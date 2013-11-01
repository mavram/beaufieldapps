//
//  FeaturedPicturesController.h
//  FeaturedPictures
//
//  Created by mircea on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeaturedPicturesView.h"
#import "FeaturedPicturesHeaderController.h"
#import "FeaturedPicturesGridController.h"


@interface FeaturedPicturesController : UIViewController <UIScrollViewDelegate, FPLoadingDelegate, UIAlertViewDelegate> {

}

@property (nonatomic, assign) NSUInteger month;
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) BOOL showOnlyStarredPhotos;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
@property (nonatomic, retain) FeaturedPicturesHeaderController *headerController;
@property (nonatomic, retain) FeaturedPicturesGridController *gridController;
@property (nonatomic, retain) FeaturedPicturesView *featuredPicturesView;
@property (nonatomic, retain, readonly) NSMutableArray *photoFrameControllers;


- (void)syncronizeWithWikimedia;

- (BOOL)moveToNextPhoto;
- (BOOL)moveToPreviousPhoto;
- (BOOL)moveToNextYear;
- (BOOL)moveToNextMonth;
- (BOOL)moveToPreviousYear;
- (BOOL)moveToPreviousMonth;
- (BOOL)moveToPhotoAtIndex:(NSUInteger)photoIndex;

- (FPPhoto *)currentPhoto;


@end
