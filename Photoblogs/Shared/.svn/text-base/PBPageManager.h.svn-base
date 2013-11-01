//
//  PBPageManager.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-25.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBEntry.h"
#import "GDataServiceBase.h"
#import "PBFetchPageOperation.h"


extern NSString *kDidFetchPageNotification;


@interface PBPageManager : NSObject<PBFetchPageOperationDelegate> {

@private
    NSMutableDictionary *_pagesInProgress;
}


@property (nonatomic, retain, readonly) GDataServiceBase *baseService;
@property (nonatomic, retain, readonly) NSOperationQueue *baseServiceQueue;


+ (PBPageManager *)sharedPageManager;

- (BOOL)fetchPageWithEntry:(PBEntry *)entry;
- (BOOL)isFetchingPage:(PBEntry *)entry;

@end
