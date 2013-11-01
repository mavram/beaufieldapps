//
//  PBFetchPhotoOperation.m
//  Photoblogs
//
//  Created by mircea on 10-08-11.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//


#import "PBAppDelegate.h"
#import "PBFetchPhotoOperation.h"
#import "NSErrorExtensions.h"
#import "NSDataExtensions.h"
#import "UIImageExtensions.h"
#import "PBGridViewThumb.h"


static NSUInteger kOperationTimeout = 120;
static NSUInteger kMinimumPhotoSize = 3*1024;
static NSUInteger kNoThumbMaxPhotoSize = 50*1024;


@implementation PBFetchPhotoOperationResult

@synthesize photo = _photo;
@synthesize cacheURL = _cacheURL;


- (id)initWithPhoto:(PBPhoto *)photo cacheURL:(NSString *)cacheURL {
    
    self = [super init];
    if (self) {
        [self setPhoto:photo];
        [self setCacheURL:cacheURL];
    }
    
    return self;
}

- (void)dealloc {
    
    [_photo release];
    [_cacheURL release];
    
    [super dealloc];
}

@end



@implementation PBFetchPhotoOperation


@synthesize photo = _photo;
@synthesize cacheURL = _cacheURL;
@synthesize delegate = _delegate;


- (id)initWithPhoto:(PBPhoto *)photo cacheURL:(NSString *)cacheURL service:(GDataServiceBase *)service {

    if (!(self = [super init])) {
        return self;
    }

	_photo = [photo retain];
    _cacheURL = [cacheURL retain];
    _service = [service retain];
    
    return self;
}

- (void) dealloc {

	[_photo release];
    [_cacheURL release];
    [_service release];

    [super dealloc];
}

- (void)main {

    if (_isFetching) {
        return;
    }

	_isFetching = YES;
    _elapsedTime = CFAbsoluteTimeGetCurrent();
    
#ifdef __DEBUG_EXECUTION_TIME__
    BOOL didTimeout = NO;
#endif
    
    [PBAppDelegate startNetworkIndicator];

    [_service fetchDataWithURL:[NSURL URLWithString:[_photo URL]]
                    dataToPost:nil
                      delegate:self
             didFinishSelector:@selector(finishedFetchingPhoto:error:)];
    
    while (_isFetching && ![self isCancelled]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[[NSDate date] dateByAddingTimeInterval:kOperationTimeout]];
        
        // check timeout
        if (CFAbsoluteTimeGetCurrent() - _elapsedTime > kOperationTimeout) {
#ifdef __DEBUG_EXECUTION_TIME__
            didTimeout = YES;
#endif
            BAInfoMessage(@"Did timeout operation for <%@> after <%f>", [_photo URL], CFAbsoluteTimeGetCurrent() - _elapsedTime);
            break;
        }
    }
	
    [PBAppDelegate stopNetworkIndicator];
    
    _isFetching = NO;
        
#ifdef __DEBUG_EXECUTION_TIME__
    if (!didTimeout && (CFAbsoluteTimeGetCurrent() - _elapsedTime > 60)) {
        BAInfoMessage(@"Did fetch photo for <%@> in <%f>", [_photo URL], CFAbsoluteTimeGetCurrent() - _elapsedTime);
    }
#endif
}

- (void)finishedFetchingPhoto:(NSData *)data error:(NSError *)error {

	// signal the operation that we are done
    _isFetching = NO;

    NSObject *delegateAsObject = (NSObject *)_delegate;
    // network errors?
    if (error) {
        [delegateAsObject performSelectorOnMainThread:@selector(didFailToFetchPhoto:)
                                           withObject:_photo
                                        waitUntilDone:NO];
        return;
    }

    // check if discardable
    if([data length] < kMinimumPhotoSize) {
        [delegateAsObject performSelectorOnMainThread:@selector(didDiscardPhoto:)
                                           withObject:_photo
                                        waitUntilDone:NO];
        return;
    }

    // try to save
    if (![data writeToFileEx:_cacheURL]) {
        [delegateAsObject performSelectorOnMainThread:@selector(didFailToFetchPhoto:)
                                           withObject:_photo
                                        waitUntilDone:NO];
        return;
    }
    
    // generate a thumb if photo to big
    if ([data length] > kNoThumbMaxPhotoSize) {
        UIImage *thumbImage = [[UIImage imageWithData:data] imageScaledToWidth:[PBGridViewThumb thumbWidth]];
        // save to cache
        if (thumbImage) {
            [UIImageJPEGRepresentation(thumbImage, 0.7) writeToFileEx:[PBGridViewThumb thumbURLWithCacheURL:_cacheURL]];
        }
    }

    PBFetchPhotoOperationResult *result = [[[PBFetchPhotoOperationResult alloc] initWithPhoto:_photo cacheURL:_cacheURL] autorelease];
    [delegateAsObject performSelectorOnMainThread:@selector(didFetchPhoto:)
                                       withObject:result
                                    waitUntilDone:NO];
}


@end
