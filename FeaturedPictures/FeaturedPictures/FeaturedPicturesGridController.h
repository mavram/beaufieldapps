//
//  FeaturedPicturesGridController.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-07-07.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeaturedPicturesGridView.h"


@interface FeaturedPicturesGridController : NSObject<FeaturedPicturesGridDelegate> {
    
@private
    NSMutableArray *_missingThumbnails;
}


@property (nonatomic, retain) FeaturedPicturesGridView *gridView;


+ (CGFloat)height;
+ (void)setHeight:(CGFloat)height;
+ (void)setThumbnailInset:(CGFloat)thumbnailInset;
+ (void)setThumbnailWidth:(CGFloat)thumbnailWidth;

- (FeaturedPicturesGridView *)viewWithFrame:(CGRect)frame;
- (void)reloadThumbnails;

@end
