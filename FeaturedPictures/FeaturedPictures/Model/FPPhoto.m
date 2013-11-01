//
//  FPPhoto.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-05.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FPPhoto.h"
#import "FPModel.h"
#import "NSErrorExtensions.h"
#import "FeaturedPicturesAppDelegate.h"


NSString *kWidthInPixelsTag = @"__width_in_px_tag__";


@interface  FPPhoto (__Internal__)

+ (NSUInteger)_numberOfPhotos:(NSString *)sql args:(NSArray *)args;
- (id)_initWithResultSetRow:(FMResultSet *)rs;

@end


@implementation FPPhoto


@synthesize thumbGeneratorURL = _thumbGeneratorURL;
@synthesize photoPageURL = _photoPageURL;
@synthesize year = _year;
@synthesize month = _month;
@synthesize positionInMonth = _positionInMonth;
@synthesize title = _title;
@synthesize isStarred = _isStarred;
@synthesize author = _author;
@synthesize description = _description;
@synthesize creationDate = _creationDate;


+ (NSUInteger)_numberOfPhotos:(NSString *)sql args:(NSArray *)args {
    
    FMDatabase *db = [[FPModel sharedModel] DB];
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:args];
    NSUInteger numberOfEntries = 0;
    while ([rs next]) {
        numberOfEntries = [rs intForColumnIndex:0];
    }
    [rs close];  
    [[FPModel sharedModel] releaseDB];
    
    return numberOfEntries;
}


+ (BOOL)createSchemaSQL:(FMDatabase *)db {
    
    if (![db executeUpdate:@"create table Photo ("
          "thumbGeneratorURL text primary key,"
          "photoPageURL text,"
          "cacheURL text,"
          "year integer,"
          "month integer,"
          "positionInMonth integer,"
          "title text,"
          "isStarred boolean,"
          "author text,"
          "description text,"
          "creationDate timestamp"
          ")"]) {
        return NO;
    }
    if (![db executeUpdate:@"create index PhotoThumbGeneratorURLIdx on Photo(\"thumbGeneratorURL\")"]) {
        return NO;
    }
    if (![db executeUpdate:@"create index PhotoYearIdx on Photo(\"year\")"]) {
        return NO;
    }    
    if (![db executeUpdate:@"create index PhotoMonthIdx on Photo(\"month\")"]) {
        return NO;
    }    
    return YES;
}


+ (NSUInteger)currentMonth {
    
    // default current to current calendar month
    NSDate *today = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];    
    NSDateComponents *todayComponents = [currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:today];
    
    NSUInteger currentMonth = [todayComponents month];

    FMDatabase *db = [[FPModel sharedModel] DB];
    
    // execute query
    FMResultSet *rs = [db executeQuery:@"select month from Photo group by year,month order by year desc, month desc;"];
    while ([rs next]) {
        // get most recent month from db
        currentMonth = [rs intForColumnIndex:0];
        break;
    }
    [rs close];  
    [[FPModel sharedModel] releaseDB];
    
    return currentMonth;
}


+ (NSUInteger)currentYear {
    
    // default current to current calendar year
    NSDate *today = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];    
    NSDateComponents *todayComponents = [currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:today];
    
    NSUInteger currentYear = [todayComponents year];
    
    FMDatabase *db = [[FPModel sharedModel] DB];
    
    // execute query
    FMResultSet *rs = [db executeQuery:@"select year from Photo group by year order by year desc;"];
    while ([rs next]) {
        // get most recent year from db
        currentYear = [rs intForColumnIndex:0];
        break;
    }
    [rs close];  
    [[FPModel sharedModel] releaseDB];
    
    return currentYear;
}


+ (NSUInteger)firstYear {
    return 2005;
}


+ (NSUInteger)numberOfPhotos {
    
    return [FPPhoto _numberOfPhotos:@"select count(*) from Photo" args:nil];
}


