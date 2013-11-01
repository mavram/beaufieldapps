//
//  PBPhotoManager.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-25.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBPhoto.h"
#import "PBEntry.h"
#import "FMDatabase.h"
#import "GDataServiceBase.h"
#import "PBFetchPhotoOperation.h"
#import "PBSubscription.h"



extern NSString *kDidFetchPhotoNotification;



@interface PBPhotoManager : NSObject<PBFetchPhotoOperationDelegate> {

@private
    NSMutableDictionary *_photosInProgress;
    NSMutableDictionary *_entriesInProgress;
}


@property (nonatomic, retain, readonly) GDataServiceBase *baseService;
@property (nonatomic, retain, readonly) NSOperationQueue *baseServiceQueue;


+ (PBPhotoManager *)sharedPhotoManager;
+ (BOOL)createSchemaSQL:(FMDatabase *)db;
+ (NSMutableArray *)parsePhotos:(NSString *)html;

- (BOOL)isDiscardablePhoto:(NSString *)URL;

- (BOOL)isFetchingPhoto:(PBPhoto *)photo;
- (BOOL)fetchPhoto:(PBPhoto *)photo withEntry:(PBEntry *)entry;
- (BOOL)isFetchingEntry:(PBEntry *)entry;
- (void)fetchPhotosWithEntry:(PBEntry *)entry;


- (void)dumpPhotosInProgress;


@end
