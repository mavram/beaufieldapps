//
//  FeaturedPicturesGridController.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-07-07.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FeaturedPicturesGridController.h"
#import "FeaturedPicturesAppDelegate.h"
#import "FPWikipediaManager.h"
#import "NSErrorExtensions.h"


@implementation FeaturedPicturesGridController


static CGFloat __height = 110; // platform specific app delegates sets these values
static CGFloat __thumbnailInset = 10;
static CGFloat __thumbnailWidth = 118;


@synthesize gridView = _gridView;


#pragma mark - FPWikipediaManager notifications


- (void)didFetchPhoto:(NSNotification *)note {
    
    FPPhoto *photo = (FPPhoto *)[note object];
    NSDictionary *userInfo = [note userInfo];
    NSUInteger photoWidth = [(NSNumber*)[userInfo objectForKey:kDidFetchPhotoNotificationPhotoWidth] integerValue];
    
    // check if is thumbnail
    if (photoWidth != __thumbnailWidth) {
        return;
    }
    
    @synchronized(self) {
        [_missingThumbnails removeObject:photo];
    }
    
    if ([_missingThumbnails count] == 0) {
        [self reloadThumbnails];
        [_gridView setNeedsLayout];
        [_gridView layoutIfNeeded];
    }
}



#pragma mark - FeaturedPicturesGridDelegate


- (BOOL)isLoading {    
    return [_missingThumbnails count];
}


- (BOOL)isOffline {    
    return [FeaturedPicturesAppDelegate isOffline];
}


#pragma mark - Life cycle


- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }
    
    _missingThumbnails = [NSMutableArray new];
    
	return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_gridView release];
    [_missingThumbnails release];
    
    [super dealloc];
}


#pragma mark - Public interface


+ (CGFloat)height {
    return __height;
}


+ (void)setHeight:(CGFloat)height {
    __height = height;
}


+ (void)setThumbnailInset:(CGFloat)thumbnailInset {
    __thumbnailInset = thumbnailInset;
}


+ (void)setThumbnailWidth:(CGFloat)thumbnailWidth {
    __thumbnailWidth = thumbnailWidth;
}



- (FPPhoto *)thumbnailAtIndex:(NSUInteger)idx {
    
    FPPhoto *photo = [[[FeaturedPicturesAppDelegate featuredPicturesController] photos] objectAtIndex:idx];
    if (![photo hasCachedImageWithWidth:__thumbnailWidth]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFetchPhoto:)
                                                     name:kDidFetchPhotoNotification
                                                   object:photo];
        [[FPWikipediaManager sharedWikipediaManager] fetchPhoto:photo photoWidth:__thumbnailWidth];
    }
    
    return photo;
}


- (void)handleTapFromThumbnail:(UITapGestureRecognizer *)recognizer {
    
    UIView *thumbnailView = [recognizer view];
    [[FeaturedPicturesAppDelegate featuredPicturesController] moveToPhotoAtIndex:[thumbnailView tag] - 1];
}


- (FeaturedPicturesGridView *)viewWithFrame:(CGRect)frame {
    
    if (_gridView) {
        return _gridView;
    }
    
    _gridView = [[FeaturedPicturesGridView alloc] initWithFrame:frame];
    
    [_gridView setGridDelegate:self];
    [_gridView setThumbnailInset:__thumbnailInset];
    [_gridView setThumbnailWidth:__thumbnailWidth];
    
    return _gridView;
}


- (void)reloadThumbnails {
    
    NSArray *subviews = [[_gridView scrollView] subviews];
    for (UIView *v in subviews) {
        [v removeFromSuperview];
    }
    
    [[_gridView scrollView] setContentOffset:CGPointZero];
    [[_gridView scrollView] setContentSize:CGSizeZero];

    NSArray * thumbnails = [[FeaturedPicturesAppDelegate featuredPicturesController] photos];

    for (FPPhoto *t in thumbnails) {
        if (![t hasCachedImageWithWidth:__thumbnailWidth]) {
            [_missingThumbnails addObject:t];
        }
    }
    
    if ([_missingThumbnails count]) {
        @synchronized(self) {
            for (FPPhoto *t in _missingThumbnails) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(didFetchPhoto:)
                                                             name:kDidFetchPhotoNotification
                                                           object:t];
                [[FPWikipediaManager sharedWikipediaManager] fetchPhoto:t photoWidth:__thumbnailWidth];
            }
        }
    } else {
        int index = 0;
        for (FPPhoto *t in thumbnails) {
            UIImage *image = [t cachedImageWithWidth:[_gridView thumbnailWidth]];
            UIImageView *thumbnailView = [[[UIImageView alloc] initWithImage:image] autorelease];
            [thumbnailView setUserInteractionEnabled:YES];
            [thumbnailView setTag:index + 1];
            UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(handleTapFromThumbnail:)] autorelease];
            [thumbnailView addGestureRecognizer:tgr];
            [[_gridView scrollView] addSubview:thumbnailView];

            index = index + 1;
        }
    }
}


@end