+ (NSArray *)photosWithYear:(NSUInteger)year month:(NSUInteger)month {

    NSMutableArray *photos = [[[NSMutableArray alloc] init] autorelease];
    
    FMDatabase *db = [[FPModel sharedModel] DB];
    
    // execute query
    FMResultSet *rs = [db executeQuery:@"select * from Photo where year=? and month=? order by positionInMonth desc;",
                       [NSNumber numberWithInteger:year],
                       [NSNumber numberWithInteger:month]];
    while ([rs next]) {
        // create photo
        FPPhoto *photo = [[FPPhoto alloc] _initWithResultSetRow:rs];
        
        // add to array
        [photos addObject:photo];
        
        // the array owns the reference count
        [photo release];
    }
    [rs close];  
    [[FPModel sharedModel] releaseDB];
    
    return photos;
}


+ (NSArray *)allStarredPhotos {
    
    NSMutableArray *photos = [[[NSMutableArray alloc] init] autorelease];
    
    FMDatabase *db = [[FPModel sharedModel] DB];
    
    // execute query
    FMResultSet *rs = [db executeQuery:@"select * from Photo where isStarred = ? order by year desc, month desc, positionInMonth desc;",
                       [NSNumber numberWithBool:YES]];
    while ([rs next]) {
        // create photo
        FPPhoto *photo = [[FPPhoto alloc] _initWithResultSetRow:rs];
        
        // add to array
        [photos addObject:photo];
        
        // the array owns the reference count
        [photo release];
    }
    [rs close];  
    [[FPModel sharedModel] releaseDB];
    
    return photos;
}


+ (FPPhoto *)photoWithPhotoPageURL:(NSString *)photoPageURL {

    FPPhoto *photo = nil;
    
    // find photo
    FMDatabase *db = [[FPModel sharedModel] DB];
    FMResultSet *rs = [db executeQuery:@"select * from Photo where photoPageURL = ?", photoPageURL];
    while ([rs next]) {
        photo = [[[FPPhoto alloc] _initWithResultSetRow:rs] autorelease];
    }
    [rs close];  
    [[FPModel sharedModel] releaseDB];
    
    return photo;
}


- (void)dealloc {
    
    [self setThumbGeneratorURL:nil];
    [self setPhotoPageURL:nil];
    [self setTitle:nil];
    [self setAuthor:nil];
    [self setDescription:nil];
    [self setCreationDate:nil];
    
    [super dealloc];
}


- (id)_initWithResultSetRow:(FMResultSet *)rs {
    
    if (!(self = [super init])) {
        return self;
    }

    
    // columns parsed from featured pictures page
    _thumbGeneratorURL = [[rs stringForColumn:@"thumbGeneratorURL"] retain];
    _photoPageURL = [[rs stringForColumn:@"photoPageURL"] retain];
    _title = [[rs stringForColumn:@"title"] retain];
    _year = [rs intForColumn:@"year"];
    _month = [rs intForColumn:@"month"];
    _positionInMonth = [rs intForColumn:@"positionInMonth"];
    // columns managed by app
    _isStarred = [rs boolForColumn:@"isStarred"];
    // columns parsed from photo page
    _author = [[rs stringForColumn:@"author"] retain];
    _description = [[rs stringForColumn:@"description"] retain];
    _creationDate = [[rs dateForColumn:@"creationDate"] retain];
    
    return self;
}


- (id)initWithImgSrc:(NSString *)imgSrc imgWidth:(NSUInteger)imgWidth {
    
    if (!(self = [super init])) {
        return self;
    }
    
    NSString *widthTag = [NSString stringWithFormat:@"%dpx", imgWidth];
    imgSrc = [imgSrc stringByReplacingOccurrencesOfString:widthTag withString:kWidthInPixelsTag];
    
    NSString *thumbGeneratorURL = imgSrc;
    
    NSString *httpPrefix = @"http:";
    if (![imgSrc hasPrefix:httpPrefix]) {
        thumbGeneratorURL = [httpPrefix stringByAppendingString:imgSrc];
    }

    [self setThumbGeneratorURL:[NSURL URLWithString:thumbGeneratorURL]];
    
    return self;
}


