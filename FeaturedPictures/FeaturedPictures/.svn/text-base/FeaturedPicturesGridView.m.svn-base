//
//  FeaturedPicturesGridView.m
//  Featured Pictures
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FeaturedPicturesGridView.h"
#import "NSErrorExtensions.h"


@implementation FeaturedPicturesGridView


@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize thumbnailInset = _thumbnailInset;
@synthesize thumbnailWidth = _thumbnailWidth;
@synthesize scrollView = _scrollView;
@synthesize gridDelegate = _gridDelegate;


- (id)initWithFrame:(CGRect)frame {
    
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }
    
	_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityIndicatorView setHidesWhenStopped:YES];
    [_activityIndicatorView stopAnimating];
	[self addSubview:_activityIndicatorView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setPagingEnabled:NO];
    [_scrollView setScrollsToTop:NO];
    [_scrollView setDelegate:self];
    [_scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
        
    [_scrollView setContentOffset:CGPointZero];
    [_scrollView setContentSize:CGSizeZero];
    
    [self addSubview:_scrollView];
    [self sendSubviewToBack:_scrollView];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    return self;
}


- (void)dealloc {

    [_scrollView release];
	[_activityIndicatorView release];

    [super dealloc];
}


- (void)layoutSubviews {
    
    [super layoutSubviews];

    // layout thumbnails
    NSArray *thumbnails = [_scrollView subviews];
    
    if ([thumbnails count] == 0) {
        // if fetching show activity indicator
        if ([_gridDelegate isLoading] && ![_gridDelegate isOffline]) {
            [_activityIndicatorView startAnimating];
            [_activityIndicatorView  setCenter:[self convertPoint:[self center] fromView:[self superview]]];
            [self bringSubviewToFront:_activityIndicatorView];
        } else {
            [_activityIndicatorView stopAnimating];
        }        
    } else {
        [_activityIndicatorView stopAnimating];
        
        CGFloat contentWidth = _thumbnailInset;
        CGFloat contentHeight = [self bounds].size.height;
        for (NSUInteger i = 0; i < [thumbnails count] ; i++) {;
            UIView *thumbnailView = (UIView *)[_scrollView viewWithTag:i + 1];
            if (!thumbnailView || ![thumbnailView isKindOfClass:[UIImageView class]]) {
                // thumb views are changed (another _layoutThumbs call). stop here.
                return;
            }
            
            UIImageView *thumbnailViewImage = (UIImageView *)thumbnailView;
            
            // thumbnail height & width
            if ([thumbnailViewImage image]) {
                CGFloat thumbnailHeight = contentHeight - 2*_thumbnailInset;
                CGFloat thumbnailWidth = (thumbnailHeight * _thumbnailWidth)/[[thumbnailViewImage image] size].height;
                [thumbnailView setFrame:CGRectMake(contentWidth, _thumbnailInset, thumbnailWidth, thumbnailHeight)];
                // update content
                contentWidth = contentWidth + thumbnailWidth + _thumbnailInset;
            }
        }
        
        // scroll frame & content size & offset
        [_scrollView setFrame:[self bounds]];
        [_scrollView setContentSize:CGSizeMake(contentWidth, contentHeight)];
    }
}


@end
