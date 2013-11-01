//
//  PBPhotoManager.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-25.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBPhotoManager.h"
#import "PBModel.h"
#import "NSErrorExtensions.h"
#import "PBPhoto.h"
#import "PBAppDelegate.h"
#import "PBFetchPhotoOperation.h"


NSString *kDidFetchPhotoNotification = @"kDidFetchPhotoNotification";


static PBPhotoManager *__sharedPhotoManager = nil;


@interface PBPhotoManager (__Internal__)

- (void)_doneFetchingPhoto:(PBPhoto *)photo;

@end


@implementation PBPhotoManager


@synthesize baseService = _baseService;
@synthesize baseServiceQueue = _baseServiceQueue;


+ (PBPhotoManager *)sharedPhotoManager {
    if (__sharedPhotoManager) {
        return __sharedPhotoManager;
    }
        
    __sharedPhotoManager = [[PBPhotoManager alloc] init];
    
    return __sharedPhotoManager;
}


+ (BOOL)createSchemaSQL:(FMDatabase *)db {
    
    return [db executeUpdate:@"create table DiscardablePhoto (URL text primary key)"];
}


+ (NSMutableArray *)parsePhotos:(NSString *)html {
    
    NSMutableArray *photos = [[[NSMutableArray alloc] init] autorelease];
    
    // if not wrapped in html scanner fails
    NSScanner *scanner = [[[NSScanner alloc] initWithString:[NSString stringWithFormat:@"<html><body>%@</body></html>", html]] autorelease];
    while (![scanner isAtEnd]) {
        // move to next img tag
        NSString *beginingOfImgTag = @"<img ";
        BOOL didFind = [scanner scanUpToString:beginingOfImgTag intoString:NULL];
        if (!didFind || [scanner isAtEnd]) {
            break;
        }
        // skip to src attr
        NSString *beginingOfSrcAttr = @" src";
        didFind = [scanner scanUpToString:beginingOfSrcAttr intoString:NULL];
        if (!didFind || [scanner isAtEnd]) {
            break;
        }
        // skip to begining of the img url string
        NSCharacterSet *quoteCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        didFind = [scanner scanUpToCharactersFromSet:quoteCharSet intoString:NULL];
        if (!didFind || [scanner isAtEnd]) {
            break;
        }
        [scanner setCharactersToBeSkipped: quoteCharSet];
        
        // scan img url
        NSString *URL = nil;
        NSString *endOfSrcAttr = @"\"";
        didFind = [scanner scanUpToString:endOfSrcAttr intoString:&URL];
        if (!didFind || [scanner isAtEnd]) {
            break;
        }
        
        if (URL == nil) {
            continue;
        }
        
        // check extension
        if (([URL rangeOfString:@".gif"].location == NSNotFound) &&
            ([URL rangeOfString:@".jpg"].location == NSNotFound) &&
            ([URL rangeOfString:@".jpeg"].location == NSNotFound) &&
            ([URL rangeOfString:@".tiff"].location == NSNotFound) &&
            ([URL rangeOfString:@".png"].location == NSNotFound)) {
            continue;
        }
        
        // ignore known noise
		if ([URL rangeOfString:@"http://feeds.feedburner"].location != NSNotFound) {
			continue;
		}
		if ([URL rangeOfString:@"http://feeds2.feedburner"].location != NSNotFound) {
			continue;
		}
		if ([URL rangeOfString:@"www.adobe.com"].location != NSNotFound) {
			continue;
		}
		if ([URL rangeOfString:@"feeds.wordpress.com"].location != NSNotFound) {
			continue;
		}
		if ([URL rangeOfString:@"stats.wordpress.com"].location != NSNotFound) {
			continue;
		}
		if ([URL rangeOfString:@"blogger.googleusercontent.com"].location != NSNotFound) {
			continue;
		}
		// noupe blog
		if ([URL rangeOfString:@"http://statisches.auslieferung.commindo-media-ressourcen.de/advertisement.gif"].location != NSNotFound) {
			continue;
		}
		if ([URL rangeOfString:@"http://auslieferung.commindo-media-ressourcen.de/www/delivery/avw.php"].location != NSNotFound) {
			continue;
		}
		if ([URL rangeOfString:@"http://feeds.feedburner.com/~ff/Noupe?"].location != NSNotFound) {
			continue;
		}
		// The Big Picture - www.boston.com
		if ([URL rangeOfString:@"http://pixel.quantserve.com/pixel/"].location != NSNotFound) {
			continue;
		}
		if ([URL rangeOfString:@"pheedo"].location != NSNotFound) {
			continue;
		}
        
        // is register as discardable
        if ([[PBPhotoManager sharedPhotoManager] isDiscardablePhoto:URL]) {
            continue;
        }

		[photos addObject:URL];
    }
    
    return photos;
}


- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }
    
    _photosInProgress = [NSMutableDictionary new];
    _entriesInProgress = [NSMutableDictionary new];

    // content fetcher
	_baseService = [GDataServiceBase new];
    _baseServiceQueue = [NSOperationQueue new];
    [_baseServiceQueue setMaxConcurrentOperationCount:7];
    
    return self;
}


- (void)dealloc {
    
    [_photosInProgress release];
    [_entriesInProgress release];
    
    [_baseServiceQueue release];
    [_baseService release];
    
    [super dealloc];
}


