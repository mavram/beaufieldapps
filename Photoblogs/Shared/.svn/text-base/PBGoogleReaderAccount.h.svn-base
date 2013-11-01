//
//  PBGoogleReaderAccount.h
//  Photoblogs
//
//  Created by Mircea Avram on 10-10-01.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDataServiceGoogleReader.h"
#import "PBEntry.h"


extern NSString *kDidDetectNetworkFailureNotification;
extern NSString *kDidSynchronizeWithServerNotification;
extern NSString *kDidFetchSubscriptionsNotification;
extern NSString *kDidFetchEntriesNotification;
extern NSString *kDidToggleStarredFlagNotification;


@protocol SRGoogleReaderAccountDelegate <NSObject>
- (void)didAuthenticateUsername:(NSString *)username password:(NSString *)password;
- (void)didFailToAuthenticate;
@end



@interface PBGoogleReaderAccount : NSObject {

@private
    NSMutableDictionary *_feedsInProgress;
    NSDate *_previousSynchronizeTimestamp;
    GDataServiceGoogleReader *_service;
	id<SRGoogleReaderAccountDelegate> _delegate;
}


@property(nonatomic) BOOL isSynchronizingWithServer;
@property(nonatomic) BOOL isFetchingEntries;
@property(nonatomic) BOOL isOffline;
@property(nonatomic, retain) NSDate *previousSynchronizeTimestamp;
@property(nonatomic, retain, readonly) GDataServiceGoogleReader *service;
@property(nonatomic, assign) id<SRGoogleReaderAccountDelegate> delegate;


- (id)init;

- (void)authenticate;
- (BOOL)synchronizeWithServer;
- (BOOL)fetchPhotoblogsEntriesWithFeedURL:(NSURL *)feedURL
                          numberOfEntries:(NSUInteger)numberOfEntries;


- (void)setUserCredentialsWithUsername:(NSString *)username password:(NSString *)password;

- (void)resetFeedContinuation:(NSURL *)feedURL;


- (void)markEntryAsRead:(PBEntry *)entry;
- (void)toggleEntryStarredTag:(PBEntry *)entry;


@end
