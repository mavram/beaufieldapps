//
//  PBGridViewThumb.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "PBLabel.h"


@interface PBGridViewThumb : UIView {

}

@property(nonatomic, retain) NSString *imageCacheURL;
@property(nonatomic, readonly) CGFloat thumbHeight;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) PBLabel *titleLabel;
@property(nonatomic, retain) PBLabel *subtitleLabel;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;


+ (CGFloat)thumbInset;
+ (CGFloat)thumbWidth;
+ (NSString *)thumbURLWithCacheURL:(NSString *)cacheURL;


- (id)initWithImageCacheURL:(NSString *)imageCacheURL title:(NSString*)title subtitle:(NSString*)subtitle defaultHeight:(CGFloat)defaultHeight;

- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;

- (void)showImage:(BOOL)isVisible;

- (BOOL)isBusy;


@end

