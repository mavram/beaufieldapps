//
//  GDataServiceGoogleReader.h
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//

#import "GDataServiceGoogle.h"
#import "GDataQueryGoogleReader.h"
#import "GDataEntryReaderEntry.h"
#import "GDataServiceBaseExtensions.h"


@interface GDataServiceGoogleReader : GDataServiceGoogle {
    NSString *token;
}

@property (nonatomic, retain) NSString* token;

+ (NSURL *)allEntriesFeedURLForSubscription:(NSString *)subscriptionIdentifier;
+ (NSURL *)keptUnreadEntriesFeedURL;
+ (NSURL *)readingListEntriesFeedURL;
+ (NSURL *)starredEntriesFeedURL;

- (BOOL) hasToken;

- (void)fetchTokenWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSelector;
                                     
- (GDataServiceTicket *)fetchSubscriptionsWithDelegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector;

- (GDataServiceTicket *)fetchUnreadCountsWithDelegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector;

- (GDataServiceTicket *)fetchFeedReaderWithURL:(NSURL *)feedReaderURL
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector;

- (GDataServiceTicket *)fetchFeedReaderWithQuery:(GDataQueryGoogleReader *)queryReader
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector;


- (void)editStarTagForEntry:(NSString*)entryIdentifier
					   feed:(NSString *)feedIdentifier
                 forRemoval:(BOOL)forRemoval
                   delegate:(id)delegate
          didFinishSelector:(SEL)finishedSelector;

- (void)editReadTagForEntry:(NSString*)entryIdentifier
					   feed:(NSString *)feedIdentifier
                 forRemoval:(BOOL)forRemoval
                   delegate:(id)delegate
          didFinishSelector:(SEL)finishedSelector;

- (void)editKeptUnreadTagForEntry:(NSString*)entryIdentifier
							 feed:(NSString *)feedIdentifier
                       forRemoval:(BOOL)forRemoval
                         delegate:(id)delegate
                didFinishSelector:(SEL)finishedSelector;


@end
