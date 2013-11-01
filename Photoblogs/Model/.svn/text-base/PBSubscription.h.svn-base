//
//  PBSubscription.h
//  Photoblogs
//
//  Created by mircea on 10-07-21.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "GDataReaderSubscription.h"


typedef enum PBMetaSubscriptionType {
    PBMetaSubscriptionTypeNewPhotos,
    PBMetaSubscriptionTypeStarredPhotos,
    PBMetaSubscriptionTypeRegular,
    PBMetaSubscriptionTypeSubscriptionsEditor = 9999,
    PBMetaSubscriptionTypeCount = 3 // Regular doesn't count as meta
} PBMetaSubscriptionType;


extern NSString *kNewPhotosSubscriptionTitle;
extern NSString *kStarredPhotosSubscriptionTitle;
extern NSString *kSubscriptionsEditorTitle;


@interface PBSubscription : NSManagedObject {

}

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *identifier;
@property(nonatomic, retain) NSString *URL;
@property(nonatomic, retain) NSNumber *isPhotoblog;
@property(nonatomic, retain) NSString *coverPhotoCacheURL;
@property(nonatomic, retain) NSNumber *metaType;
@property(nonatomic, retain) NSNumber *isAtEnd;


+ (PBSubscription *)subscriptionWithGoogleReaderSubscription:(GDataReaderSubscription *)googleReaderSubscription;
+ (PBSubscription *)subscriptionWithMetaType:(PBMetaSubscriptionType)metaType;


- (BOOL)isPhotoblogValue;
- (BOOL)isAtEndValue;
- (PBMetaSubscriptionType)metaTypeValue;
- (NSURL *)feedURL;

- (NSUInteger)numberOfUnreadEntries;
- (NSUInteger)numberOfEntries;
- (NSArray *)entries;
- (NSArray *)unreadEntries;
- (void)deleteAllEntries;

- (NSString *)coverPhotoCacheURLValue;


@end