- (BOOL)isDiscardablePhoto:(NSString *)URL {
    
    // check if URL is registered as discardable photo
    FMDatabase *db = [[PBModel sharedModel] DB];
    FMResultSet *rs = [db executeQuery:@"select count(*) from DiscardablePhoto where URL = ?", URL];
    NSInteger numberOfEntries = 0;
    while ([rs next]) {
        numberOfEntries = [rs intForColumnIndex:0];
    }
    [rs close];  
    [[PBModel sharedModel] releaseDB];
    
    return (numberOfEntries != 0);
}


- (BOOL)fetchPhoto:(PBPhoto *)photo withEntry:(PBEntry *)entry {
    
    // check if we are not fetching or have it cached already
    if ([photo cacheURL] || [self isFetchingPhoto:photo]) {
        return NO;
    }
    
    // start building cache URL
    NSString *cacheURL = [[PBAppDelegate applicationCacheDirectory] path];
    cacheURL = [cacheURL stringByAppendingPathComponent:[entry feedTitle]];
	
    // escape photo URL
	NSURL *photoURL = [NSURL URLWithString:[[photo URL] stringByReplacingOccurrencesOfString:@"?" withString:@"_"]];
    cacheURL = [cacheURL stringByAppendingPathComponent:[photoURL host]];
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

    // create operation and add to queue
    PBFetchPhotoOperation *fetchPhotoOp = [[PBFetchPhotoOperation alloc] initWithPhoto:photo cacheURL:cacheURL service:_baseService];
    [fetchPhotoOp setDelegate:self];
    [_baseServiceQueue addOperation:fetchPhotoOp];
    [fetchPhotoOp release];

    @synchronized(self) {
        // this entry is used for didFetchPhoto to check if we are
        // done with all the photos for the entry
        [_photosInProgress setObject:entry forKey:[photo URL]];
        
        NSNumber *numberOfPhotosInProgressAsObject = (NSNumber *)[_entriesInProgress objectForKey:[entry identifier]];
        if (numberOfPhotosInProgressAsObject) {
            NSInteger newNnumberOfPhotosInProgress = [numberOfPhotosInProgressAsObject integerValue] + 1;
            [_entriesInProgress setObject:[NSNumber numberWithInteger:newNnumberOfPhotosInProgress] forKey:[entry identifier]];
        } else {
            // first photo
            [_entriesInProgress setObject:[NSNumber numberWithInteger:1] forKey:[entry identifier]];
        }
    }
    
    return YES;
}


- (BOOL)isFetchingPhoto:(PBPhoto *)photo {

    @synchronized(self) {
        return ([_photosInProgress objectForKey:[photo URL]] != nil);
    }
}


- (BOOL)isFetchingEntry:(PBEntry *)entry {

    @synchronized(self) {
        return ([_entriesInProgress objectForKey:[entry identifier]] != nil);
    }
}


- (void)fetchPhotosWithEntry:(PBEntry *)entry {
    
    NSArray *photos = [entry photos];
    for (PBPhoto *p in photos) {
        // fetchPhoto checks and make sure we don't fetch twice
        [self fetchPhoto:p withEntry:entry];
    }
}


- (void)_doneFetchingPhoto:(PBPhoto *)photo {
    
    @synchronized(self) {
        PBEntry *entry = (PBEntry *)[_photosInProgress objectForKey:[photo URL]];
        NSInteger numberOfPhotosInProgress = [(NSNumber *)[_entriesInProgress objectForKey:[entry identifier]] integerValue];
        if (numberOfPhotosInProgress == 1) {
            // last photo
            [_entriesInProgress removeObjectForKey:[entry identifier]];
        }
        [_photosInProgress removeObjectForKey:[photo URL]];
    }
}


- (void)didDiscardPhoto:(PBPhoto *)photo {
    
    [self _doneFetchingPhoto:photo];
    
    // delete photo
    [PBPhoto deletePhoto:[photo URL]];

    // insert URL as discardable
    FMDatabase *db = [[PBModel sharedModel] DB];
    [db executeUpdate:@"insert into DiscardablePhoto (URL) values (?)", [photo URL]];
    
    // error handling
    if ([db hadError]) {
        BAErrorMessage(@"db_error<%d:%@>", [db lastErrorCode], [db lastErrorMessage]);
    }
    [[PBModel sharedModel] releaseDB];
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Did discard photo for <%@> with <%d> queued.", [photo URL], [[_photosInProgress allKeys] count]);
#endif
}


- (void)didFailToFetchPhoto:(PBPhoto *)photo {
    
    [self _doneFetchingPhoto:photo];
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Did fail to fetch photo for <%@> with <%d> queued.", [photo URL], [[_photosInProgress allKeys] count]);
#endif
    
    NSNotification *note = [NSNotification notificationWithName:kDidFetchPhotoNotification
                                                         object:photo
                                                       userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];
}


- (void)didFetchPhoto:(PBFetchPhotoOperationResult *)result {
    
    [self _doneFetchingPhoto:[result photo]];
    [[result photo] setCacheURL:[result cacheURL]];
    
    NSNotification *note = [NSNotification notificationWithName:kDidFetchPhotoNotification
                                                         object:[result photo]
                                                       userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];
}


- (void)dumpPhotosInProgress {
    
    BADebugMessage(@"__begin__");
    
    @synchronized(self) {
        for (NSURL *URL in [_photosInProgress allKeys]) {
            BADebugMessage(@"URL In Progress: %@", URL);
            
            PBEntry *entry = (PBEntry *)[_photosInProgress objectForKey:URL];
            [entry dumpProperties];
        }
    }
    
    BADebugMessage(@"__end__");
} 


@end
