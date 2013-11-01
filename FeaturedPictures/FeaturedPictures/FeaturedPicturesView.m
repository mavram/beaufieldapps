//
//  FeaturedPicturesView.m
//  FeaturePictures
//
//  Created by mircea on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import "NSErrorExtensions.h"
#import "FeaturedPicturesView.h"
#import "FeaturedPicturesAppDelegate.h"


@implementation FeaturedPicturesView


@synthesize pagingScrollView = _pagingScrollView;


- (id)initWithFrame:(CGRect)frame {
    
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }
    
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                            UIViewAutoresizingFlexibleBottomMargin |
                            UIViewAutoresizingFlexibleLeftMargin |
                            UIViewAutoresizingFlexibleRightMargin;
    
    [self setBackgroundColor:[UIColor clearColor]];
        

    _pagingScrollView = [[UIScrollView alloc] initWithFrame:[self bounds]];
    
    [_pagingScrollView setBackgroundColor:[UIColor clearColor]];
    [_pagingScrollView setShowsVerticalScrollIndicator:NO];
    [_pagingScrollView setShowsHorizontalScrollIndicator:NO];
    [_pagingScrollView setPagingEnabled:YES];
    [_pagingScrollView setDirectionalLockEnabled:YES];
    [_pagingScrollView setScrollsToTop:NO];
    
    [self addSubview:_pagingScrollView];
    [self sendSubviewToBack:_pagingScrollView];
    
    return self;
}


- (void)dealloc {
    
    [_pagingScrollView release];
    
    [super dealloc];
}


- (void)layoutSubviews {
    
    [super layoutSubviews];

    for (UIView *v in [self subviews]) {
        [v setNeedsLayout];
    }
}


@end

