//
//  PBFetchPhotoOperation.h
//  Photoblogs
//
//  Created by mircea on 10-08-11.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDataServiceBase.h"
#import "PBPhoto.h"


@interface PBFetchPhotoOperationResult : NSObject {
}

@property(nonatomic, retain) PBPhoto *photo;
@property(nonatomic, retain) NSString *cacheURL;

- (id)initWithPhoto:(PBPhoto *)photo cacheURL:(NSString *)cacheURL;

@end


@protocol PBFetchPhotoOperationDelegate <NSObject>

- (void)didFetchPhoto:(PBFetchPhotoOperationResult *)result;
- (void)didDiscardPhoto:(PBPhoto *)photo;
- (void)didFailToFetchPhoto:(PBPhoto *)photo;

@end


@interface PBFetchPhotoOperation : NSOperation {

@private
    CFAbsoluteTime _elapsedTime;
    GDataServiceBase *_service;
	BOOL _isFetching;
}

@property(nonatomic, retain, readonly) PBPhoto *photo;
@property(nonatomic, retain, readonly) NSString *cacheURL;
@property(nonatomic, assign) id<PBFetchPhotoOperationDelegate> delegate;

- (id)initWithPhoto:(PBPhoto *)photo cacheURL:(NSString *)cacheURL service:(GDataServiceBase *)service;;

@end



