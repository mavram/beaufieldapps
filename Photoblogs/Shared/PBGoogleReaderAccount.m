//
//  PBGoogleReaderAccount.m
//  Photoblogs
//
//  Created by Mircea Avram on 10-10-01.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBGoogleReaderAccount.h"
#import "PBAppDelegate.h"

#import "NSErrorExtensions.h"

#import "GDataReaderObjectSubscriptionsList.h"
#import "GDataReaderObjectUnreadCountsList.h"
#import "GDataReaderSubscription.h"
#import "GDataFeedReader.h"
#import "GDataQueryGoogleReader.h"
#import "GDataReaderUnreadCount.h"

#import "PBModel.h"
#import "PBEntry.h"
#import "PBPhoto.h"


BADefineUnitOfWork(authenticate);
BADefineUnitOfWork(fetchToken);
BADefineUnitOfWork(fetchSubscriptions);
BADefineUnitOfWork(fetchUnreadCount);
BADefineUnitOfWork(fetchEntries);
BADefineUnitOfWork(synchronizeWithServer);


NSUInteger kMinimumNumberOfEntriesToFetchWhenSynchronizing = 256; // 1000 is maximum supported


NSString *kDidDetectNetworkFailureNotification              = @"kDidDetectNetworkFailureNotification";
NSString *kDidSynchronizeWithServerNotification             = @"kDidSynchronizeWithServerNotification";
NSString *kDidFetchSubscriptionsNotification                = @"kDidFetchSubscriptionsNotification";
NSString *kDidFetchEntriesNotification                      = @"kDidFetchEntriesNotification";
NSString *kDidToggleStarredFlagNotification                 = @"kDidToggleStarredFlagNotification";

static NSString *kTimestampKey                                      = @"kTimestampKey";
static NSString *kFetchPhotoblogsEntriesFeedURLKey                  = @"kFetchPhotoblogsEntriesFeedURLKey";
static NSString *kFetchPhotoblogsEntriesNumberOfEntriesKey          = @"kFetchPhotoblogsEntriesNumberOfEntriesKey";


@interface PBGoogleReaderAccount (__Internal__)

- (NSString *)_feedContinuation:(NSURL *)feed;
- (void)_setContinuation:(NSString *)continuation feed:(NSURL *)feed;

- (PBSubscription*)_subscriptionWithIdentifier:(NSString *)subscriptionIdentifier;
- (void)_postSynchronizeWithServerCleanup;

- (void)_fetchToken;
- (void)_fetchUnreadCounts;
- (void)_fetchSubscriptionsSynchronizingWithServer:(BOOL)isSynchronizingWithServer;
- (void)_fetchEntriesWithContinuation:(NSString *)continuation
                              feedURL:(NSURL*)feedURL
                      numberOfEntries:(NSUInteger)numberOfEntries;

@end



@implementation PBGoogleReaderAccount


@synthesize isOffline = _isOffline;
@synthesize isSynchronizingWithServer = _isSynchronizingWithServer;
@synthesize isFetchingEntries = _isFetchingEntries;
@synthesize previousSynchronizeTimestamp = _previousSynchronizeTimestamp;
@synthesize service = _service;
@synthesize delegate  = _delegate;


- (id)init {
	
    if (!(self = [super init])) {
        return self;
    }
    
    _service = [[GDataServiceGoogleReader alloc] init];
    _isSynchronizingWithServer = NO;
    _isFetchingEntries = NO;
    _isOffline = NO;
    _feedsInProgress = [NSMutableDictionary new];
    
    return self;
}


- (void)dealloc {
    
    [_previousSynchronizeTimestamp release];
    [_service release];
    [_feedsInProgress release];

	[super dealloc];
}


#pragma mark - Internal helpers


