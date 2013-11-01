//
//  GDataServiceGoogleReader.m
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "NSStringExtensions.h"

#import "GDataServiceGoogleReader.h"
#import "GDataReaderObjectSubscriptionsList.h" 
#import "GDataReaderObjectUnreadCountsList.h"
#import "GDataFeedReader.h"


@implementation GDataServiceGoogleReader

@synthesize token;

+ (NSString *)serviceRootURLString {
    return @"http://www.google.com/reader"; 
}

+ (NSURL *)tokenURL {
    NSString *rootURLString = [self serviceRootURLString];        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/0/token", rootURLString]];
    return url;    
}

+ (NSURL *)entryEditingURL { 
    NSString *rootURLString = [self serviceRootURLString];        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/0/edit-tag?client=scroll", rootURLString]];
    return url;
}

+ (NSURL *)subscriptionsReaderObjectURL {
    NSString *rootURLString = [self serviceRootURLString];        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/0/subscription/list", rootURLString]];
    return url;
}

+ (NSURL *)unreadCountReaderObjectURL {
    NSString *rootURLString = [self serviceRootURLString];        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/0/unread-count", rootURLString]];
    return url;
}

+ (NSURL *)entriesFeedURLByType:(NSString *)type {
    NSString *rootURLString = [self serviceRootURLString];        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/atom/user/-/state/com.google/%@", rootURLString, type]];
    return url;
}

- (void)editEntry:(NSString *)entryIdentifier
			 feed:(NSString *)feedIdentifier
		  withTag:(NSString *)tag
       forRemoval:(BOOL)forRemoval
         delegate:(id)delegate
didFinishSelector:(SEL)finishedSelector {

    NSString *currentToken = [self token];

    if (currentToken == nil) {
        NSAssert(currentToken != nil, @"Invalid token.");
    }
    
    // Use a dummy URL as all we need is the query string
    GDataQuery *postQuery = [[[GDataQuery alloc] initWithFeedURL:[GDataServiceGoogleReader subscriptionsReaderObjectURL]] autorelease];
    
    NSString *actionType = nil;
    if (forRemoval) {
        actionType = @"r";
    } else {
        actionType = @"a";
    }
    
    [postQuery addCustomParameterWithName:actionType value:tag];
    [postQuery addCustomParameterWithName:@"async" value:@"true"];
    [postQuery addCustomParameterWithName:@"i" value:entryIdentifier];
    {
        NSString *feedName = [NSString stringWithFormat:@"%@", feedIdentifier];
        [postQuery addCustomParameterWithName:@"s" value:feedName];
    }
    [postQuery addCustomParameterWithName:@"pos" value:@"0"];
    [postQuery addCustomParameterWithName:@"T" value:currentToken];
    
    NSData *uploadData = [[[postQuery URL] query] dataUsingEncoding: NSASCIIStringEncoding];
    return [self fetchDataWithURL:[GDataServiceGoogleReader entryEditingURL]
                       dataToPost:uploadData
                         delegate:delegate
                didFinishSelector:finishedSelector];
}


#pragma mark -
#pragma mark NSObject Overrides

- (void)dealloc {
    
    [self setToken:nil];
    
    [super dealloc];
}

- (id)init {
    if ([super init] == nil) {
        return nil;
    }

    [self setToken:nil];

    return self;
}


#pragma mark -
#pragma mark Public Methods


+ (NSString *)serviceID {
    return @"reader";
}

+ (NSURL *)allEntriesFeedURLForSubscription:(NSString *)subscriptionIdentifier {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/atom/%@",
                                       [self serviceRootURLString], [subscriptionIdentifier stringByURLEncoding]]];
    return url;
}

+ (NSURL *)keptUnreadEntriesFeedURL {
    return [self entriesFeedURLByType: @"kept-unread"];
}

+ (NSURL *)readingListEntriesFeedURL {
    return [self entriesFeedURLByType: @"reading-list"];
}

+ (NSURL *)starredEntriesFeedURL {
    return [self entriesFeedURLByType: @"starred"];
}


#pragma mark -
#pragma mark Additional HTTP fetchers

- (void)fetchTokenWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSelector {

    // reset existing token (if any)
    [self setToken:nil];
    // fetch new token
    [self fetchDataWithURL:[GDataServiceGoogleReader tokenURL]
                dataToPost:nil
                  delegate:delegate
         didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchSubscriptionsWithDelegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector {
    
    NSURL *url = [GDataServiceGoogleReader subscriptionsReaderObjectURL];
    return [self fetchFeedWithURL:url
                        feedClass:[GDataReaderObjectSubscriptionsList class]
                             ETag:nil
                         delegate:delegate
                didFinishSelector:finishedSelector];
}
                               
- (GDataServiceTicket *)fetchUnreadCountsWithDelegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector {
   
    NSURL *url = [GDataServiceGoogleReader unreadCountReaderObjectURL];
    return [self fetchFeedWithURL:url
                        feedClass:[GDataReaderObjectUnreadCountsList class]
                             ETag:nil
                         delegate:delegate
                didFinishSelector:finishedSelector]; 
}


- (GDataServiceTicket *)fetchFeedReaderWithURL:(NSURL *)feedReaderURL
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector {

    return [self fetchFeedWithURL:feedReaderURL
                        feedClass:[GDataFeedReader class]
                         delegate:delegate
                didFinishSelector:finishedSelector];
}


- (GDataServiceTicket *)fetchFeedReaderWithQuery:(GDataQueryGoogleReader *)queryReader
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector {
    
    return [self fetchFeedWithQuery:queryReader
                          feedClass:[GDataFeedReader class]
                           delegate:delegate
                  didFinishSelector:finishedSelector];
}

- (void)editStarTagForEntry:(NSString *)entryIdentifier
					   feed:(NSString *)feedIdentifier
                 forRemoval:(BOOL)forRemoval
                   delegate:(id)delegate
          didFinishSelector:(SEL)finishedSelector {

    return [self editEntry:entryIdentifier
					  feed:feedIdentifier
                   withTag:@"user/-/state/com.google/starred"
                forRemoval:forRemoval
                  delegate:delegate
         didFinishSelector:finishedSelector];
}

- (void)editReadTagForEntry:(NSString *)entryIdentifier
					   feed:(NSString *)feedIdentifier
                 forRemoval:(BOOL)forRemoval
                   delegate:(id)delegate
          didFinishSelector:(SEL)finishedSelector {
    
    return [self editEntry:entryIdentifier
					  feed:feedIdentifier
                   withTag:@"user/-/state/com.google/read"
                forRemoval:forRemoval
                  delegate:delegate
         didFinishSelector:finishedSelector];
}

- (void)editKeptUnreadTagForEntry:(NSString *)entryIdentifier
							 feed:(NSString *)feedIdentifier
                       forRemoval:(BOOL)forRemoval
                         delegate:(id)delegate
                didFinishSelector:(SEL)finishedSelector {
    
    return [self editEntry:entryIdentifier
					  feed:feedIdentifier
                   withTag:@"user/-/state/com.google/kepy-unread"
                forRemoval:forRemoval
                  delegate:delegate
         didFinishSelector:finishedSelector];
}

- (BOOL) hasToken {
    return (token != nil);
}

@end
