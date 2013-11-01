//
//  PBPhotoGridViewThumb.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBPhotoGridViewThumb.h"
#import "PBEntry.h"
#import "PBPhoto.h"
#import "NSErrorExtensions.h"
#import "PBPhotoManager.h"
#import "PBGridView.h"


NSString *kDidFetchThumbPhotoNotification = @"kDidFetchThumbPhotoNotification";


@implementation PBPhotoGridViewThumb 


@synthesize parent = _parent;
@synthesize entry = _entry;


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_entry release];
    
    [super dealloc];
}


- (id)initWithEntry:(PBEntry *)entry parent:(NSObject *)parent {

    // fetch thumbs and set one thumb if available
    NSString *imageCacheURL = nil;
    
    PBPhoto *thumbPhoto = [entry thumbPhoto];
    if (thumbPhoto) {
        imageCacheURL = [thumbPhoto cacheURL];
    } else {
        // is fetching already or we'll start fetching now
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFetchPhoto:)
                                                     name:kDidFetchPhotoNotification
                                                   object:nil];
        [[PBPhotoManager sharedPhotoManager] fetchPhotosWithEntry:entry];
    }
    
    if (![super initWithImageCacheURL:imageCacheURL
                                title:imageCacheURL ? nil:[entry title]
                             subtitle:nil
                        defaultHeight:[PBGridViewThumb thumbWidth]/2]) {
        return self;
    }
    
    [self setEntry:entry];
    [self setParent:parent];
    
	
    return self;   
}



#pragma mark - PhotoManager notifications


- (void)didFetchPhoto:(NSNotification*)note {

    PBPhoto *photo = (PBPhoto *)[note object];
    
    // check if is our entry
    if (![[photo entryIdentifier] isEqualToString:[_entry identifier]]) {
        return;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [[self activityIndicatorView] stopAnimating];

    [self setImageCacheURL:[photo cacheURL]];
    if ([self imageCacheURL]) {
        [self setTitle:nil];
        NSNotification *newNote = [NSNotification notificationWithName:kDidFetchThumbPhotoNotification
                                                                object:_parent
                                                              userInfo:nil];
        [[NSNotificationQueue defaultQueue] enqueueNotification:newNote
                                                   postingStyle:NSPostWhenIdle
                                                   coalesceMask:NSNotificationCoalescingOnSender
                                                       forModes:nil];
    }
}


#pragma mark - Overrides


- (BOOL)isBusy {

    return [[PBPhotoManager sharedPhotoManager] isFetchingEntry:_entry];
}


@end