- (PBSubscription*)_subscriptionWithIdentifier:(NSString *)subscriptionIdentifier {
    
    // find the subscription by identifier
    NSArray *subscriptions = [[PBModel sharedModel] subscriptions];
    for (PBSubscription *subscription in subscriptions) {
        if ([[subscription identifier] isEqualToString:subscriptionIdentifier]) {
            return subscription;
        }
    }
    
    // none found
    return nil;
}


- (void)_postSynchronizeWithServerCleanup {
    
    NSNotification *note = [NSNotification notificationWithName:kDidSynchronizeWithServerNotification
                                                         object:nil
                                                       userInfo:nil];
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];	
    
    _isSynchronizingWithServer = NO;
    
    BAEndUnitOfWork(synchronizeWithServer);
}


- (void)_fetchToken {
    
    [PBAppDelegate startNetworkIndicator];
    BABeginUnitOfWork(fetchToken);
    [_service fetchTokenWithDelegate:self
                   didFinishSelector:@selector(finishedWithToken:error:)];
}


- (void)finishedWithToken:(NSData *)data error:(NSError *)error {
    
    [PBAppDelegate stopNetworkIndicator];
	
    if (error) {
        // notify observers about network failure
        NSNotification *note = [NSNotification notificationWithName:kDidDetectNetworkFailureNotification
                                                             object:error
                                                           userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:note];

        BAEndUnitOfWork(fetchToken);
        return;
    }
    
    // refresh the service token
    NSString *token = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [_service setToken:token];
	[token release];
    
    BAEndUnitOfWork(fetchToken);
}


- (void)_fetchSubscriptionsSynchronizingWithServer:(BOOL)isSynchronizingWithServer {

    [PBAppDelegate startNetworkIndicator];
    
    BABeginUnitOfWork(fetchSubscriptions);
    
    [_service fetchSubscriptionsWithDelegate:self
                           didFinishSelector:@selector(ticket:finishedWithSubscriptions:error:)];
}


- (void)ticket:(GDataServiceTicket *)ticket finishedWithSubscriptions:(GDataReaderObjectSubscriptionsList *)subscriptionsList error:(NSError *)error {
    
    [PBAppDelegate stopNetworkIndicator];

    if (error) {                
        // notify observers about network failure
        {
            NSNotification *note = [NSNotification notificationWithName:kDidDetectNetworkFailureNotification
                                                                 object:error
                                                               userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:note];
        }
        
        // notify observers about fetching subscriptions
        {
            NSNotification *note = [NSNotification notificationWithName:kDidFetchSubscriptionsNotification
                                                                 object:nil
                                                               userInfo:nil];
            [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                                       postingStyle:NSPostASAP
                                                       coalesceMask:NSNotificationNoCoalescing
                                                           forModes:nil];
        }
        
        BAEndUnitOfWork(fetchSubscriptions);

        // if part of synchronizeWithServer send the notification
        if (_isSynchronizingWithServer) {
            [self _postSynchronizeWithServerCleanup];
        }

        return;
    }
    
    PBModel *model = [PBModel sharedModel];
    NSArray *googleReaderSubscriptions = [subscriptionsList objects];
    
    // add new subscription
    NSUInteger numberOfNewSubscriptions = 0;
    for (GDataReaderSubscription *googleReaderSubscription in googleReaderSubscriptions) {
        if (![self _subscriptionWithIdentifier:[googleReaderSubscription identifier]]) {
            PBSubscription *subscription = [model addSubscriptionWithGoogleReaderSubscription:googleReaderSubscription];
            if (subscription) {
                numberOfNewSubscriptions++;
            }
        }
    }

    // some of the subscriptions might be obsolete
    NSMutableArray *obsoleteSubscriptions = [[NSMutableArray alloc] init];
    for (PBSubscription *subscription in [model subscriptions]) {
        // only regular subscriptions can get obsolete
        if ([subscription metaTypeValue] != PBMetaSubscriptionTypeRegular) {
            continue;
        }

		BOOL isSubscriptionObsolete = YES;
		for (GDataReaderSubscription *googleReaderSubscription in googleReaderSubscriptions) {
			if ([[googleReaderSubscription identifier] isEqualToString:[subscription identifier]]) {
				isSubscriptionObsolete = NO;
                break;
			}
		}

        if (isSubscriptionObsolete) {
			[obsoleteSubscriptions addObject:subscription];
        }
    }

	// remove obsolete subscriptions
    for (PBSubscription *subscription in obsoleteSubscriptions) {
        // remove the subscription from the model
        [[PBModel sharedModel] removeSubscription:subscription];
    }
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Did fetch <%d> subscriptions with <%d> obsolete and <%d> new.",
                   [googleReaderSubscriptions count] , [obsoleteSubscriptions count], numberOfNewSubscriptions);
