//
//  PBEntry.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-15.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBEntry.h"
#import "PBModel.h"
#import "NSErrorExtensions.h"
#import "NSStringExtensions.h"
#import "PBSubscription.h"
#import "PBPhoto.h"
#import "PBPhotoManager.h"


@interface PBEntry (__Internal__)

+ (NSUInteger)_numberOfEntries:(NSString *)sql args:(NSArray *)args;
+ (NSArray *)_selectEntries:(NSString *)sql args:(NSArray *)args;

@end


@implementation PBEntry


@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize feedIdentifier = _feedIdentifier;
@synthesize feedTitle = _feedTitle;
@synthesize URL = _URL;
@synthesize publishedDate = _publishedDate;

@synthesize isRead = _isRead;
@synthesize isStarred = _isStarred;
@synthesize isKeptUnread = _isKeptUnread;


- (void)dealloc {
    
    [_identifier release];
    [_title release];
    [_feedIdentifier release];
    [_feedTitle release];
    [_URL release];
    [_publishedDate release];

    [super dealloc];
}


+ (BOOL)createSchemaSQL:(FMDatabase *)db {

    if (![db executeUpdate:@"create table Entry ("
        "identifier text primary key,"
        "title text,"
        "feedIdentifier text,"
        "feedTitle text,"
        "URL text,"
        "publishedDate timestamp,"
        "isRead boolean,"
        "isStarred boolean,"
        "isKeptUnread boolean"
         ")"]) {
        return NO;
    }
    if (![db executeUpdate:@"create index EntryIdentifierIdx on Entry(\"identifier\")"]) {
        return NO;
    }
                                                               
    return YES;
}


