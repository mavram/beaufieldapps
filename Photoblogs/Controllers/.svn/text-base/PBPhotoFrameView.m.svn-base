//
//  PBPhotoFrameView.m
//  Photoblogs
//
//  Created by mircea on 10-08-04.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBPhotoFrameView.h"
#import "NSErrorExtensions.h"
#import "PBAppDelegate.h"


@implementation PBPhotoFrameView


static const CGFloat kPhotoInset = 20;
static PBPhotoFrameMode __photoFrameMode = PBPhotoFrameModeUIKit;


@synthesize image = _image;
@synthesize imageView = _imageView;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize messageLabel = _messageLabel;
@synthesize photoDelegate = _photoDelegate;


+ (PBPhotoFrameMode)photoFrameMode {
	return __photoFrameMode;
}


+ (void)setPhotoFrameMode:(PBPhotoFrameMode)mode {
	__photoFrameMode = mode;
}


- (id)initWithImage:(UIImage *)image {

    if (!(self = [super initWithFrame:CGRectZero])) {
        return self;
    }

    [self setBackgroundColor:[UIColor blackColor]];
    [self setImage:image];

    _imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_imageView];
    
	_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityIndicatorView setHidesWhenStopped:YES];
    [_activityIndicatorView stopAnimating];
	[self addSubview:_activityIndicatorView];
    
    _messageLabel = [UILabel new];
    NSString *fontName = @"GillSans";
    CGFloat fontSize = 26;
    CGFloat minimumFontSize = 12;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontName = @"Trebuchet MS";
        fontSize = 14;
        minimumFontSize = 12;
    }
    [_messageLabel setBackgroundColor:[UIColor blackColor]];
    [_messageLabel setTextColor:[UIColor whiteColor]];
    [_messageLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
    [_messageLabel setMinimumFontSize:minimumFontSize];
    [_messageLabel setTextAlignment:UITextAlignmentCenter];
	[_messageLabel setText:@""];
    [_messageLabel setAdjustsFontSizeToFitWidth:YES];
	[_messageLabel setHidden:YES];
	[self addSubview:_messageLabel];

    return self;   
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if ([_photoDelegate isFetchingPhoto]) {
        [_activityIndicatorView startAnimating];
        [_activityIndicatorView setCenter:CGPointMake([self center].x, [self bounds].size.height - [_activityIndicatorView frame].size.height)];
    } else {
        [_activityIndicatorView stopAnimating];
    }

    if (_image == nil) {
        if ([_photoDelegate isOffline]) {
            [_messageLabel setText:@"Network connectivity is required to fetch photo."];
        } else if ([_photoDelegate isFetchingPhoto]) {
            [_messageLabel setText:@"Fetching photo..."];
        } else {
            [_messageLabel setText:@"Can not fetch photo."];
        }
        [_messageLabel setFrame:CGRectMake(0, 0, [self bounds].size.width - 20, 100)];
        if ([[_messageLabel text] sizeWithFont:[_messageLabel font]].width > [_messageLabel bounds].size.width) {
            [_messageLabel sizeToFit];
        }
		[_messageLabel setCenter:[self convertPoint:[self center] fromView:[self superview]]];
        [_messageLabel setHidden:NO];
    } else {
        [_messageLabel setHidden:YES];
    }

    if (_image) {
        if ([PBAppDelegate isLiteVersion]) {
            [_imageView setImage:[UIImage imageNamed:@"Photo-Sample"]];
        } else {
            [_imageView setImage:_image];
        }
        [_imageView sizeToFit];

        CGFloat photoInset = kPhotoInset;
        if (__photoFrameMode == PBPhotoFrameModeFullScreen) {
            photoInset = 0.0;
        }

        CGRect insetFrame = CGRectMake(0, 0, CGRectGetWidth([self frame]) - 2*photoInset, CGRectGetHeight([self frame]) - 2*photoInset);
        CGRect photoFrame = [_imageView frame];
        
        if (!CGRectContainsRect(insetFrame, photoFrame) || (__photoFrameMode == PBPhotoFrameModeFullScreen)) {
            if ((CGRectGetHeight(photoFrame) > CGRectGetHeight(insetFrame)) || (__photoFrameMode == PBPhotoFrameModeFullScreen)) {
                [_imageView setFrame:CGRectMake(0,
                                                0,
                                                CGRectGetWidth(photoFrame)*CGRectGetHeight(insetFrame)/CGRectGetHeight(photoFrame),
                                                CGRectGetHeight(insetFrame))];
                photoFrame = [_imageView frame];
            }
            
            if (CGRectGetWidth(photoFrame) > CGRectGetWidth(insetFrame)) {
                [_imageView setFrame:CGRectMake(0,
                                                0,
                                                CGRectGetWidth(insetFrame),
                                                CGRectGetHeight(photoFrame)*CGRectGetWidth(insetFrame)/CGRectGetWidth(photoFrame))];
            }
        }
        
        [_imageView setCenter:[self convertPoint:[self center] fromView:[self superview]]];    
    }
}


- (void)dealloc {
    
    [_image release];
    [_imageView release];
	[_activityIndicatorView release];
    [_messageLabel release];

    [super dealloc];
}


@end