#endif

	[obsoleteSubscriptions release];

    BAEndUnitOfWork(fetchSubscriptions);

    NSNotification *note = [NSNotification notificationWithName:kDidFetchSubscriptionsNotification
                                                         object:nil
                                                       userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];	

    if (_isSynchronizingWithServer) {
        // reset offline mode
        _isOffline = NO;
        // fetch unread counts
        [self _fetchUnreadCounts];
    }
}


- (void)_fetchUnreadCounts {

    [PBAppDelegate startNetworkIndicator];
    
    BABeginUnitOfWork(fetchUnreadCount);
    
    [_service fetchUnreadCountsWithDelegate:self
                          didFinishSelector:@selector(ticket:finishedWithUnreadCounts:error:)];    

}


- (void)ticket:(GDataServiceTicket *)ticket finishedWithUnreadCounts:(GDataReaderObjectUnreadCountsList *)unreadCountsList error:(NSError *)error {
	
    [PBAppDelegate stopNetworkIndicator];
	
    if (error) {        
        // notify observers about network failure
        NSNotification *note = [NSNotification notificationWithName:kDidDetectNetworkFailureNotification
                                                             object:error
                                                           userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:note];
        
        BAEndUnitOfWork(fetchUnreadCount);
        
        // if part of synchronizeWithServer send the notification
        if (_isSynchronizingWithServer) {
            [self _postSynchronizeWithServerCleanup];
        }
        
        return;
    }
    
    // set new unread counts
#ifdef __DEBUG_APP_LIFECYCLE__
    NSUInteger numberOfUnreadEntries = 0;
#endif
    NSUInteger numberOfUnreadPhotoblogEntries = 0;
    NSArray *unreadCounts = [unreadCountsList objects];
    for (GDataReaderUnreadCount *unreadCount in unreadCounts) {
        NSString *identifier = [unreadCount identifier];
        NSUInteger count = [[unreadCount count] integerValue];

        if ([unreadCount isTotalCount]) {
#ifdef __DEBUG_APP_LIFECYCLE__
            numberOfUnreadEntries = count;
#endif
        } else {
            PBSubscription *subscription = [self _subscriptionWithIdentifier:identifier];
            if ([subscription isPhotoblogValue]) {
                numberOfUnreadPhotoblogEntries += count;
            }
        }
    }

#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Did find <%d> new photos out of <%d> entries.", numberOfUnreadPhotoblogEntries, numberOfUnreadEntries);
#endif
    
    BAEndUnitOfWork(fetchUnreadCount);
    
    if (_isSynchronizingWithServer) {    
        // fetch reading list
        NSURL *readingListURL = [GDataServiceGoogleReader readingListEntriesFeedURL];
        
        // start fetching reading list. even if no unread we fetch as we may
        // have them mark as read from google reader. when synchronizing with server
        // we stop at first duplicate
        [self _fetchEntriesWithContinuation:nil
                                    feedURL:readingListURL
                            numberOfEntries:numberOfUnreadPhotoblogEntries];
    }
}


