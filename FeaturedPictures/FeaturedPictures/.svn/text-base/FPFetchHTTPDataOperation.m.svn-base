//
//  FPFetchHTTPDataOperation.m
//  FeaturedPictures
//
//  Created by mircea on 10-08-11.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//


#import "FeaturedPicturesAppDelegate.h"
#import "NSErrorExtensions.h"
#import "FPFetchHTTPDataOperation.h"


static NSUInteger kOperationTimeout = 60;

NSString *kDidDetectNetworkFailureNotification = @"kDidDetectNetworkFailureNotification";


@implementation FPFetchHTTPDataOperation



- (void)finishedWithData:(NSData *)data {

    // these are overrides
#ifndef NS_BLOCK_ASSERTIONS 
    NSAssert(NO, @"%@ is an abstract method. Override it.", _cmd);
#endif
}

- (void)failedWithError:(NSError *)error {
    
    // these are overrides
#ifndef NS_BLOCK_ASSERTIONS 
    NSAssert(NO, @"%@ is an abstract method. Override it.", _cmd);
#endif
}


- (id)initWithURL:(NSURL *)url {

    if (!(self = [super init])) {
        return self;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _httpFetcher = [[GTMHTTPFetcher fetcherWithRequest:request] retain];
    [_httpFetcher setRetryEnabled:YES];
    
    return self;
}


- (void) dealloc {

    [_httpFetcher release];
    [super dealloc];
}


- (void)fetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error{
	
    [FeaturedPicturesAppDelegate stopNetworkIndicator];
    
    if (error) {
        // notify observers about network failure
        NSNotification *note = [NSNotification notificationWithName:kDidDetectNetworkFailureNotification
                                                             object:error
                                                           userInfo:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:note waitUntilDone:NO];

        [self failedWithError:error];
    } else {    
        [self finishedWithData:data];
    }

	// signal the operation that we are done
    _isFetching = NO;
}


- (void)main {

    if (_isFetching) {
        return;
    }

	_isFetching = YES;
    
    [FeaturedPicturesAppDelegate startNetworkIndicator];
    
    [_httpFetcher beginFetchWithDelegate:self
                       didFinishSelector:@selector(fetcher:finishedWithData:error:)];
    
    while (_isFetching && ![self isCancelled]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[[NSDate date] dateByAddingTimeInterval:kOperationTimeout]];
    }
}


@end
