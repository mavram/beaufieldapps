//
//  FeaturedPicturesGridView.h
//  Featured Pictures
//
//  Created by Mircea Avram on 11-04-03.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPPhoto.h"
#import "FPHUDView.h"


@protocol FeaturedPicturesGridDelegate <NSObject>

- (BOOL)isLoading;
- (BOOL)isOffline;

@end


@interface FeaturedPicturesGridView : FPHUDView<UIScrollViewDelegate> {
}

@property (nonatomic, assign) CGFloat thumbnailWidth;
@property (nonatomic, assign) CGFloat thumbnailInset;
@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, assign) id<FeaturedPicturesGridDelegate> gridDelegate;


- (id)initWithFrame:(CGRect)frame;


@end
