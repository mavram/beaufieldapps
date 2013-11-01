//
//  PBLabel.m
//  Photoblogs
//
//  Created by mircea on 10-07-21.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBLabel.h"
#import "NSErrorExtensions.h"


@implementation PBLabel

static const CGFloat kFontSize			= 40;
static const CGFloat kLabelInset_iPad   = 20;
static const CGFloat kLabelInset_iPhone = 10;

@synthesize width = _width;
@synthesize label = _label;

+ (CGFloat)labelInset {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return kLabelInset_iPhone;
    }
    return kLabelInset_iPad;
}

- (void)dealloc {

    [_label release];
    [super dealloc];
}

- (id)initWithText:(NSString *)text width:(CGFloat)width{

    // init label
    CGRect frame = CGRectMake(0, 0, width, [PBLabel labelInset]);
    _label = [[UILabel alloc] initWithFrame:frame];
    [_label setBackgroundColor:[UIColor blackColor]];
    [_label setAlpha:0.5];
    [_label setTextColor:[UIColor whiteColor]];
	[self setText:text];
    [_label setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [_label setAdjustsFontSizeToFitWidth:YES];
    
    // init self
    if (([self initWithFrame:[_label bounds]]) == nil) {
        return self;
    }
    
    _width = width;
    
    [self addSubview:_label];

    return self;   
}

- (void)setText:(NSString *)text {
	[_label setText:[NSString stringWithFormat:@" %@ ", text]];
}

- (void)sizeToFit {
	
    CGFloat labelFontMinimumSize = 16;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        labelFontMinimumSize = 8;
    }
    [_label setMinimumFontSize:labelFontMinimumSize];
    
    CGFloat labelMaxWidth= _width - [PBLabel labelInset];
    
    CGFloat labelFontActualSize = 0;
    NSString *fontName = @"GillSans";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        fontName = @"Trebuchet MS";
    }
    UIFont *labelFont = [UIFont fontWithName:fontName size:kFontSize];
    CGSize labelSize = [[_label text] sizeWithFont:labelFont
                                       minFontSize:labelFontMinimumSize
                                    actualFontSize:&labelFontActualSize
                                          forWidth:labelMaxWidth
                                     lineBreakMode:UILineBreakModeTailTruncation];
    [_label setFont:[labelFont fontWithSize:labelFontActualSize]];
    [_label sizeToFit];
    [_label setFrame:CGRectMake(0,
							   0,
							   labelSize.width,
							   [_label bounds].size.height)];
	
	[self setFrame:CGRectMake([self bounds].origin.x,
							  [self bounds].origin.y,
							  [_label bounds].size.width,
							  [_label bounds].size.height)];
}


@end
