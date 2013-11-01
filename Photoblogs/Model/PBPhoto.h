//
//  PBPhoto.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-24.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface PBPhoto : NSObject {
    
}


@property (nonatomic, retain, readonly) NSString *URL;
@property (nonatomic, retain, readonly) NSString *title;
@property (nonatomic, retain) NSString *cacheURL;
@property (nonatomic, retain, readonly) NSString *entryIdentifier;


+ (BOOL)createSchemaSQL:(FMDatabase *)db;

+ (PBPhoto *)photoWithURL:(NSString *)URL;
+ (NSArray *)photosWithEntry:(NSString *)entryIdentifier;
+ (NSArray *)cachedPhotosWithSubscription:(NSString *)subscriptionIdentifier;
+ (BOOL)addPhoto:(NSString *)URL title:(NSString *)title withEntry:(NSString *)entryIdentifier;
+ (BOOL)deletePhoto:(NSString *)URL;
+ (BOOL)deleteAllPhotosWithEntry:(NSString *)entryIdentifier;

- (id)initWithResultSetRow:(FMResultSet *)rs;

- (void)setCacheURL:(NSString *)cacheURL;

@end