- (void)_fetchEntriesWithContinuation:(NSString *)continuation
                              feedURL:(NSURL *)feedURL
                      numberOfEntries:(NSUInteger)numberOfEntries {

    [PBAppDelegate startNetworkIndicator];
    
    if (!_isFetchingEntries) {
        BABeginUnitOfWork(fetchEntries);
    }
    _isFetchingEntries = YES;
    

    // setup query
    GDataQueryGoogleReader *queryReader = [GDataQueryGoogleReader readerQueryWithFeedURL:feedURL];
    if (continuation) {
        [queryReader setContinuation:continuation];
    }
    // if we are synchronizing with server we don't want to many roundtrips
    // so we batch the retrieval
    if (_isSynchronizingWithServer) {
        [queryReader setCount:(numberOfEntries < kMinimumNumberOfEntriesToFetchWhenSynchronizing) ? kMinimumNumberOfEntriesToFetchWhenSynchronizing : numberOfEntries];
    } else {
        [queryReader setCount:numberOfEntries];
    }
    
    // fetch entries list
    GDataServiceTicket *ticket = [_service fetchFeedReaderWithQuery:queryReader
                                                           delegate:self
                                                  didFinishSelector:@selector(ticket:finishedFetchingEntries:error:)];
    
    
    // carry over
    [ticket setProperty:feedURL forKey:kFetchPhotoblogsEntriesFeedURLKey];
    // how many we need to fetch. when synchronizing with server it refers to unread ones
    [ticket setProperty:[NSNumber numberWithInteger:numberOfEntries] forKey:kFetchPhotoblogsEntriesNumberOfEntriesKey];
}


- (void)ticket:(GDataServiceTicket *)ticket finishedFetchingEntries:(GDataFeedReader *)feed error:(NSError *)error {

    [PBAppDelegate stopNetworkIndicator];
    
    // get carry over params
    NSURL *feedURL = (NSURL *)[ticket propertyForKey:kFetchPhotoblogsEntriesFeedURLKey];
    NSUInteger numberOfEntries = [(NSNumber *)[ticket propertyForKey:kFetchPhotoblogsEntriesNumberOfEntriesKey] integerValue];
    
    if (error) {        
        // notify observers about network failure
        {
            NSNotification *note = [NSNotification notificationWithName:kDidDetectNetworkFailureNotification
                                                                 object:error
                                                               userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:note];
        }
        
        // notify about entries
        {
            NSNotification *note = [NSNotification notificationWithName:kDidFetchEntriesNotification
                                                                 object:feedURL
                                                               userInfo:nil];
            [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                                       postingStyle:NSPostASAP
                                                       coalesceMask:NSNotificationNoCoalescing
                                                           forModes:nil];	
        }
        
        BAEndUnitOfWork(fetchEntries);
        _isFetchingEntries = NO;
        
        // if part of synchronizeWithServer send the notification
        if (_isSynchronizingWithServer) {
            [self _postSynchronizeWithServerCleanup];
        }
        
        return;
    }
    
    // synchronize the entries
    [[PBModel sharedModel] DB];
    BOOL didFindDuplicatedEntry = NO;
    for (GDataEntryReaderEntry *googleReaderEntry in [feed entries]) {
        PBSubscription *subscription = [self _subscriptionWithIdentifier:[[googleReaderEntry source] streamId]];
        
        if (![subscription isPhotoblogValue]) {
            continue;
        }
        
        // loop through google reader entries until we have fetched numberOfEntries.
        // if synchronizing with server we consider only unread items and we stop when
        // we find first duplicate or we have all the unread items
        PBEntry *entry = [PBEntry entryWithIdentifier:[googleReaderEntry identifier]];
        if (_isSynchronizingWithServer) {
            if (entry) {
                // found a duplicate. stop
                didFindDuplicatedEntry = YES;
                break;
            } else if ([googleReaderEntry isRead] == NO) {
                // found one more unread item
                numberOfEntries = numberOfEntries - 1;
            }
        } else {
            // any non-duplicated entry will do
            if (!entry) {
                numberOfEntries = numberOfEntries - 1;
            } else {
                // here we can update entry flags - unread/starred/...
                continue;
            }
        }
        
        // add the entry (since we skip duplicates we won't get status
        // changes for entries fetched already - e.g. starred/unread/...)
        [PBEntry insertOrReplaceEntryWithGoogleReaderEntry:googleReaderEntry withSubscription:subscription];
        
        if (numberOfEntries == 0) {
            // got them all
            break;
        }
    }

    // relase the db instance
    [[PBModel sharedModel] releaseDB];
    
    // when synchronizing this is used for subsquent fetches
    // but never for the first one
    NSString *continuation = [[feed continuation] stringValue];
    if (continuation) {
        [self _setContinuation:continuation feed:feedURL];
    }

    if (didFindDuplicatedEntry) {
        // this happens only when synchronizing with server
#ifdef __DEBUG_APP_LIFECYCLE__
        BADebugMessage(@"Did find duplicate entry. Stop fetching with <%d> unprocessed entries.", numberOfEntries);
#endif
    } else {
#ifdef __DEBUG_APP_LIFECYCLE__
        if (numberOfEntries > 0) {
            BADebugMessage(@"Did fetch entries. Needs to fetch <%d> more.", numberOfEntries);
        } else {
            BADebugMessage(@"Did fetch entries.");
        }
#endif

        // if more are left, get them
        if (numberOfEntries > 0) {
            // check if more available
            if (continuation != nil) {
                [self _fetchEntriesWithContinuation:continuation
                                            feedURL:feedURL
                                    numberOfEntries:numberOfEntries];
                return;
            } else {
                // get subscription to update isAtEnd flag
                for (PBSubscription *subscription in [[PBModel sharedModel] subscriptions]) {
                    if ([[subscription feedURL] isEqual:feedURL]) {
                        [subscription setIsAtEnd:[NSNumber numberWithBool:YES]];
                        [[PBModel sharedModel] saveContext];
#ifdef __DEBUG_APP_LIFECYCLE__
                        BADebugMessage(@"Did reach the end for subscription <%@>", [subscription title]);
#endif
                        break;
                    }
                }
            }
        }        
    }
        
    BAEndUnitOfWork(fetchEntries);
    _isFetchingEntries = NO;

    // notify about entries
    NSNotification *note = [NSNotification notificationWithName:kDidFetchEntriesNotification
                                                         object:feedURL
                                                       userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];	

    // notify synchronization is done
    if (_isSynchronizingWithServer) {
        [self _postSynchronizeWithServerCleanup];
    }
}


