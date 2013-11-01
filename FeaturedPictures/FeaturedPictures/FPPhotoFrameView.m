//
//  FPPhotoFrameView.m
//  FeaturedPictures
//
//  Created by mircea on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import "FPPhotoFrameView.h"
#import "NSErrorExtensions.h"


@interface FPPhotoFrameView (__Internal__)

// add internal methods here

@end


@implementation FPPhotoFrameView


@synthesize zoomingScrollView = _zoomingScrollView;


- (id)initWithFrame:(CGRect)frame image:(UIImage *)image {

    if (!(self = [super initWithFrame:frame])) {
        return self;
    }

    [self setBackgroundColor:[UIColor clearColor]];    
    [self setName:@"picture"];
    [self setUserInteractionEnabled:YES];

    if (!image) {
        return self;
    }

    [self setImage:image];

    return self;   
}


- (void)layoutSubviews {
    
    [super layoutSubviews];

    if (_zoomingScrollView) {
        UIImageView *imageView = (UIImageView*)[self viewForZoomingInScrollView:nil];

        CGSize boundsSize = [_zoomingScrollView bounds].size;
        CGRect frameToCenter = [imageView frame];
        
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width)
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        else
            frameToCenter.origin.x = 0;
        
        // center vertically
        if (frameToCenter.size.height < boundsSize.height)
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        else
            frameToCenter.origin.y = 0;
        
        [imageView setFrame:frameToCenter];
    }
}


- (void)dealloc {

    if (_zoomingScrollView) {
        [_zoomingScrollView release];
    }

    [super dealloc];
}


#pragma mark - UIScrollViewDelegate


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return (UIImageView*)[[_zoomingScrollView subviews] objectAtIndex:0];
}


- (void)setMaxMinZoomScalesForCurrentBounds {
    
    [_zoomingScrollView setFrame:[self bounds]];
    
    CGSize boundsSize = _zoomingScrollView.bounds.size;
    CGSize imageSize = [self viewForZoomingInScrollView:nil].bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // don't let minScale exceed maxScale. (If the image is smaller
    // than the screen, we don't want to force it to be zoomed.) 
    CGFloat maxScale = 2.0;
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    [_zoomingScrollView setMaximumZoomScale:maxScale];
    [_zoomingScrollView setMinimumZoomScale:minScale];
    [_zoomingScrollView setZoomScale:minScale];
}


- (void)setImage:(UIImage *)image {
    
    NSAssert(!_zoomingScrollView, @"...");
    
    _zoomingScrollView = [[UIScrollView alloc] initWithFrame:[self bounds]];
    
    [_zoomingScrollView setBackgroundColor:[UIColor clearColor]];
    [_zoomingScrollView setShowsVerticalScrollIndicator:NO];
    [_zoomingScrollView setShowsHorizontalScrollIndicator:NO];
    [_zoomingScrollView setDirectionalLockEnabled:YES];
    [_zoomingScrollView setClipsToBounds: YES];
    [_zoomingScrollView setContentSize:image.size];
    [_zoomingScrollView setDelegate:self];
    [self addSubview:_zoomingScrollView];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    [_zoomingScrollView addSubview:imageView];
    [_zoomingScrollView setContentSize:[image size]];
    
    [self setMaxMinZoomScalesForCurrentBounds];
}


@end


