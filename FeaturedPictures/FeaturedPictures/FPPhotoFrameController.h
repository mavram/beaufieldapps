//
//  FPPhotoFrameController.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPPhoto.h"
#import "FPPhotoFrameView.h"


@interface FPPhotoFrameController : NSObject<FPLoadingDelegate> {

}

@property(nonatomic, retain) FPPhotoFrameView *photoFrameView;
@property(nonatomic, retain) FPPhoto *photo;

+ (CGFloat)photoWidth;

- (id)initWithPhoto:(FPPhoto *)photo;
- (FPPhotoFrameView *)viewWithFrame:(CGRect)frame;


@end