- (void)authenticate {
    
    [PBAppDelegate startNetworkIndicator];
    BABeginUnitOfWork(authenticate);
    [_service authenticateWithDelegate:self
               didAuthenticateSelector:@selector(ticket:authenticateWithError:)];
}


- (void)ticket:(GDataServiceTicket *)ticket authenticateWithError:(NSError *)error {
	
    [PBAppDelegate stopNetworkIndicator];
	
    if (error) {
        // check first if authentication failed
        if (![[_service username] length] || ![[_service password] length] || ([error code] == 403)) {
			[_delegate didFailToAuthenticate];
            // reset offline mode
            _isOffline = NO;
        } else {
            // notify observers about network failure
            NSNotification *note = [NSNotification notificationWithName:kDidDetectNetworkFailureNotification
                                                                 object:error
                                                               userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:note];
        }
        BAEndUnitOfWork(authenticate);
        return;
    }
    
    BAEndUnitOfWork(authenticate);
    
    // reset offline mode
    _isOffline = NO;
    
    // reset all feeds in progress
    @synchronized(self) {
        [_feedsInProgress removeAllObjects];
    }
	
    // start fetching the token
    [self _fetchToken];
	[_delegate didAuthenticateUsername:[_service username] password:[_service password]];
}


- (BOOL)synchronizeWithServer {
    
    // check if enough time has passed
	NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_previousSynchronizeTimestamp];
	if (timeInterval < [[[[PBModel sharedModel] appSettings] synchronizeTimeInterval] intValue]) {
		return NO;
	}
    
    BABeginUnitOfWork(synchronizeWithServer);
    
    // refresh synchronization timestamp
	[self setPreviousSynchronizeTimestamp:[NSDate date]];
    
    _isSynchronizingWithServer = YES;
    
    // start by fetching subscriptions
    [self _fetchSubscriptionsSynchronizingWithServer:_isSynchronizingWithServer];
    
    return YES;
}


