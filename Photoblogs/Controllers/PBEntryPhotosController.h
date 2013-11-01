//
//  PBEntryPhotosController.h
//  Photoblogs
//
//  Created by Mircea Avram on 10-10-21.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBEntryPhotosView.h"
#import "PBEntry.h"


@interface PBEntryPhotosController : NSObject<UIScrollViewDelegate, PBEntryPhotosIteratorDelegate> {
    
@private
    NSUInteger _currentPhotoIdx;
}

@property(nonatomic, retain, readonly) PBEntryPhotosView *view;
@property(nonatomic, retain) PBEntry *entry;
@property(nonatomic, retain) NSArray *cachedEntryPhotos;
@property(nonatomic) NSUInteger entryIdx;
@property(nonatomic, retain) NSMutableArray *photoFrameControllers;

- (id)initWithEntry:(PBEntry *)entry entryIdx:(NSUInteger)entryIdx;

- (void)toggleStar;
- (void)saveCurrentPhotoToAlbums;
- (void)showOriginal;

- (NSString *)title;
- (NSString *)currentPhotoCacheURL;


@end
