//
//  PBPhotoFrameView.h
//  Photoblogs
//
//  Created by mircea on 10-08-04.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	PBPhotoFrameModeUIKit,
	PBPhotoFrameModeFullScreen
} PBPhotoFrameMode;


@protocol PBPhotoFrameDelegate <NSObject>

- (BOOL)isFetchingPhoto;
- (BOOL)isOffline;

@end


@interface PBPhotoFrameView : UIView {

}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain, readonly) UIImageView *imageView;
@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UILabel *messageLabel; 
@property (nonatomic, assign) id<PBPhotoFrameDelegate> photoDelegate;


+ (PBPhotoFrameMode)photoFrameMode;
+ (void)setPhotoFrameMode:(PBPhotoFrameMode)mode;


- (id)initWithImage:(UIImage *)image;


@end
