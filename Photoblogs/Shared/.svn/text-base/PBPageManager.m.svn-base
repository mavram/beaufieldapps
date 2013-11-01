//
//  PBPageManager.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-25.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBPageManager.h"
#import "NSErrorExtensions.h"
#import "PBAppDelegate.h"
#import "PBFetchPageOperation.h"


NSString *kDidFetchPageNotification = @"kDidFetchPageNotification";


static PBPageManager *__sharedPageManager = nil;


@implementation PBPageManager


@synthesize baseService = _baseService;
@synthesize baseServiceQueue = _baseServiceQueue;


+ (PBPageManager *)sharedPageManager {
    if (__sharedPageManager) {
        return __sharedPageManager;
    }
        
    __sharedPageManager = [[PBPageManager alloc] init];
    
    return __sharedPageManager;
}


- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }
    
    _pagesInProgress = [[NSMutableDictionary alloc] init];

    // content fetcher
	_baseService = [[GDataServiceBase alloc] init];
    _baseServiceQueue = [[NSOperationQueue alloc] init];
    [_baseServiceQueue setMaxConcurrentOperationCount:7];
        
    return self;
}


- (void)dealloc {
    
    [_pagesInProgress release];
    
    [_baseServiceQueue release];
    [_baseService release];
    
    [super dealloc];
}


- (BOOL)fetchPageWithEntry:(PBEntry *)entry {
    
    // check if we are not fetching or have it cached already
    if ([self isFetchingPage:entry]) {
        return NO;
    }
    
    // create operation and add to queue
    PBFetchPageOperation *fetchPageOp = [[PBFetchPageOperation alloc] initWithEntry:entry service:_baseService];
    [fetchPageOp setDelegate:self];
    [_baseServiceQueue addOperation:fetchPageOp];
    [fetchPageOp release];

    @synchronized(self) {
        [_pagesInProgress setObject:entry forKey:[entry identifier]];
    }
    
    return YES;
}


- (BOOL)isFetchingPage:(PBEntry *)entry {

    @synchronized(self) {
        return ([_pagesInProgress objectForKey:[entry identifier]] != nil);
    }
}


- (void)didFetchPage:(PBEntry *)entry {

    @synchronized(self) {
        [_pagesInProgress removeObjectForKey:[entry identifier]];
    }
    
    // TODO: add implementation
    
    NSNotification *note = [NSNotification notificationWithName:kDidFetchPageNotification
                                                         object:entry
                                                       userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];
}
    

- (void)didFailToFetchPage:(PBEntry *)entry {
    
    @synchronized(self) {
        [_pagesInProgress removeObjectForKey:[entry identifier]];
    }
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Did fail to fetch content for <%@> with <%d> queued", [entry URL], [[_pagesInProgress allKeys] count]);
#endif
    
    NSNotification *note = [NSNotification notificationWithName:kDidFetchPageNotification
                                                         object:entry
                                                       userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];
}


@end