- (BOOL)saveToDatabase {
    
    FMDatabase *db = [[FPModel sharedModel] DB];
    
    // persist photo
    [db executeUpdate:@"insert or replace into Photo ("
     "thumbGeneratorURL,"
     "photoPageURL,"
     "year,"
     "month,"
     "positionInMonth,"
     "title,"
     "isStarred,"
     "author,"
     "description,"
     "creationDate"
     ") values "
     "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
     _thumbGeneratorURL,
     _photoPageURL,
     [NSNumber numberWithInteger:_year],
     [NSNumber numberWithInteger:_month],
     [NSNumber numberWithInteger:_positionInMonth],
     _title,
     [NSNumber numberWithBool:_isStarred],
     _author,
     _description,
     _creationDate];
    
    if ([db hadError]) {
        BAErrorMessage(@"db_error<%d:%@>", [db lastErrorCode], [db lastErrorMessage]);
        [[FPModel sharedModel] releaseDB];
        return NO;
    }
    
    [[FPModel sharedModel] releaseDB];
    
    return YES;
}


+ (NSString *)monthNameWithName:(NSUInteger)month {
    NSString *monthName; {
        // craft a date with current month
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"MM dd, yyy"];
        NSDate *dateWithMonth = [formatter dateFromString:[NSString stringWithFormat:@"%d 1, 2011", month, nil]];
        // get the month name
        [formatter setDateFormat:@"MMMM"];
        monthName = [formatter stringFromDate:dateWithMonth];
    }
    
    return monthName;
}


- (NSString *)monthName {
    return [FPPhoto monthNameWithName:_month];
}


- (NSString *)fullResolutionPhotoURL {
    
    // thumb: http://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Vulpes_vulpes_laying_in_snow.jpg/__width_in_px_tag__-Vulpes_vulpes_laying_in_snow.jpg
    // full resolution: http://upload.wikimedia.org/wikipedia/commons/0/03/Vulpes_vulpes_laying_in_snow.jpg

    NSString *frpURL = [_thumbGeneratorURL stringByReplacingOccurrencesOfString:@"thumb/" withString:@""];
    NSString *s = @"/";
    s = [s stringByAppendingString:kWidthInPixelsTag];
    NSArray *c = [frpURL componentsSeparatedByString:s];
    
    if ([c count]) {
        return [c objectAtIndex:0];
    }
    
    return nil;
}


#pragma mark - Local Cache methods


- (NSString*)thumbGeneratorURLWithWidth:(NSUInteger)width {
    
    NSString *widthTag = [NSString stringWithFormat:@"%dpx", width];

    NSString *httpPrefix = @"http:";
    if (_thumbGeneratorURL && ![_thumbGeneratorURL hasPrefix:httpPrefix]) {
        [self setThumbGeneratorURL:[httpPrefix stringByAppendingString:_thumbGeneratorURL]];
    }

    return [_thumbGeneratorURL stringByReplacingOccurrencesOfString:kWidthInPixelsTag withString:widthTag];
}


- (NSString *)cacheURLWithWidth:(NSUInteger)width {
    
    // start building cache URL
    NSString *cacheURL = [[FeaturedPicturesAppDelegate applicationCacheDirectory] path];
    
    // escape photo URL
	NSURL *photoURL = [NSURL URLWithString:_photoPageURL];
    cacheURL = [cacheURL stringByAppendingPathComponent:[photoURL host]];
    cacheURL = [cacheURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", _year, nil]];
    cacheURL = [cacheURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", _month, nil]];
    cacheURL = [cacheURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%dpx", width, nil]];
    cacheURL = [cacheURL stringByAppendingPathComponent:[photoURL relativePath]];
    
    // check if we need to create the folders in the path
    NSString *parentDirectory = [cacheURL stringByDeletingLastPathComponent];
    
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:parentDirectory isDirectory:&isDirectory] == NO) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtPath:parentDirectory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            [error printErrorToConsoleWithMessage:[NSString stringWithFormat:@"Failed to create directory <%@>", parentDirectory]];
        } 
    }
    
    return cacheURL;
}


- (BOOL)hasCachedImageWithWidth:(NSUInteger)width {
    
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    NSString *cachedImageURL = [self cacheURLWithWidth:width];
    return [fileManager fileExistsAtPath:cachedImageURL];
}


- (UIImage *)cachedImageWithWidth:(NSUInteger)width {

    NSString *cachedImageURL = [self cacheURLWithWidth:width];
    return [UIImage imageWithContentsOfFile:cachedImageURL];
}


@end

