//
//  PBSubscriptionGridViewThumb.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBGridViewThumb.h"
#import "PBSubscription.h"



@interface PBSubscriptionGridViewThumb : PBGridViewThumb {
    
}


@property(nonatomic, retain) PBSubscription *subscription;

- (id)initWithSubscription:(PBSubscription *)subscription;

- (void)refreshUnreadCounts;


@end
