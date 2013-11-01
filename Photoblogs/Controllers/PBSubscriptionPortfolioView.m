//
//  PBSubscriptionPortfolioView.m
//  Photoblogs
//
//  Created by mircea on 10-08-04.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBSubscriptionPortfolioView.h"
#import "NSErrorExtensions.h"


@implementation PBSubscriptionPortfolioView


@synthesize iteratorDelegate = _iteratorDelegate;


- (id)initWithFrame:(CGRect)frame {

    if (![super initWithFrame:frame]) {
        return self;
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setPagingEnabled:YES];
    [self setDirectionalLockEnabled:YES];
    [self setScrollsToTop:NO];

    return self;
}


- (void)layoutSubviews {

	[super layoutSubviews];
    
    UIView *firstSubview = nil;
    if ([[self subviews] count]) {
        // first subview can be replaced as we cycle to keep only 3 controllers
        // that will skew off the numbers and will trigger unecessary update
        if ([[self subviews] count] == 1) {
            firstSubview = [[self subviews] objectAtIndex:0];
        } else {
            firstSubview = [[self subviews] objectAtIndex:1];
        }
    }
    if (firstSubview && ([self frame].size.height != [firstSubview frame].size.height)) {        
        // size
        CGSize currentContentSize = CGSizeMake([self bounds].size.width*[_iteratorDelegate numberOfEntries],
                                               [self bounds].size.height);
        [self setContentSize:currentContentSize];
        // offset
        CGPoint currentContentOffset = CGPointMake([self bounds].size.width*[_iteratorDelegate currentEntryIndex], 0);
        [self setContentOffset:currentContentOffset];
    }
    
    // subviews
    for (UIView *entryPhotosView in [self subviews]) {
		[entryPhotosView setFrame:CGRectMake([self frame].size.width * [entryPhotosView tag], 0,
											 [self frame].size.width, [self frame].size.height)];
    }
}


@end
