//
//  FPHUDView.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-16.
//  Copyright 2011 N/A. All rights reserved.
//

#import "FPHUDView.h"


@implementation FPHUDView


@synthesize opacity = _opacity;


- (id)initWithView:(UIView *)view {

	if (!view) {
		[NSException raise:NSInvalidArgumentException 
					format:@"The view used in the FPHUDView initializer is nil."];
	}

	return [self initWithFrame:view.bounds];
}


- (id)initWithFrame:(CGRect)frame {

    // make room for shadow first
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }
    
    // Set default values for properties
    _opacity = 0.4;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                            UIViewAutoresizingFlexibleBottomMargin |
                            UIViewAutoresizingFlexibleLeftMargin |
                            UIViewAutoresizingFlexibleRightMargin;
    
    // Transparent background
    [self setOpaque:NO];
    [self setBackgroundColor:[UIColor clearColor]];

    return self;
}


- (void)dealloc {

    [super dealloc];
}


#pragma mark Drawing methods


- (void)drawRect:(CGRect)rect {

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetGrayFillColor(ctx, 0.0, _opacity);
    CGRect b = [self bounds];
    CGContextFillRect(ctx, CGRectMake(b.origin.x, b.origin.y, b.size.width, b.size.height));
}


@end
