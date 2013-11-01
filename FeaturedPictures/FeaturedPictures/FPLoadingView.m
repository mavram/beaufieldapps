//
//  FPLoadingView.m
//  FeaturedPictures
//
//  Created by mircea on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import "FPLoadingView.h"
#import "NSErrorExtensions.h"


@implementation FPLoadingView


@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize messageLabel = _messageLabel;
@synthesize name = _name;
@synthesize loadingDelegate = _loadingDelegate;


- (id)initWithFrame:(CGRect)frame {

    if (!(self = [super initWithFrame:frame])) {
        return self;
    }

    [self setBackgroundColor:[UIColor clearColor]];
    
	_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
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
    [_messageLabel setBackgroundColor:[UIColor clearColor]];
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
    
    // if item is loaded show nothing
    if ([_loadingDelegate isLoaded]) {
        [_messageLabel setHidden:YES];
        [_activityIndicatorView stopAnimating];
        return;
    }

    // find what message is visible
    if ([_loadingDelegate isOffline]) {
        NSString *m = [NSString stringWithFormat:NSLocalizedString(@"Network connectivity is required to fetch %@.", nil), _name, nil];
        [_messageLabel setText:m];
    } else if ([_loadingDelegate isLoading]) {
        NSString *m = [NSString stringWithFormat:NSLocalizedString(@"Fetching %@...", nil), _name, nil];
        [_messageLabel setText:m];
    } else {
        NSString *m = [NSString stringWithFormat:NSLocalizedString(@"No %@.", nil), _name, nil];
        [_messageLabel setText:m];
    }
    
    // resize message label
    [_messageLabel setFrame:CGRectMake(0, 0, [self bounds].size.width - 20, 100)];
    if ([[_messageLabel text] sizeWithFont:[_messageLabel font]].width > [_messageLabel bounds].size.width) {
        [_messageLabel sizeToFit];
    }

    // center message label
    [_messageLabel setCenter:[self convertPoint:[self center] fromView:[self superview]]];
    [_messageLabel setHidden:NO];

    // if fetching show activity indicator
    if ([_loadingDelegate isLoading] && ![_loadingDelegate isOffline]) {
        [_activityIndicatorView startAnimating];
        CGPoint indicatorCenter = CGPointMake([_messageLabel center].x,
                                              [_messageLabel frame].origin.y + [_messageLabel bounds].size.height);
        [_activityIndicatorView setCenter:indicatorCenter];
        [self bringSubviewToFront:_activityIndicatorView];
    } else {
        [_activityIndicatorView stopAnimating];
    }
}


- (void)dealloc {
    
    [_name release];
	[_activityIndicatorView release];
    [_messageLabel release];

    [super dealloc];
}


@end