+ (BOOL)insertOrReplaceEntryWithGoogleReaderEntry:(GDataEntryReaderEntry *)googleReaderEntry
                                 withSubscription:(PBSubscription *)subscription {
    
    // original URL
    NSString *originalURL = [[googleReaderEntry HTMLLink] href];
    if (originalURL == nil) {
        NSArray *links = [googleReaderEntry links];
        if ([links count]) {
            originalURL = [[links objectAtIndex:0] href];
        }
    }
    
    NSString *identifier = [googleReaderEntry identifier];
    NSString *title = [[[googleReaderEntry title] stringValue] stringByUnescapingHTML];
    NSString *feedIdentifier = [[googleReaderEntry source] streamId];
    NSString *feedTitle = [[[[googleReaderEntry source] title] stringValue] stringByUnescapingHTML];

//#define __DEBUG_RSS__
#ifdef __DEBUG_RSS__
    BADebugMessage(@"feed:%@", feedTitle);
    BADebugMessage(@"entry:%@", title);
    BADebugMessage(@"originalURL:%@", originalURL);
#endif
    
    // get summary (from summary or content - whichever is present)
    NSString *summary = [[googleReaderEntry summary] stringValue];
    if (!summary) {
        summary = [[googleReaderEntry content] stringValue];
    }
    
    // extra processing for photo entries
    NSMutableArray *enclosedPhotos = [[NSMutableArray new] autorelease];

    // is image enclosed as original
    for (GDataLink *link in [googleReaderEntry links]) {
        if ([[link rel] isEqualToString:@"enclosure"]) {
            NSRange range = [[link type] rangeOfString:@"image/"];
            if (range.location != NSNotFound) {
                [enclosedPhotos addObject:[link href]];
            }
        }
    }
    
    // if no original image is enclosed parse summary
    if ([enclosedPhotos count] == 0) {
        [enclosedPhotos addObjectsFromArray:[PBPhotoManager parsePhotos:summary]];
    }
    
    NSMutableArray *photos = [[NSMutableArray new] autorelease];
    for (NSString *URL in enclosedPhotos) {
#ifdef __DEBUG_RSS__
        BADebugMessage(@"photo: %@", URL);
#endif
        
        // use heuristics to add photos based on thumb photos
        // NOTE: more heuristics
        if (([feedIdentifier isEqualToString:@"feed/http://feeds.feedburner.com/chromasia"]) ||
            ([feedIdentifier isEqualToString:@"feed/http://www.chromasia.com/iblog/index.xml"])) {
            URL = [URL stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
        } else if ([feedIdentifier isEqualToString:@"feed/http://www.id7.co.uk/portfolio/atom.xml"]) {
            URL = [URL stringByReplacingOccurrencesOfString:@"-s.jpg" withString:@"-main.jpg"];
        } else if ([feedIdentifier isEqualToString:@"feed/http://moodaholic.com/rss"]) {
            URL = [URL stringByReplacingOccurrencesOfString:@"thumbnails/thumb_" withString:@"images/"];
        } else if ([feedIdentifier isEqualToString:@"feed/http://feeds.feedburner.com/MADPHOTOWORLD"]) {
            URL = [URL stringByReplacingOccurrencesOfString:@"thumb" withString:@"large"];
        } else if ([feedIdentifier isEqualToString:@"feed/http://feeds.feedburner.com/DeceptiveMedia"]) {
            URL = [URL stringByReplacingOccurrencesOfString:@"rss" withString:@"original"];
        } else if ([feedIdentifier isEqualToString:@"feed/http://mute.rigent.com/rss/mutefeed.xml"]) {
            URL = [URL stringByReplacingOccurrencesOfString:@"feedi" withString:@"pics"];
        } 
        
        // NOTE: detect when fetching photos and if they are the same (URL wise) as the thumbs
        // add those subscriptions in a database (as we do for discardable photos) and use them
        // as heuristics
        
        {
            NSRange range = [URL rangeOfString:@"blogspot.com"];
            if (range.location != NSNotFound) {
                range = [URL rangeOfString:@"s400"];
                if (range.location != NSNotFound) { 
                    URL = [URL stringByReplacingOccurrencesOfString:@"s400" withString:@"s1600"];
                }
            }
        }		
        {
            NSRange range = [URL rangeOfString:@"http://aminus3.s3.amazonaws.com/image"];
            if (range.location != NSNotFound) {
                URL = [URL stringByReplacingOccurrencesOfString:@"burst" withString:@"large"];
            }
        }
        {
            NSRange range = [URL rangeOfString:@"http://img.aminus2.com/image"];
            if (range.location != NSNotFound) {
                URL = [URL stringByReplacingOccurrencesOfString:@"burst" withString:@"large"];
            }
        }
        
        [photos addObject:URL];
    }
    
    // persist entry (in a transaction)
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    __BEGIN_DB_TRANSACTION__
    
    [db executeUpdate:@"insert or replace into Entry ("
        "identifier,"
        "title,"
        "feedIdentifier,"
        "feedTitle,"
        "URL,"
        "publishedDate,"
        "isRead,"
        "isStarred,"
        "isKeptUnread"
        ") values (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        identifier,
        title,
        feedIdentifier,
        feedTitle,
        originalURL,
        [[googleReaderEntry publishedDate] date],
        [NSNumber numberWithBool:[googleReaderEntry isRead]],
        [NSNumber numberWithBool:[googleReaderEntry hasStar]],
        [NSNumber numberWithBool:[googleReaderEntry isKeptUnread]]];

    __VALIDATE_DB_STATUS__
    
    // save photos
    for (NSString *URL in photos) {
        if (![PBPhoto addPhoto:URL title:title withEntry:identifier]) {
            // error handling
            [[PBModel sharedModel] releaseDB];
            return NO;
        }
    }

    // commit the transaction
    __COMMIT_DB_TRANSACTION__
    
    [[PBModel sharedModel] releaseDB];
    
    return YES;
}


+ (PBEntry *)entryWithIdentifier:(NSString *)entryIdentifier {
    
    PBEntry *entry = nil;    

    FMDatabase *db = [[PBModel sharedModel] DB];
    FMResultSet *rs = [db executeQuery:@"select * from Entry where identifier = ?", entryIdentifier];
    
    while ([rs next]) {
        entry = [[[PBEntry alloc] initWithResultSetRow:rs] autorelease];
        break;
    }
    [rs close];  
    [[PBModel sharedModel] releaseDB];
    
    return entry;
}


+ (NSUInteger)_numberOfEntries:(NSString *)sql args:(NSArray *)args {
    
    FMDatabase *db = [[PBModel sharedModel] DB];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:args];
    NSUInteger numberOfEntries = 0;
    while ([rs next]) {
        numberOfEntries = [rs intForColumnIndex:0];
    }
    [rs close];  
    [[PBModel sharedModel] releaseDB];
    
    return numberOfEntries;
}


+ (NSArray *)_selectEntries:(NSString *)sql args:(NSArray *)args {
    
    NSMutableArray *entries = [[[NSMutableArray alloc] init] autorelease];
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    // execute query
    FMResultSet *rs =[db executeQuery:sql withArgumentsInArray:args];
    while ([rs next]) {
        // create entry
        PBEntry *entry = [[PBEntry alloc] initWithResultSetRow:rs];
        
        // add to array
        [entries addObject:entry];
        
        // the array owns the reference count
        [entry release];
    }
    [rs close];  
    [[PBModel sharedModel] releaseDB];
    
    return entries;
}


+ (NSUInteger)numberOfEntries {

    return [PBEntry _numberOfEntries:@"select count(*) from Entry" args:nil];
}


+ (NSArray *)entries {

    return [PBEntry _selectEntries:@"select * from Entry order by publishedDate desc" args:nil];
}    


+ (NSUInteger)numberOfEntriesWithSubscription:(PBSubscription *)subscription {
    
    NSArray *args = [NSArray arrayWithObjects:[subscription identifier], nil];
    return [PBEntry _numberOfEntries:@"select count(*) from Entry where feedIdentifier = ?" args:args];
}



+ (NSArray *)entriesWithSubscription:(PBSubscription *)subscription {
    
    NSArray *args = [NSArray arrayWithObjects:[subscription identifier], nil];
    return [PBEntry _selectEntries:@"select * from Entry where feedIdentifier = ? order by publishedDate desc" args:args];
}


