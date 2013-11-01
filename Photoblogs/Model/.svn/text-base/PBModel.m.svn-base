//
//  PBModel.m
//  Photoblogs
//
//  Created by Mircea Avram on 10-12-06.
//  Copyright 2010 Beaufield Atelier. All rights reserved.
//


#import "NSErrorExtensions.h"
#import "PBModel.h"
#import "PBEntry.h"
#import "PBPhoto.h"
#import "PBPhotoManager.h"


@implementation PBModel


static PBModel *__sharedModel = nil;


@synthesize coreDataURL = _coreDataURL;
@synthesize sqliteURL = _sqliteURL;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize appSettings = _appSettings;


+ (PBModel *)sharedModel {
    if (__sharedModel != nil) {
        return __sharedModel;
    }
    
    __sharedModel = [[PBModel alloc] init];
    
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
    [db beginTransaction];
    if (![PBEntry createSchemaSQL:db]) {
        __VALIDATE_DB_STATUS__
    }
    if (![PBPhoto createSchemaSQL:db]) {
        __VALIDATE_DB_STATUS__
    }
    if (![PBPhotoManager createSchemaSQL:db]) {
        __VALIDATE_DB_STATUS__
    }
    [db commit];
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


- (BOOL)resetCoreDataStore {
    
	NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    
    // check if we have a store
    if (![fileManager fileExistsAtPath:[_coreDataURL path]]) {
        return YES;
    }

	NSError *error = nil;

    // delete CoreData file
	if ([fileManager removeItemAtURL:_coreDataURL error:&error] == NO) {
        [error printErrorToConsoleWithMessage:@"Failed to remove CoreData store."];
		return NO;
	}

    return YES;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
	
	if (_coreDataURL) { //application mode
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhotoBlogsReader" withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
	} else { // unit tests
		NSArray	*arrayOfBundles = [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]];
		_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:arrayOfBundles];
	}
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSString *storeType = NSSQLiteStoreType;
	if (!_coreDataURL) {// unit tests
		storeType = NSInMemoryStoreType;
	}

	if (![_persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:_coreDataURL options:nil error:&error]) {
		[error printErrorToConsoleWithMessage:[NSString stringWithFormat:@"Failed to initialize CoreData."]];
	}

    return _persistentStoreCoordinator;
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
    
    [_coreDataURL release];
    [_sqliteURL release];
    
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];

	[_appSettings release];

	[super dealloc];
}


- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }

    _coreDataURL = nil;
    _sqliteURL = nil;
    _appSettings = nil;
    
    _db = nil;
    _dbCounter = 0;

    return self;
}


- (BOOL)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			[error printErrorToConsoleWithMessage:[NSString stringWithFormat:@"Failed to save the object context."]];
			return NO;
        } 
    }
	
	return YES;
}


- (PBAppSettings *)appSettings {
    if (_appSettings) {
        return _appSettings;
    }
    
    // Get app settings
	NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppSettings" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
    
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if (error) {
		[error printErrorToConsoleWithMessage:@"Failed to fetch application settings."];
		return _appSettings;
	} else {
        // If no app settings create them
		if ([fetchResults count] == 0) {
			_appSettings = (PBAppSettings*)[[NSEntityDescription insertNewObjectForEntityForName:@"AppSettings"
                                                                          inManagedObjectContext:[self managedObjectContext]] retain];

            [_appSettings setSynchronizeTimeInterval:[NSNumber numberWithInteger:300]];
            
			[self saveContext];
		} else {
			_appSettings = [[fetchResults objectAtIndex:0] retain];
		}
	}
    
    return _appSettings;
}


- (NSArray *)subscriptions {

    NSMutableArray * subscriptions = [[NSMutableArray new] autorelease];

    // fetch from db
	NSManagedObjectContext *managedObjectContext = [[PBModel sharedModel] managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
	if (error) {
        // return no subscriptions
		[error printErrorToConsoleWithMessage:@"Failed to fetch subscriptions."];
		return subscriptions;
	}
    
    if ([fetchResults count] == 0) {
        // create first meta subscriptions
        [subscriptions addObject:[PBSubscription subscriptionWithMetaType:PBMetaSubscriptionTypeNewPhotos]];
        [subscriptions addObject:[PBSubscription subscriptionWithMetaType:PBMetaSubscriptionTypeStarredPhotos]];
        [subscriptions addObject:[PBSubscription subscriptionWithMetaType:PBMetaSubscriptionTypeSubscriptionsEditor]];
        [self saveContext];
    } else {
        [subscriptions addObjectsFromArray:fetchResults];
    }

    // sort by metaType so that we have new/starred first and the editor last
	NSSortDescriptor *sortDateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"metaType" ascending:YES] autorelease];
	NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDateDescriptor, nil] autorelease];
    return [subscriptions sortedArrayUsingDescriptors:sortDescriptors];
}


- (PBSubscription *)addSubscriptionWithGoogleReaderSubscription:(GDataReaderSubscription *)googleReaderSubscription {

    // create subscription
    PBSubscription *subscription = [PBSubscription subscriptionWithGoogleReaderSubscription:googleReaderSubscription];

    // persist to db
    if ([self saveContext]) {
        return subscription;
    }
    
    BAErrorMessage(@"Failed to add subscription <%@>", [subscription title]);

    return nil;
}


- (BOOL)removeSubscription:(PBSubscription *)subscription {
    
    [[self managedObjectContext] deleteObject:subscription];
    // persist to db
    if ([self saveContext]) {
        return YES;
    }
    
    BAErrorMessage(@"Failed to remove subscription <%@>", [subscription title]);
    
    return NO;
}


@end
