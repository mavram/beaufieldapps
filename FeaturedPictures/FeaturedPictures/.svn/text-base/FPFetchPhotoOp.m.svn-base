//
//  FPFetchPhotoOp.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-05.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FPFetchPhotoOp.h"
#import "NSErrorExtensions.h"
#import "NSDataExtensions.h"


@implementation FPFetchPhotoOp



@synthesize forceFullResolution = _forceFullResolution;
@synthesize photoWidth = _photoWidth;
@synthesize delegate = _delegate;
@synthesize photo = _photo;


- (id)initWithPhoto:(FPPhoto *)photo photoWidth:(NSUInteger)photoWidth forceFullResolution:(BOOL)forceFullResolution {
    
    if (forceFullResolution) {
        if ((self = [super initWithURL:[NSURL URLWithString:[photo fullResolutionPhotoURL]]]) == nil) {
            return self;
        }        
    } else {        
        if ((self = [super initWithURL:[NSURL URLWithString:[photo thumbGeneratorURLWithWidth:photoWidth]]]) == nil) {
            return self;
        }
    }
    
    [self setPhoto:photo];
    [self setPhotoWidth:photoWidth];
    [self setForceFullResolution:forceFullResolution];

    return self;
}


- (void)dealloc {
    
    [self setPhoto:nil];
    
    [super dealloc];
}


- (void)_delegateCallback:(NSNumber *)didFail {

    if ([didFail boolValue]) {
        [_delegate didFailToFetchPhoto:_photo withWidth:_photoWidth forceFullResolution:_forceFullResolution]; 
    } else {
        [_delegate didFetchPhoto:_photo withWidth:_photoWidth];
    }
}


- (void)finishedWithData:(NSData *)data {

    // save data
    NSString *cacheURL = [_photo cacheURLWithWidth:_photoWidth];
    [data writeToFileEx:cacheURL];

    // inform delegate
    [self performSelectorOnMainThread:@selector(_delegateCallback:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
}


- (void)failedWithError:(NSError *)error {
    
    NSString* errorMessage = [NSString stringWithFormat:@"Failed to fetch photo <%@> with thumb URL <%@>.",
                                    [_photo photoPageURL],
                                    [_photo thumbGeneratorURLWithWidth:_photoWidth]];
    [error printErrorToConsoleWithMessage:errorMessage];
    
    // nothing was fetched
    [self performSelectorOnMainThread:@selector(_delegateCallback:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
}


@end
