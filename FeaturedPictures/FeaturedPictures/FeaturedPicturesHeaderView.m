//
//  FPPortfolioHeaderView.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-18.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FeaturedPicturesAppDelegate.h"
#import "FeaturedPicturesHeaderView.h"
#import "NSErrorExtensions.h"

static CGFloat __hinset = 9;
static CGFloat __vinset = 9;

@implementation FeaturedPicturesHeaderView


@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize starredPhotoButton = _starredPhotoButton;


- (id)initWithFrame:(CGRect)frame {
    
    if (!(self = [super initWithFrame:frame])) {
        return self;
    }
    
    // title label
    _titleLabel = [UILabel new]; {
        NSString *fontName = @"GillSans";
        CGFloat fontSize = 36;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            fontName = @"Trebuchet MS";
            fontSize = 20;
        }
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
        [_titleLabel setTextAlignment:UITextAlignmentLeft];
        [_titleLabel setMinimumFontSize:10];
        [_titleLabel setText:@""];
        [_titleLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:[self opacity] + 0.1]];
        [_titleLabel setShadowOffset:CGSizeMake(-2, -1)];
        [_titleLabel setUserInteractionEnabled:YES];
    }
	[self addSubview:_titleLabel];
    
    // subtitle label
    _subtitleLabel = [UILabel new]; {
        NSString *fontName = @"GillSans";
        CGFloat fontSize = 24;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            fontName = @"Trebuchet MS";
            fontSize = 12;
        }
        [_subtitleLabel setBackgroundColor:[UIColor clearColor]];
        [_subtitleLabel setTextColor:[UIColor whiteColor]];
        [_subtitleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
        [_subtitleLabel setTextAlignment:UITextAlignmentLeft];
        [_subtitleLabel setText:@""];
        [_subtitleLabel setMinimumFontSize:8];
        [_subtitleLabel setLineBreakMode:UILineBreakModeTailTruncation];
        [_subtitleLabel setUserInteractionEnabled:YES];
    }
	[self addSubview:_subtitleLabel];
    
    // starred photo button
    _starredPhotoButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_button_starred_photo"]];
    [_starredPhotoButton setUserInteractionEnabled:YES];
    [self addSubview:_starredPhotoButton];
    
    return self;   
}


- (void)dealloc {
    
    [_titleLabel release];
    [_subtitleLabel release];
    [_starredPhotoButton release];
    
    [super dealloc];
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSUInteger numberOfPhotos = [[[FeaturedPicturesAppDelegate featuredPicturesController] photos] count];

    // layout title label
    [_titleLabel sizeToFit];
    CGRect titleLabelRect = [_titleLabel bounds];
    titleLabelRect.origin.x = __hinset;
    titleLabelRect.origin.y = __vinset;
    [_titleLabel setFrame:titleLabelRect];
        
    // widgets available only when photos are present
    if (numberOfPhotos) {
        // layout subtitle label
        [_subtitleLabel setHidden:NO];
        [_subtitleLabel setAdjustsFontSizeToFitWidth:NO];
        [_subtitleLabel sizeToFit];
        CGRect subtitleLabelRect = [_subtitleLabel bounds];
        subtitleLabelRect.origin.x = __hinset;
        subtitleLabelRect.origin.y = titleLabelRect.origin.y + titleLabelRect.size.height + __vinset;
        [_subtitleLabel setFrame:subtitleLabelRect];
        
        // make sure subtitle doesn't exceed header width (after left & right hinsets were deducted)
        CGFloat maxSubtitleLabelWidth = [self bounds].size.width - 2*__hinset;
        CGSize sizeWithCurrentFont = [[_subtitleLabel text] sizeWithFont:[_subtitleLabel font]];
        
        if (sizeWithCurrentFont.width > maxSubtitleLabelWidth) {
            CGRect adjustedSubtitleLabelRect = [_subtitleLabel frame];
            adjustedSubtitleLabelRect.size.width = maxSubtitleLabelWidth;
            [_subtitleLabel setFrame:adjustedSubtitleLabelRect];
            [_subtitleLabel setAdjustsFontSizeToFitWidth:YES];[_subtitleLabel setFrame:adjustedSubtitleLabelRect];
        }
        
        // layout starred photo button
        [_starredPhotoButton setHidden:NO];
        CGRect starredPhotoButtonRect = [_starredPhotoButton bounds];
        starredPhotoButtonRect.origin.x =[self bounds].size.width - starredPhotoButtonRect.size.width - __hinset;
        starredPhotoButtonRect.origin.y = __vinset;
        [_starredPhotoButton setFrame:starredPhotoButtonRect];
    } else {
        [_starredPhotoButton setHidden:YES];
        [_subtitleLabel setHidden:YES];
    }
}


@end
