//
//  PBFetchPageOperation.h
//  Photoblogs
//
//  Created by mircea on 10-08-11.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDataServiceBase.h"
#import "PBEntry.h"


@protocol PBFetchPageOperationDelegate <NSObject>

- (void)didFetchPage:(PBEntry *)entry;
- (void)didFailToFetchPage:(PBEntry *)entry;

@end


@interface PBFetchPageOperation : NSOperation {

@private
    CFAbsoluteTime _elapsedTime;
    GDataServiceBase *_service;
	BOOL _isFetching;
}


@property(nonatomic, retain, readonly) PBEntry *entry;
@property(nonatomic, assign) id<PBFetchPageOperationDelegate> delegate;


- (id)initWithEntry:(PBEntry *)entry service:(GDataServiceBase *)service;

@end



