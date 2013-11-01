//
//  PBPhotoFrameController.m
//  Photoblogs
//
//  Created by Mircea Avram on 10-10-22.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBPhotoFrameController.h"
#import "NSErrorExtensions.h"
#import "PBAppDelegate.h"
#import "PBPhotoManager.h"


@implementation PBPhotoFrameController


@synthesize view = _view;
@synthesize photo = _photo;
@synthesize entry = _entry;
@synthesize photoIdx = _photoIdx;


- (id)initWithPhoto:(PBPhoto *)photo entry:(PBEntry *) entry photoIdx:(NSUInteger)photoIdx {

    if (!(self = [super init])) {
        return self;
    }
	
    [self setPhoto:photo];
    [self setEntry:entry];
    _photoIdx = photoIdx;

	return self;
}	


- (void) dealloc {
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[_photo release];
    [_entry release];
	[_view removeFromSuperview];
	[_view release];

	[super dealloc];
}


- (UIView *)view {

	if (_view) {
		return _view;
	}
    
    _view = [[PBPhotoFrameView alloc] initWithImage:nil];
    // for super layoutSubviews
    [_view setTag:_photoIdx];
    [_view setPhotoDelegate:self];

    if ([_photo cacheURL]) {
        [_view setImage:[UIImage imageWithContentsOfFile:[_photo cacheURL]]];
    } else {
        if ([self isOffline] == NO) {
            // photo is either fetching already or we'll start fetching it
            // register for notifications first
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didFetchPhoto:)
                                                         name:kDidFetchPhotoNotification
                                                       object:nil];
            [[PBPhotoManager sharedPhotoManager] fetchPhoto:_photo withEntry:_entry];
        }
    }

	return _view;
}


#pragma mark - PhotoManager notifications


- (void)didFetchPhoto:(NSNotification*)note {
    
    PBPhoto *photo = (PBPhoto *)[note object];

    // check if is our photo
    if (![[photo URL] isEqualToString:[_photo URL]]) {
        return;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // since we cached local copy ivars did update (cacheURL for one)
    [self setPhoto:photo];
    
    if ([_photo cacheURL]) {
        [_view setImage:[UIImage imageWithContentsOfFile:[_photo cacheURL]]];
    }
    
    [_view setNeedsLayout];
    [_view layoutIfNeeded];
}


#pragma mark - PhotoFrameDelegate


- (BOOL)isOffline {
    return [[[PBAppDelegate sharedAppDelegate] googleReaderAccount] isOffline];
}


- (BOOL)isFetchingPhoto {
    return [[PBPhotoManager sharedPhotoManager] isFetchingPhoto:_photo];
}


@end
