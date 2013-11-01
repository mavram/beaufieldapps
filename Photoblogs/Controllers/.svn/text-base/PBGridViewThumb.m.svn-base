//
//  PBGridViewThumb.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBGridViewThumb.h"
#import "NSErrorExtensions.h"
#import "PBGridView.h"


@implementation PBGridViewThumb


static const CGFloat kThumbInset_iPad = 10;
static const CGFloat kThumbWidth_iPad = 246;
static const CGFloat kThumbInset_iPhone = 5;
static const CGFloat kThumbWidth_iPhone = 155;




@synthesize imageCacheURL = _imageCacheURL;
@synthesize thumbHeight = _thumbHeight;
@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize activityIndicatorView = _activityIndicatorView;


+ (CGFloat)thumbInset {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return kThumbInset_iPhone;
    }
    return kThumbInset_iPad;
}


+ (CGFloat)thumbWidth {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return kThumbWidth_iPhone;
    }
    return kThumbWidth_iPad;
}


+ (NSString *)thumbURLWithCacheURL:(NSString *)cacheURL {
    
    return [cacheURL stringByAppendingString:@"_"];
}


- (void)dealloc {

    [_imageCacheURL release];
    [_imageView release];
    [_activityIndicatorView release];
    [_titleLabel release];
    [_subtitleLabel release];
    
    [super dealloc];
}


- (id)initWithImageCacheURL:(NSString *)imageCacheURL title:(NSString*)title subtitle:(NSString*)subtitle defaultHeight:(CGFloat)defaultHeight {
    
    if (![super initWithFrame:CGRectZero]) {
        return self;
    }
    
    // default thumb height
    _thumbHeight = defaultHeight;
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[_activityIndicatorView setHidesWhenStopped:YES];
    if ([self isBusy]) {
        [_activityIndicatorView startAnimating];
    } else {
        [_activityIndicatorView stopAnimating];
    }
    [self addSubview:_activityIndicatorView];
	
    [self setImageCacheURL:imageCacheURL];
	[self setTitle:title];
	[self setSubtitle:subtitle];
    
    [self setBackgroundColor:[UIColor blackColor]];
    
    return self;   
}


- (void)layoutSubviews {
    
    CGPoint currentOrigin = [self frame].origin;
    [self setFrame:CGRectMake(currentOrigin.x, currentOrigin.y, [PBGridViewThumb thumbWidth], _thumbHeight)];

    if (_imageView) {
        [_imageView setFrame:CGRectMake(0, 0, [PBGridViewThumb thumbWidth], _thumbHeight)];
        [self sendSubviewToBack:_imageView];
    }

	if (_titleLabel) {
		CGSize titleLabelSize = [_titleLabel bounds].size;
		[_titleLabel setFrame:CGRectMake([PBGridViewThumb thumbWidth] - titleLabelSize.width,
                                         _thumbHeight - titleLabelSize.height - [PBLabel labelInset],
                                         titleLabelSize.width,
                                         titleLabelSize.height)];
	}
	
	if (_subtitleLabel) {
		CGSize subtitleLabelSize = [_subtitleLabel bounds].size;
		[_subtitleLabel setFrame:CGRectMake(0,
                                            [PBLabel labelInset],
                                            subtitleLabelSize.width,
                                            subtitleLabelSize.height)];
	}
        
    // center activity indicator
    //[_activityIndicatorView setCenter:[self convertPoint:[self center] fromView:[self superview]]];
    // position at top left corner
    [_activityIndicatorView setFrame:CGRectMake(0, 0, [_activityIndicatorView frame].size.width, [_activityIndicatorView frame].size.width)];
    // always keep it last
    [self bringSubviewToFront:_activityIndicatorView];
}


- (void)setTitle:(NSString *)title {

    if (title) {
		if (_titleLabel) {
			[_titleLabel setText:title];
		} else {
			_titleLabel = [[PBLabel alloc] initWithText:title width:[PBGridViewThumb thumbWidth]];
			[self addSubview:_titleLabel];
		}
        [_titleLabel sizeToFit];
        [self setNeedsLayout];
    } else {
		[_titleLabel removeFromSuperview];
		[self setTitleLabel:nil];
    }
}


- (void)setSubtitle:(NSString *)subtitle {

    if (subtitle) {
		if (_subtitleLabel) {
			[_subtitleLabel setText:subtitle];
		} else {
#ifdef __DEBUG_LAYOUT_SUBVIEWS__
			_subtitleLabel = [[PBLabel alloc] initWithText:subtitle width:[PBGridViewThumb thumbWidth]];
#else
            _subtitleLabel = [[PBLabel alloc] initWithText:subtitle width:[PBGridViewThumb thumbWidth]/2];
#endif
			[self addSubview:_subtitleLabel];
		}
        [_subtitleLabel sizeToFit];
        [self setNeedsLayout];
    } else {
		[_subtitleLabel removeFromSuperview];
		[self setSubtitleLabel:nil];
    }
}


- (void)showImage:(BOOL)isVisible {
    
    if (isVisible) {
        // check if optimized thumb is available
        NSString *p = _imageCacheURL;
        NSString *p_ = [PBGridViewThumb thumbURLWithCacheURL:_imageCacheURL];

        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        UIImage *image = nil;
        if ([fileManager fileExistsAtPath:p_] == NO) {
            image = [UIImage imageWithContentsOfFile:p];
        } else {
            image = [UIImage imageWithContentsOfFile:p_];
        }
        
        if (image) {
            _thumbHeight = [image size].height*[PBGridViewThumb thumbWidth]/[image size].width;
            if (_imageView) {
                [_imageView setImage:image];
            } else {
                _imageView = [[UIImageView alloc] initWithImage:image];
                [_imageView setContentMode: UIViewContentModeScaleToFill];
                [self addSubview:_imageView];
            }
        } else {
            if ([self isBusy]) {
                [_activityIndicatorView startAnimating];
            } else {
                [_activityIndicatorView stopAnimating];
            }
        }
    } else {
        // check if we need to release the _imageView
        if (_imageView) {
            // preserve thumb height
            [_imageView removeFromSuperview];
            [self setImageView:nil];
        }
    }
    
    [self setNeedsLayout];
}


- (BOOL)isBusy {

    return NO;
}


@end

