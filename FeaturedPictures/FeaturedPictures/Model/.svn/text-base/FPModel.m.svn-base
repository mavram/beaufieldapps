//
//  FPModel.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-04.
//  Copyright 2010 Beaufield Atelier. All rights reserved.
//


#import "NSErrorExtensions.h"
#import "FPModel.h"
#import "FPPhoto.h"


@implementation FPModel


static FPModel *__sharedModel = nil;


@synthesize sqliteURL = _sqliteURL;


+ (FPModel *)sharedModel {
    if (__sharedModel != nil) {
        return __sharedModel;
    }
    
    __sharedModel = [[FPModel alloc] init];
    
	return __sharedModel;
}


- (BOOL)initSqliteStore {
    
    // check if sqlite store exists
    BOOL needsToCreateSchema = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:[_sqliteURL path]]) {
        needsToCreateSchema = YES;
    }
    [fileManager release];
    
    // check if we are done
    if (!needsToCreateSchema) {
        return YES;
    }
    
    // open db
    FMDatabase *db = [self DB];
    if (db == nil) {
        return NO;
    }
    
    // create db schema
    if ([db beginTransaction]) {
        if (![FPPhoto createSchemaSQL:db]) {
            if ([db hadError]) {
                BAErrorMessage(@"db_error<%d:%@>", [db lastErrorCode], [db lastErrorMessage]);
                if ([db inTransaction]) {
                    [db rollback];
                }
                [self releaseDB];
                return NO;
            }
        }
        [db commit];
    } else {
        BAErrorMessage(@"db_error<%d:%@>", [db lastErrorCode], [db lastErrorMessage]);
        [self releaseDB];
        return NO;
    }
    
    [self releaseDB];

    return YES;
}


- (BOOL)resetSqliteStore {

	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    
    // check if we have a store
    if (![fileManager fileExistsAtPath:[_sqliteURL path]]) {
        return YES;
    }
    
	NSError *error = nil;
    // delete sqlite file
	if ([fileManager removeItemAtURL:_sqliteURL error:&error] == NO) {
        [error printErrorToConsoleWithMessage:@"Failed to remove sqlite store."];
		return NO;
	}
    
    return YES;
}


- (FMDatabase *)DB {
    
    if (_db) {
        _dbCounter++;
        return _db;
    }

    // open db
    _db = [[FMDatabase databaseWithPath:[_sqliteURL path]] retain];
    if (![_db open]) {
        BAErrorMessage(@"db_error<%d:%@>", [_db lastErrorCode], [_db lastErrorMessage]);
        return nil;
    }
    
    // increase counter
    _dbCounter++;
    
    // set db options
    [_db setShouldCacheStatements:YES];

    return _db;
}


- (void)releaseDB {
    
    _dbCounter--;
    if (_dbCounter > 0) {
        return;
    }
    
    [_db close];
    [_db release];
    _db = nil;
}


- (void)dealloc {
    
    [_sqliteURL release];

	[super dealloc];
}


- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }

    _sqliteURL = nil;
    
    _db = nil;
    _dbCounter = 0;

    return self;
}


@end
