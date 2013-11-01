//
//  PBSubscriptionGridViewThumb.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBSubscriptionGridViewThumb.h"
#import "PBEntry.h"


@implementation PBSubscriptionGridViewThumb 


@synthesize subscription = _subscription;


- (void)dealloc {
    
    [_subscription release];
    
    [super dealloc];
}


- (NSString *) unreadCountAsStringWithSubscription:(PBSubscription *)subscription {
    
    NSUInteger unreadCount = 0;
    
    if ([subscription metaTypeValue] == PBMetaSubscriptionTypeNewPhotos) {
        unreadCount = [PBEntry numberOfUnreadEntries];
    } else if ([subscription metaTypeValue] == PBMetaSubscriptionTypeRegular) { // individual subscription
        unreadCount = [PBEntry numberOfUnreadEntriesWithSubscription:subscription];
    }

    NSString *unreadCountAsString = nil;
    if (unreadCount) {
        unreadCountAsString = [NSString stringWithFormat:@"%d", unreadCount];
    }
    return unreadCountAsString;
}


- (id)initWithSubscription:(PBSubscription *)subscription {

    NSString *unreadCountAsString = [self unreadCountAsStringWithSubscription:subscription];

    if (![super initWithImageCacheURL:[subscription coverPhotoCacheURLValue]
                                title:[subscription title]
                             subtitle:unreadCountAsString
                        defaultHeight:[PBGridViewThumb thumbWidth]]) {
        return self;
    }

    [self setSubscription:subscription];
	
    return self;   
}


- (void)refreshUnreadCounts {

    NSString *unreadCountAsString = [self unreadCountAsStringWithSubscription:_subscription];

    [self setSubtitle:unreadCountAsString];
	[self setNeedsLayout];
}


@end
