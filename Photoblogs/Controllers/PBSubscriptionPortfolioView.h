//
//  PBSubscriptionPortfolioView.h
//  Photoblogs
//
//  Created by mircea on 10-08-04.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PBPortfolioIteratorDelegate <NSObject>

- (NSUInteger)numberOfEntries;
- (NSUInteger)currentEntryIndex;

@end


@interface PBSubscriptionPortfolioView : UIScrollView {
}


@property (nonatomic, assign) id<PBPortfolioIteratorDelegate> iteratorDelegate;


@end
