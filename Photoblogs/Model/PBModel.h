//
//  PBModel.h
//  Photoblogs
//
//  Created by Mircea Avram on 10-12-06.
//  Copyright 2010 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBAppSettings.h"
#import "PBSubscription.h"
#import "FMDatabase.h"


#define __VALIDATE_DB_STATUS__                                                          \
    if ([db hadError]) {                                                                \
        BAErrorMessage(@"db_error<%d:%@>", [db lastErrorCode], [db lastErrorMessage]);  \
        if ([db inTransaction]) {                                                       \
            [db rollback];                                                              \
        }                                                                               \
        [[PBModel sharedModel] releaseDB];                                              \
        return NO;                                                                      \
    }                                                                                   \


#define __BEGIN_DB_TRANSACTION__                        \
    BOOL didStartTransaction = NO;                      \
    if (![db inTransaction]) {                          \
        didStartTransaction = [db beginTransaction];    \
    }                                                   \


#define __COMMIT_DB_TRANSACTION__   \
    if (didStartTransaction) {      \
        [db commit];                \
    }                               \


@interface PBModel : NSObject {
    
@private
    FMDatabase *_db;
    NSUInteger *_dbCounter;

}


@property (nonatomic, retain) NSURL *coreDataURL; // defaults to nil for unit testing
@property (nonatomic, retain) NSURL *sqliteURL;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain, readonly) PBAppSettings *appSettings;
@property (nonatomic, retain, readonly) NSArray *subscriptions;


+ (PBModel*)sharedModel;

- (FMDatabase *)DB;
- (void)releaseDB;

- (BOOL)initSqliteStore;
- (BOOL)resetSqliteStore;
- (BOOL)resetCoreDataStore;

- (BOOL)saveContext;

- (PBSubscription *)addSubscriptionWithGoogleReaderSubscription:(GDataReaderSubscription *)googleReaderSubscription;
- (BOOL)removeSubscription:(PBSubscription *)subscription;


@end
