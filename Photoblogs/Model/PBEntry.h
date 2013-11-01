//
//  PBEntry.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-15.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "GDataEntryReaderEntry.h"
#import "PBPhoto.h"


@class PBSubscription;

@interface PBEntry : NSObject {
    
}

@property (nonatomic, retain, readonly) NSString *identifier;
@property (nonatomic, retain, readonly) NSString *feedIdentifier;
@property (nonatomic, retain, readonly) NSString *title;
@property (nonatomic, retain, readonly) NSString *feedTitle;
@property (nonatomic, retain, readonly) NSArray *photos;
@property (nonatomic, retain, readonly) NSString *URL;
@property (nonatomic, retain, readonly) NSDate *publishedDate;

@property (nonatomic, readonly) BOOL isRead;
@property (nonatomic, readonly) BOOL isStarred;
@property (nonatomic, readonly) BOOL isKeptUnread;



+ (BOOL)createSchemaSQL:(FMDatabase *)db;

+ (BOOL)insertOrReplaceEntryWithGoogleReaderEntry:(GDataEntryReaderEntry *)googleReaderEntry
                                 withSubscription:(PBSubscription*)subscription;
+ (PBEntry *)entryWithIdentifier:(NSString *)entryIdentifier;

+ (NSUInteger)numberOfEntries;
+ (NSArray *)entries;
+ (NSUInteger)numberOfEntriesWithSubscription:(PBSubscription *)subscription;
+ (NSArray *)entriesWithSubscription:(PBSubscription *)subscription;
+ (NSUInteger)numberOfUnreadEntries;
+ (NSUInteger)numberOfUnreadEntriesWithSubscription:(PBSubscription *)subscription;
+ (NSArray *)unreadEntries;
+ (NSArray *)unreadEntriesWithSubscription:(PBSubscription *)subscription;
+ (NSUInteger)numberOfStarredEntries;
+ (NSArray *)starredEntries;

+ (BOOL)deleteAllStarredEntries;
+ (BOOL)deleteAllEntriesWithSubscription:(PBSubscription *)subscription;

- (PBPhoto *)thumbPhoto;


- (id)initWithResultSetRow:(FMResultSet *)rs;


- (void)dumpProperties;


- (BOOL)markAsRead;
- (BOOL)toggleStarredFlag;


@end
