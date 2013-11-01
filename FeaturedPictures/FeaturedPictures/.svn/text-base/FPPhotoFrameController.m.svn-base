//
//  FPPhotoFrameController.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-17.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import "FPPhotoFrameController.h"
#import "NSErrorExtensions.h"
#import "FeaturedPicturesAppDelegate.h"
#import "FPWikipediaManager.h"


static CGFloat __photoWidth = 1024;


@implementation FPPhotoFrameController


@synthesize photoFrameView = _photoFrameView;
@synthesize photo = _photo;


#pragma mark - FPWikipediaManager notifications


- (void)didFetchPhoto:(NSNotification*)note {
    
    FPPhoto *photo = (FPPhoto *)[note object];
    NSDictionary *userInfo = [note userInfo];
    NSUInteger photoWidth = [(NSNumber*)[userInfo objectForKey:kDidFetchPhotoNotificationPhotoWidth] integerValue];
    
    // discard thumbnail notifications
    if (photoWidth != __photoWidth) {
        return;
    }

    // check if is our photo
    if (![[photo photoPageURL] isEqualToString:[_photo photoPageURL]]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    UIImage *cachedImage = [_photo cachedImageWithWidth:__photoWidth];
    [_photoFrameView setImage:cachedImage];
    [_photoFrameView setNeedsLayout];
    [_photoFrameView layoutIfNeeded];

}


#pragma mark - Lifecycle


- (id)initWithPhoto:(FPPhoto *)photo {

    if (!(self = [super init])) {
        return self;
    }

    [self setPhoto:photo];

	return self;
}	


- (void) dealloc {
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[_photo release];
	[_photoFrameView removeFromSuperview];
	[_photoFrameView release];

	[super dealloc];
}


- (UIView *)viewWithFrame:(CGRect)frame {

	if (_photoFrameView) {
		return _photoFrameView;
	}

    UIImage *cachedImage = [_photo cachedImageWithWidth:__photoWidth];
    _photoFrameView = [[FPPhotoFrameView alloc] initWithFrame:frame image:cachedImage];
    
    if (!cachedImage && ![self isOffline]) {
        // photo is either fetching already or we'll start fetching it
        // register for notifications first
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFetchPhoto:)
                                                     name:kDidFetchPhotoNotification
                                                   object:nil];
        [[FPWikipediaManager sharedWikipediaManager] fetchPhoto:_photo photoWidth:__photoWidth];
    }

    [_photoFrameView setLoadingDelegate:self];

	return _photoFrameView;
}


#pragma mark - FPLoadingDelegate


- (BOOL)isLoaded {

    BOOL hasCachedImage = [_photo hasCachedImageWithWidth:__photoWidth];
    return hasCachedImage;
}


- (BOOL)isOffline {
    return [FeaturedPicturesAppDelegate isOffline];
}


- (BOOL)isLoading {
    return [[FPWikipediaManager sharedWikipediaManager] isFetchingPhoto:_photo width:__photoWidth];
}


+ (CGFloat)photoWidth {
    return __photoWidth;
}


@end
