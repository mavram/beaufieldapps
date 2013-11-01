//
//  FeaturedPicturesHeaderController.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-07-07.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FeaturedPicturesHeaderController.h"
#import "FeaturedPicturesAppDelegate.h"
#import "NSErrorExtensions.h"
#import "FPPhotoFrameController.h"


@implementation FeaturedPicturesHeaderController


static CGFloat __height = 110; // platform specific app delegates sets these values


@synthesize headerView = _headerView;


#pragma mark - Internals


- (void)_updateStarredButtonWithCurrentPhoto:(FPPhoto *)currentPhoto {

    // starred photo button image
    NSString *imageName = @"header_button_starred_photo";
    if ([currentPhoto isStarred]) {
        imageName = @"header_button_starred_photo_selected";
    }
    UIImage *starredPhotosButtonImage = [UIImage imageNamed:imageName];
    [[_headerView starredPhotoButton] setImage:starredPhotosButtonImage];
}


#pragma mark - Tap handlers

- (void)handleTapFromStarredPhotoButton:(UITapGestureRecognizer *)recognizer {
    
    FPPhoto *currentPhoto = [[FeaturedPicturesAppDelegate featuredPicturesController] currentPhoto];
    [currentPhoto setIsStarred:![currentPhoto isStarred]];
    [currentPhoto saveToDatabase];
    [self _updateStarredButtonWithCurrentPhoto:currentPhoto];
}


#pragma mark - Life cycle


- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }
    
	return self;
}


- (void)dealloc {
    
    [_headerView release];
    
    [super dealloc];
}


#pragma mark - Public interface


- (FeaturedPicturesHeaderView *)viewWithFrame:(CGRect)frame {
    
    if (_headerView) {
        return _headerView;
    }
    
    _headerView = [[FeaturedPicturesHeaderView alloc] initWithFrame:frame];
    
    UITapGestureRecognizer *hspbtgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromStarredPhotoButton:)] autorelease];
    [[_headerView starredPhotoButton] addGestureRecognizer:hspbtgr];
    
    return _headerView;
}


+ (CGFloat)height {
    return __height;
}


+ (void)setHeight:(CGFloat)height {
    __height = height;
}


- (void)reloadLabels {
    
    NSUInteger numberOfPhotos = [[[FeaturedPicturesAppDelegate featuredPicturesController] photos] count];
    
    // refresh title label
    NSString *title = nil;
    NSString *starredPhotosPrefix = @"Favourite Pictures";
    
    if (numberOfPhotos) {
        FPPhoto *currentPhoto = [[FeaturedPicturesAppDelegate featuredPicturesController] currentPhoto];
        if ([[FeaturedPicturesAppDelegate featuredPicturesController] showOnlyStarredPhotos]) {
            title = [NSString stringWithFormat:@"%@ (%d of %d)", starredPhotosPrefix, [[FeaturedPicturesAppDelegate featuredPicturesController] currentPhotoIndex] + 1, numberOfPhotos, nil];
        } else {
            title = [NSString stringWithFormat:@"%@, %d (%d of %d)", [currentPhoto monthName], [currentPhoto year], [[FeaturedPicturesAppDelegate featuredPicturesController] currentPhotoIndex] + 1, numberOfPhotos, nil];
        }
    } else {
        if ([[FeaturedPicturesAppDelegate featuredPicturesController] showOnlyStarredPhotos]) {
            title = starredPhotosPrefix;
        } else {
            title = [NSString stringWithFormat:@"%@, %d", [FPPhoto monthNameWithName:[[FeaturedPicturesAppDelegate featuredPicturesController] month]], [[FeaturedPicturesAppDelegate featuredPicturesController] year], nil];
        }
    }
    [[_headerView titleLabel] setText:title];
    [[_headerView titleLabel] sizeToFit];
    
    FPPhoto *currentPhoto = [[FeaturedPicturesAppDelegate featuredPicturesController] currentPhoto];
    if (numberOfPhotos) {
        // refresh subtitle label
        [[_headerView subtitleLabel] setText:[currentPhoto title]];
        [[_headerView subtitleLabel] sizeToFit];
        [self _updateStarredButtonWithCurrentPhoto:currentPhoto];
    }
}


@end
