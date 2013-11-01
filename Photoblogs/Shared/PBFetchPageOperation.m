//
//  PBFetchPageOperation.m
//  Photoblogs
//
//  Created by mircea on 10-08-11.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//


#import "PBAppDelegate.h"
#import "PBFetchPageOperation.h"
#import "NSErrorExtensions.h"
#import "PBPhotoManager.h"


static NSUInteger kOperationTimeout = 120;


@implementation PBFetchPageOperation


@synthesize entry = _entry;
@synthesize delegate = _delegate;


- (id)initWithEntry:(PBEntry *)entry service:(GDataServiceBase *)service {

    if (!(self = [super init])) {
        return self;
    }

	_entry = [entry retain];
    _service = [service retain];
    
    return self;
}

- (void) dealloc {

    [_entry release];
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

    [_service fetchDataWithURL:[NSURL URLWithString:[_entry URL]]
                    dataToPost:nil
                      delegate:self
             didFinishSelector:@selector(finishedFetchingContent:error:)];
    
    while (_isFetching && ![self isCancelled]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[[NSDate date] dateByAddingTimeInterval:kOperationTimeout]];
        
        // check timeout
        if (CFAbsoluteTimeGetCurrent() - _elapsedTime > kOperationTimeout) {
#ifdef __DEBUG_EXECUTION_TIME__
            didTimeout = YES;
#endif
            BAInfoMessage(@"Did timeout operation for <%@> after <%f>", [_entry URL], CFAbsoluteTimeGetCurrent() - _elapsedTime);
            break;
        }
    }
	
    [PBAppDelegate stopNetworkIndicator];
    
    _isFetching = NO;
    
#ifdef __DEBUG_EXECUTION_TIME__
    if (!didTimeout && (CFAbsoluteTimeGetCurrent() - _elapsedTime > 60)) {
        BAInfoMessage(@"Did fetch content for <%@> in <%f>", [_entry URL], CFAbsoluteTimeGetCurrent() - _elapsedTime);
    }
#endif
}

- (void)finishedFetchingContent:(NSData *)data error:(NSError *)error {
    
	// signal the operation that we are done
    _isFetching = NO;

    NSObject *delegateAsObject = (NSObject *)_delegate;
    // network errors?
    if (error) {
        [delegateAsObject performSelectorOnMainThread:@selector(didFailToFetchPage:)
                                           withObject:_entry
                                        waitUntilDone:NO];
        return;
    }
    
    NSString *content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    // TODO: add implementation
    NSArray *photos = [PBPhotoManager parsePhotos:content];
    for (NSString *photo in photos) {
        BADebugMessage(@"%@", photo);
    }

    [delegateAsObject performSelectorOnMainThread:@selector(didFetchPage:)
                                       withObject:_entry
                                    waitUntilDone:NO];
}


@end
