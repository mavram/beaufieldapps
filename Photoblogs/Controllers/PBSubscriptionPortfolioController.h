//
//  PBSubscriptionPortfolioController.h
//  Photoblogs
//
//  Created by mircea on 10-07-29.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBSubscription.h"
#import "PBSubscriptionPortfolioView.h"


@interface PBSubscriptionPortfolioController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, PBPortfolioIteratorDelegate> {
 
@private
    NSUInteger _currentEntryIdx;
}

@property (nonatomic, retain) PBSubscriptionPortfolioView *portfolioView;
@property (nonatomic, retain) NSMutableArray *entryPhotosControllers;
@property (nonatomic, retain) PBSubscription *subscription;
@property (nonatomic, retain) NSArray *cachedEntries;
@property (nonatomic, assign) UIActionSheet *actionSheet;


- (id)initWithSubscription:(PBSubscription *)subscription entryIdx:(NSUInteger)entryIdx;

@end
