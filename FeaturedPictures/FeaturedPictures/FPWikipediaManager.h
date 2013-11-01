//
//  FPWikipediaManager.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-05.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FPParsePhotosOp.h"
#import "FPFetchPhotoOp.h"


extern NSString *kDidParsePhotosNotification;
extern NSString *kDidFetchPhotoNotification;
extern NSString *kDidFetchPhotoNotificationPhotoWidth;


@interface FPWikipediaManager : NSObject<FPParsePhotosOpDelegate, FPFetchPhotoOpDelegate> {

@private
    NSMutableDictionary *_photosInProgress;
}


@property (nonatomic, retain, readonly) NSOperationQueue *operationsQueue;
@property (nonatomic, assign, readonly) BOOL isParsingPhotos;


+ (FPWikipediaManager *)sharedWikipediaManager;


- (void)parseCurrentPhotos;
- (void)parsePhotosWithYear:(NSUInteger)year month:(NSUInteger)month;

- (void)fetchPhoto:(FPPhoto *)photo photoWidth:(NSUInteger)photoWidth; // NSUIntegerMax returns full resolution photo

- (BOOL)isFetchingPhoto:(FPPhoto *)photo width:(NSUInteger)photoWidth;

- (void)dumpWikipedia;

@end