- (void)setUserCredentialsWithUsername:(NSString *)username password:(NSString *)password {
    
    // save them for Google Reader service
    [_service setUserCredentialsWithUsername:username password:password];
}


- (BOOL)fetchPhotoblogsEntriesWithFeedURL:(NSURL *)feedURL
                          numberOfEntries:(NSUInteger)numberOfEntries {
    
    if (_isSynchronizingWithServer || _isFetchingEntries) {
        return NO;
    }
    
    NSString *cachedContinuation = [self _feedContinuation:feedURL];
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Fetching <%d> entries. %@",
                   numberOfEntries,
                   cachedContinuation ? cachedContinuation : @"No continuation.");
#endif

    // start fetching reading list
    [self _fetchEntriesWithContinuation:cachedContinuation
                                feedURL:feedURL
                        numberOfEntries:numberOfEntries];
    
    return YES;
}


- (void)markEntryAsRead:(PBEntry *)entry {
    
    if ([entry isRead]) {
        return;
    }
    
    [entry markAsRead];
    
    [PBAppDelegate startNetworkIndicator];
	
    [_service editReadTagForEntry:[entry identifier]
                             feed:[entry feedIdentifier]
                       forRemoval:NO
                         delegate:self
                didFinishSelector:@selector(finishedMarkingEntryAsRead:error:)];
}


- (void)finishedMarkingEntryAsRead:(NSData *)data error:(NSError *)error {
    
    [PBAppDelegate stopNetworkIndicator];
    
    if (error != nil) {
        [error printErrorToConsoleWithMessage:[NSString stringWithFormat:@"Failed to mark entry as read"]];

        // notify observers about network failure
        NSNotification *note = [NSNotification notificationWithName:kDidDetectNetworkFailureNotification
                                                             object:error
                                                           userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    }
}


- (void)toggleEntryStarredTag:(PBEntry *)entry {
    
    [PBAppDelegate startNetworkIndicator];
    
    [entry toggleStarredFlag];
    
    [_service editStarTagForEntry:[entry identifier]
                             feed:[entry feedIdentifier]
                                  forRemoval:![entry isStarred] // we did changed flag in DB. use !
                                    delegate:self
                           didFinishSelector:@selector(finishedTogglingEntryStarredTag:error:)];
    
}


- (void)finishedTogglingEntryStarredTag:(NSData *)data error:(NSError *)error {
    
    [PBAppDelegate stopNetworkIndicator];
    
    if (error != nil) {
        // notify observers about network failure
        NSNotification *note = [NSNotification notificationWithName:kDidDetectNetworkFailureNotification
                                                             object:error
                                                           userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:note];

        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to toggle starred flag. Please try again."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
        return;
    }
    
    // notify observers
    NSNotification *note = [NSNotification notificationWithName:kDidToggleStarredFlagNotification
                                                         object:nil
                                                       userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}


#pragma mark - Feeds in progress


- (NSString *)_feedContinuation:(NSURL *)feed {
    
    @synchronized(self) {
        return (NSString *)[_feedsInProgress objectForKey:feed];
    }
}


- (void)_setContinuation:(NSString *)continuation feed:(NSURL *)feed {
    
    @synchronized(self) {
        [_feedsInProgress setObject:continuation forKey:feed];
    }
}


- (void)resetFeedContinuation:(NSURL *)feedURL {

    @synchronized(self) {
        [_feedsInProgress removeObjectForKey:feedURL];
    }
}


@end
