//
//  PBEntryPhotosView.m
//  PhotoBlogs
//
//  Created by mircea on 10-08-04.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBEntryPhotosView.h"
#import "NSErrorExtensions.h"


@implementation PBEntryPhotosView


@synthesize messageLabel = _messageLabel;
@synthesize iteratorDelegate = _iteratorDelegate;


- (id)initWithFrame:(CGRect)frame {

    if (!(self = [super initWithFrame:frame])) {
        return self;
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setPagingEnabled:YES];
    [self setDirectionalLockEnabled:YES];
    [self setScrollsToTop:NO];
    [self setBounces:NO];

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
    [_messageLabel setText:@"This post has no photos."];
    [_messageLabel setAdjustsFontSizeToFitWidth:YES];
    [self addSubview:_messageLabel];
    
    return self;   
}


- (void)dealloc {
    
    [_messageLabel release];
    [super dealloc];
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
	if (_messageLabel) {
        [_messageLabel setFrame:CGRectMake(0, 0, [self bounds].size.width - 20, 100)];
        if ([[_messageLabel text] sizeWithFont:[_messageLabel font]].width > [_messageLabel bounds].size.width) {
            [_messageLabel sizeToFit];
        }
		[_messageLabel setCenter:[self convertPoint:[self center] fromView:[self superview]]];
        
        return;
	}
    
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
        CGSize currentContentSize = CGSizeMake([self bounds].size.width, [self bounds].size.height*[_iteratorDelegate numberOfPhotos]);
        [self setContentSize:currentContentSize];
        // offset
        CGPoint currentContentOffset = CGPointMake(0, [self bounds].size.height*[_iteratorDelegate currentPhotoIndex]);
        [self setContentOffset:currentContentOffset];
    }
    
    // subviews
	for (UIView *photoFrameView in [self subviews]) {
        [photoFrameView setFrame:CGRectMake(0, [self frame].size.height * [photoFrameView tag],
                                            [self frame].size.width, [self frame].size.height)];
	}
}


- (void)setIteratorDelegate:(id<PBEntryPhotosIteratorDelegate>)iteratorDelegate {
    
    _iteratorDelegate = iteratorDelegate;
    
    // check if we need to remove message label
    if ([_iteratorDelegate numberOfPhotos]) {
        [_messageLabel removeFromSuperview];
        [self setMessageLabel:nil];
    }
}


@end


