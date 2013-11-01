//
//  FPPhotoFrameView.h
//  FeaturedPictures
//
//  Created by mircea on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPLoadingView.h"


@interface FPPhotoFrameView : FPLoadingView<UIScrollViewDelegate> {

}


@property (nonatomic, retain) UIScrollView *zoomingScrollView;


- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)setImage:(UIImage *)image;

- (void)setMaxMinZoomScalesForCurrentBounds;

@end
