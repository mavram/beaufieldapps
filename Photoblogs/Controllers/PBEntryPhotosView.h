//
//  PBEntryPhotosView.h
//  Photoblogs
//
//  Created by mircea on 10-08-04.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PBEntryPhotosIteratorDelegate <NSObject>

- (NSUInteger)numberOfPhotos;
- (NSUInteger)currentEntryIndex;
- (NSUInteger)currentPhotoIndex;

@end


@interface PBEntryPhotosView : UIScrollView {
}


@property(nonatomic, retain) UILabel *messageLabel; 
@property (nonatomic, assign) id<PBEntryPhotosIteratorDelegate> iteratorDelegate;


@end