+ (NSUInteger)numberOfUnreadEntries {
    
    NSArray *args = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil];
    return [PBEntry _numberOfEntries:@"select count(*) from Entry where isRead = ?" args:args];
}


+ (NSUInteger)numberOfUnreadEntriesWithSubscription:(PBSubscription *)subscription {
    
    NSArray *args = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO], [subscription identifier], nil];
    return [PBEntry _numberOfEntries:@"select count(*) from Entry where isRead = ? and feedIdentifier = ?" args:args];
}


+ (NSArray *)unreadEntries {
    
    NSArray *args = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil];
    return [PBEntry _selectEntries:@"select * from Entry where isRead = ? order by publishedDate desc" args:args];
}    


+ (NSArray *)unreadEntriesWithSubscription:(PBSubscription *)subscription {
    
    NSArray *args = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO], [subscription identifier], nil];
    return [PBEntry _selectEntries:@"select * from Entry where isRead = ? and feedIdentifier = ? order by publishedDate desc" args:args];
}    


+ (NSUInteger)numberOfStarredEntries {
    
    NSArray *args = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil];
    return [PBEntry _numberOfEntries:@"select count(*) from Entry where isStarred = ?" args:args];
}


+ (NSArray *)starredEntries {
    
    NSArray *args = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil];
    return [PBEntry _selectEntries:@"select * from Entry where isStarred = ? order by publishedDate desc" args:args];
}    


- (id)initWithResultSetRow:(FMResultSet *)rs {

    if (!(self = [super init])) {
        return self;
    }
    
    _identifier = [[rs stringForColumn:@"identifier"] retain];
    _title = [[rs stringForColumn:@"title"] retain];
    _feedIdentifier = [[rs stringForColumn:@"feedIdentifier"] retain];
    _feedTitle = [[rs stringForColumn:@"feedTitle"] retain];
    _URL = [[rs stringForColumn:@"URL"] retain];
    _publishedDate = [[rs dateForColumn:@"publishedDate"] retain];
    _isRead = [rs boolForColumn:@"isRead"];
    _isStarred = [rs boolForColumn:@"isStarred"];
    _isKeptUnread = [rs boolForColumn:@"isKeptUnread"];

    return self;
}


- (NSArray *)photos {
    
    return [PBPhoto photosWithEntry:_identifier];
}


+ (BOOL)deleteAllStarredEntries {
    
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    [db executeUpdate:@"delete from Entry where isStarred = ?", [NSNumber numberWithBool:YES]];
    __VALIDATE_DB_STATUS__
    
    [[PBModel sharedModel] releaseDB];
    
    return YES;
}


+ (BOOL)deleteAllEntriesWithSubscription:(PBSubscription *)subscription {
    
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    [db executeUpdate:@"delete from Entry where feedIdentifier = ?", [subscription identifier]];
    __VALIDATE_DB_STATUS__
    
    [[PBModel sharedModel] releaseDB];
    
    return YES;
}


- (PBPhoto *)thumbPhoto {
    
    NSArray *photos = [self photos];
    
    for (PBPhoto *p in photos) {
        if ([p cacheURL] != nil) {
            return p;
        }
    }
    
    return nil;
}


- (void)dumpProperties {
    
    BADebugMessage(@"Title: %@", [self title]);
    BADebugMessage(@"Published date: %@", [self publishedDate]);
    BADebugMessage(@"By: %@", [self feedTitle]);

    if (![self isRead]) {
        BADebugMessage(@"IsUnread: YES");
    }
    if ([self isStarred]) {
        BADebugMessage(@"IsStarred: YES");
    }
    
    if ([[self photos] count] == 0) {
        BADebugMessage(@"No photos");
    } else {
        for (PBPhoto *p in [self photos]) {
            BADebugMessage(@"Photo: %@", [p URL]);
        }
    }
}


- (BOOL)markAsRead {
    
    // persist photo
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    __BEGIN_DB_TRANSACTION__
    
    [db executeUpdate:@"update Entry set isRead = ? where URL = ?", [NSNumber numberWithBool:YES], _URL];
    
    // error handling
    __VALIDATE_DB_STATUS__
    
    __COMMIT_DB_TRANSACTION__
    
    [[PBModel sharedModel] releaseDB];
    
    _isRead = YES;
    
    return YES;    
}


- (BOOL)toggleStarredFlag {

    _isStarred = !_isStarred;

    // persist photo
    FMDatabase *db = [[PBModel sharedModel] DB];
    
    __BEGIN_DB_TRANSACTION__
    
    [db executeUpdate:@"update Entry set isStarred = ? where URL = ?", [NSNumber numberWithBool:_isStarred], _URL];
    
    // error handling
    __VALIDATE_DB_STATUS__
    
    __COMMIT_DB_TRANSACTION__
    
    [[PBModel sharedModel] releaseDB];
    
    return YES;    
}


@end
