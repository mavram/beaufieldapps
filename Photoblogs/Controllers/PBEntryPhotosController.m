//
//  PBEntryPhotosController.m
//  Photoblogs
//
//  Created by Mircea Avram on 10-10-21.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "PBEntryPhotosController.h"
#import "PBAppDelegate.h"
#import "NSErrorExtensions.h"
#import "PBPhotoFrameController.h"
#import "PBPhotoManager.h"


@implementation PBEntryPhotosController


@synthesize view = _view;
@synthesize entry = _entry;
@synthesize cachedEntryPhotos = _cachedEntryPhotos;
@synthesize entryIdx = _entryIdx;
@synthesize photoFrameControllers = _photoFrameControllers;


- (id)initWithEntry:(PBEntry *)entry entryIdx:(NSUInteger)entryIdx {

    if (!(self = [super init])) {
        return self;
    }

    [self setEntry:entry];
	
    _entryIdx = entryIdx;
    _currentPhotoIdx = NSNotFound;
	_photoFrameControllers = [[NSMutableArray alloc] init];
    
    // cache them so if photos that we fetch are discarded
    // we won't run into concurrency issues
    [self setCachedEntryPhotos:[_entry photos]];
    
#ifdef __DEBUG_APP_LIFECYCLE__
    //BADebugMessage(@"Did load entry <%@> with <%d> photos", [_entry title], [_cachedEntryPhotos count]);
#endif
	
	return self;
}


- (void)dealloc {

	[_view removeFromSuperview];
	[_view release];
	[_entry release];
    [_cachedEntryPhotos release];
	[_photoFrameControllers release];
	
    [super dealloc];
}


- (PBPhotoFrameController *)_photoFrameControllerAtIndex:(NSInteger)index {
	for (PBPhotoFrameController *photoFrameController in _photoFrameControllers) {
		if ([photoFrameController photoIdx] == _currentPhotoIdx) {
			return photoFrameController;
		}
	}
	// assert
	return nil;
}


- (void)_addPhotoFrameControllerAtIndex:(NSInteger)index {
	
	PBPhoto *photo = [_cachedEntryPhotos objectAtIndex:index];
 	PBPhotoFrameController *photoFrameController = [[[PBPhotoFrameController alloc] initWithPhoto:photo
                                                                                            entry:_entry
                                                                                         photoIdx:index] autorelease];
	if (index >= _currentPhotoIdx) {
		[_photoFrameControllers addObject:photoFrameController];
		[_view addSubview:[photoFrameController view]];
	} else if (index < _currentPhotoIdx) {
		[_photoFrameControllers insertObject:photoFrameController atIndex:0];
		[_view insertSubview:[photoFrameController view] atIndex:0];
	}
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	NSInteger index = floor((_view.contentOffset.y - _view.frame.size.height/2) / _view.frame.size.height) + 1;
    
	if (index == _currentPhotoIdx) {
		return;
	}
    
    NSUInteger numberOfPhotos = [_cachedEntryPhotos count];

	if (index > _currentPhotoIdx) {
		if (_currentPhotoIdx < (numberOfPhotos - 1)) {
			_currentPhotoIdx++;
			if (_currentPhotoIdx < (numberOfPhotos - 1)) {
				if (([_photoFrameControllers count] < 3) || (_currentPhotoIdx > 1)) {
					[self _addPhotoFrameControllerAtIndex:_currentPhotoIdx + 1];
				}
				if ([_photoFrameControllers count] > 3) {
					[_photoFrameControllers removeObjectAtIndex:0];
				}
			}
		}
	} else if (index < _currentPhotoIdx) {
		if (_currentPhotoIdx > 0) {
			_currentPhotoIdx--;
			if (_currentPhotoIdx > 0) {
				if (([_photoFrameControllers count] < 3) || (((numberOfPhotos - 1) - _currentPhotoIdx) > 1)) {
					[self _addPhotoFrameControllerAtIndex:_currentPhotoIdx - 1];
				}
				if ([_photoFrameControllers count] > 3) {
					[_photoFrameControllers removeLastObject];
				}
			}
		}
	}
    
    [[[[PBAppDelegate sharedAppDelegate] navigationController] topViewController] setTitle: [self title]];
}


- (void)toggleStar {
    
    [[[PBAppDelegate sharedAppDelegate] googleReaderAccount] toggleEntryStarredTag:_entry];
}


- (void)saveCurrentPhotoToAlbums  {

    PBPhoto *photo = [[self _photoFrameControllerAtIndex:_currentPhotoIdx] photo];    
    
    UIImage *image = [UIImage imageWithContentsOfFile:[photo cacheURL]];
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    if (error) {
        BAErrorMessage(@"Failed to save photo to albums. Error <%@>", [error localizedDescription]);
    }
}


- (void)showOriginal  {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_entry URL]]];
}


- (UIView *)view {

	if (_view) {
		return _view;
	}

    CGRect frame = [[UIScreen mainScreen] bounds];

    _view = [[PBEntryPhotosView alloc] initWithFrame:frame];
    [_view setIteratorDelegate:self];
    [_view setDelegate:self];
    // for super layoutSubviews
    [_view setTag:_entryIdx];

    for (PBPhoto *photo in _cachedEntryPhotos) {
        if ([_photoFrameControllers count] == 0) {
            _currentPhotoIdx = 0;
            [self _addPhotoFrameControllerAtIndex:_currentPhotoIdx];
        } else {
            if ([_photoFrameControllers count] == 1) {
                [self _addPhotoFrameControllerAtIndex:_currentPhotoIdx + 1];
                break;
            }
        }
    }

	return _view;
}


- (NSString *)title {
    
    NSUInteger numberOfPhotos = [_cachedEntryPhotos count];
    
    if (numberOfPhotos == 1) {
        PBPhoto *photo = [_cachedEntryPhotos objectAtIndex:0];
        return [NSString stringWithFormat:@"%@", [photo title]];
    } else if (numberOfPhotos > 1) {
        PBPhoto *photo = [_cachedEntryPhotos objectAtIndex:_currentPhotoIdx];
        return [NSString stringWithFormat:@"%@ (%d of %d)", [photo title], _currentPhotoIdx + 1, numberOfPhotos];
    }

    return [NSString stringWithFormat:@"%@", [_entry title]];
}


- (NSString *)currentPhotoCacheURL {

    PBPhoto *currentPhoto = nil;
    if (_currentPhotoIdx != NSNotFound) {
        currentPhoto = [_cachedEntryPhotos objectAtIndex:_currentPhotoIdx];
    }
    
    return [currentPhoto cacheURL];
}


#pragma mark - PBEntryPhotosIteratorDelegate


- (NSUInteger)numberOfPhotos {    
    return [_cachedEntryPhotos count];
}


- (NSUInteger)currentEntryIndex {
    return _entryIdx;
}


- (NSUInteger)currentPhotoIndex {
    return _currentPhotoIdx;
}


@end
