//
//  PBPhoto.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-24.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "NSErrorExtensions.h"
#import "PBModel.h"
#import "PBPhoto.h"
#import "PBFetchPhotoOperation.h"


@interface PBPhoto (__Internal__)

// nothing

@end


@implementation PBPhoto


@synthesize URL = _URL;
@synthesize title = _title;
@synthesize cacheURL = _cacheURL;
@synthesize entryIdentifier = _entryIdentifier;


- (void)dealloc {
    
    [_title release];
    [_URL release];
    [_cacheURL release];
    [_entryIdentifier release];
    
    [super dealloc];
}


+ (BOOL)createSchemaSQL:(FMDatabase *)db {
    
    if (![db executeUpdate:@"create table Photo ("
          "URL text primary key,"
          "entryIdentifier text,"
          "cacheURL text,"
          "title text"
          ")"]) {
        return NO;
    }
    if (![db executeUpdate:@"create index PhotoURLIdx on Photo(\"URL\")"]) {
        return NO;
    }
    
    return YES;
}


+ (NSArray *)photosWithEntry:(NSString *)entryIdentifier {

    NSMutableArray *photos = [[[NSMutableArray alloc] init] autorelease];
    
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    // execute query
    FMResultSet *rs = [db executeQuery:@"select * from Photo where entryIdentifier = ?", entryIdentifier];
    while ([rs next]) {
        // create photo
        PBPhoto *photo = [[PBPhoto alloc] initWithResultSetRow:rs];
        
        // add to array
        [photos addObject:photo];
        
        // the array owns the reference count
        [photo release];
    }
    [rs close];  
    [[PBModel sharedModel] releaseDB];
    
    return photos;

}


+ (NSArray *)cachedPhotosWithSubscription:(NSString *)subscriptionIdentifier {
    
    NSMutableArray *photos = [[[NSMutableArray alloc] init] autorelease];
    
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    // execute query
    FMResultSet *rs = [db executeQuery:@"select * from Photo where (cacheURL not null) and (entryIdentifier in (select identifier from Entry where feedIdentifier = ?))",
                       subscriptionIdentifier];
    while ([rs next]) {
        // create photo
        PBPhoto *photo = [[PBPhoto alloc] initWithResultSetRow:rs];
        
        // add to array
        [photos addObject:photo];
        
        // the array owns the reference count
        [photo release];
    }
    [rs close];  
    [[PBModel sharedModel] releaseDB];
    
    return photos;
    
}


+ (PBPhoto *)photoWithURL:(NSString *)URL {
    
    PBPhoto *photo = nil;
    
    // find photo
    FMDatabase *db = [[PBModel sharedModel] DB];
    FMResultSet *rs = [db executeQuery:@"select * from Photo where URL = ?", URL];
    while ([rs next]) {
        photo = [[[PBPhoto alloc] initWithResultSetRow:rs] autorelease];
    }
    [rs close];  
    [[PBModel sharedModel] releaseDB];
    
    return photo;
}


+ (BOOL)addPhoto:(NSString *)URL title:(NSString *)title withEntry:(NSString *)entryIdentifier {

    FMDatabase *db = [[PBModel sharedModel] DB];
    
    __BEGIN_DB_TRANSACTION__
    
    // persist photo
    [db executeUpdate:@"insert or replace into Photo ("
        "URL,"
        "entryIdentifier,"
        "cacheURL,"
        "title"
        ") values (?, ?, ?, ?)",
        URL,
        entryIdentifier,
        nil,
        title];
    __VALIDATE_DB_STATUS__
    
    __COMMIT_DB_TRANSACTION__
    
    [[PBModel sharedModel] releaseDB];
    
    return YES;
}


+ (BOOL)deletePhoto:(NSString *)URL {

    FMDatabase *db = [[PBModel sharedModel] DB];

    [db executeUpdate:@"delete from Photo where URL = ?", URL];
    __VALIDATE_DB_STATUS__
    
    [[PBModel sharedModel] releaseDB];

    return YES;
}


+ (BOOL)deleteAllPhotosWithEntry:(NSString *)entryIdentifier {
    
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    [db executeUpdate:@"delete from Photo where entryIdentifier = ?", entryIdentifier];
    __VALIDATE_DB_STATUS__
    
    [[PBModel sharedModel] releaseDB];
    
    return YES;
}


- (id)initWithResultSetRow:(FMResultSet *)rs {
    
    if (!(self = [super init])) {
        return self;
    }
    
    _URL = [[rs stringForColumn:@"URL"] retain];
    _cacheURL = [[rs stringForColumn:@"cacheURL"] retain];
    _title = [[rs stringForColumn:@"title"] retain];
    _entryIdentifier = [[rs stringForColumn:@"entryIdentifier"] retain];

    return self;
}


- (BOOL)_setCacheURLValue:(NSString *)cacheURL {
    
    // persist photo
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    __BEGIN_DB_TRANSACTION__
    
    [db executeUpdate:@"update Photo set cacheURL = ? where URL = ?", cacheURL, _URL];
    
    // error handling
    __VALIDATE_DB_STATUS__
    
    __COMMIT_DB_TRANSACTION__
    
    [[PBModel sharedModel] releaseDB];
    
    if (_cacheURL) {
        [_cacheURL release];
        _cacheURL = nil;
    }
    
    if (cacheURL) {
        _cacheURL = [cacheURL retain];
    }
    
    return YES;    
}


- (void)setCacheURL:(NSString *)cacheURL {
    
    [self _setCacheURLValue:cacheURL];
}


@end
