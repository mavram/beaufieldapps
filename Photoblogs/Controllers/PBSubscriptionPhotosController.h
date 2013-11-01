//
//  PBSubscriptionPhotosController.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBGridView.h"
#import "PBSubscription.h"


@interface PBSubscriptionPhotosController : UIViewController<PBGridViewDelegate, UIActionSheetDelegate> {

}


@property (nonatomic, retain) PBGridView *gridView;
@property (nonatomic, retain) PBSubscription *subscription;
@property (nonatomic, retain) NSArray *cachedEntries;
@property(nonatomic, assign) UIActionSheet *actionSheet;


- (id)initWithSubscription:(PBSubscription *)subscription;


@end
