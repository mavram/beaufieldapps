//
//  FPWikipediaManager.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-05.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FPWikipediaManager.h"
#import "FPModel.h"
#import "NSErrorExtensions.h"
#import "FPPhoto.h"
#import "FeaturedPicturesAppDelegate.h"


NSString *kDidParsePhotosNotification = @"kDidParsePhotosNotification";
NSString *kDidFetchPhotoNotification = @"kDidFetchPhotoNotification";
NSString *kDidFetchPhotoNotificationPhotoWidth = @"kDidFetchPhotoNotificationPhotoWidth";

static const NSUInteger kMaxConcurrentOperations = 7;

static FPWikipediaManager *__sharedWikipediaManager = nil;

static BOOL __isDumpingWikipedia = NO;
static NSUInteger __currentYear = 2005;
static NSUInteger __currentMonth = 1;


BADefineUnitOfWork(dumpWikipedia);
BADefineUnitOfWork(parsePhotos);
BADefineUnitOfWork(fetchPhoto)


@implementation FPWikipediaManager


@synthesize operationsQueue = _operationsQueue;
@synthesize isParsingPhotos = _isParsingPhotos;


+ (FPWikipediaManager *)sharedWikipediaManager {
    if (__sharedWikipediaManager) {
        return __sharedWikipediaManager;
    }
    
    __sharedWikipediaManager = [[FPWikipediaManager alloc] init];
    
    return __sharedWikipediaManager;
}


- (id)init {
    
    if (!(self = [super init])) {
        return self;
    }
    
    _photosInProgress = [NSMutableDictionary new];
    _isParsingPhotos = NO;
    
    // content fetcher
    _operationsQueue = [NSOperationQueue new];
    [_operationsQueue setMaxConcurrentOperationCount:kMaxConcurrentOperations];
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Did initialize with %d photos.", [FPPhoto numberOfPhotos]);
#endif
    
    return self;
}


- (void)dealloc {
    
    [_photosInProgress release];
    [_operationsQueue release];

    [super dealloc];
}


- (void)_enqueuOp:(FPParsePhotosOp *)op {

    if (_isParsingPhotos) {
        return;
    }
    
    BABeginUnitOfWork(parsePhotos);
    
    _isParsingPhotos = YES;
    
    // set delegate & add to queue
    [op setDelegate:self];
    [_operationsQueue addOperation:op];
}


- (void)parseCurrentPhotos {
    
    // create operation and add to queue
    [self _enqueuOp:[[FPParsePhotosOp new] autorelease]];
}


- (void)parsePhotosWithYear:(NSUInteger)year month:(NSUInteger)month {
        
    // create operation and add to queue
    FPParsePhotosOp *op = [[[FPParsePhotosOp alloc] initWithYear:year month:month dumpMode:__isDumpingWikipedia] autorelease];
    [self _enqueuOp:op];
}


- (void)fetchPhoto:(FPPhoto *)photo photoWidth:(NSUInteger)photoWidth {
    
    if ([self isFetchingPhoto:photo width:photoWidth]) {
        return;
    }
    
    BABeginUnitOfWork(fetchPhoto);
    
    @synchronized(self) {
        [_photosInProgress setObject:[NSNumber numberWithInteger:photoWidth] forKey:[photo cacheURLWithWidth:photoWidth]];
    }
   
    // create operation and add to queue
    FPFetchPhotoOp *fetchPhotoOp = [[[FPFetchPhotoOp alloc] initWithPhoto:photo photoWidth:photoWidth forceFullResolution:NO] autorelease];
    [fetchPhotoOp setDelegate:self];
    [_operationsQueue addOperation:fetchPhotoOp];
}


- (void)didParsePhotos:(NSArray *)photos {
    
#ifdef __DEBUG_APP_LIFECYCLE__
    NSUInteger year = NSNotFound;
    if ([photos count]) {
        year = [(FPPhoto *)[photos objectAtIndex:0] year];
    }

    NSMutableArray *numberOfPhotosForEachMonth = [NSMutableArray arrayWithObjects:
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0],
        [NSNumber numberWithInt:0], nil];
#endif
    
    NSMutableArray *newPhotos = [[NSMutableArray new] autorelease];
    
    for (FPPhoto *p in photos) {        
        if ([FPPhoto photoWithPhotoPageURL:[p photoPageURL]]) {
            // skip duplicates not to override columns like cacheURL
            continue;
        }
        
        // heuristics
        if (([p year] == 2011) && ([p month] == 6)) {
            if ([[p title] rangeOfString:@"Pi-unrolled-720"].location != NSNotFound) {
                continue;
            }
            if ([[p title] rangeOfString:@"Su25-kompo-vers2"].location != NSNotFound) {
                continue;
            }
        }

#ifdef __DEBUG_APP_LIFECYCLE__
        NSNumber *numberOfPhotos = [numberOfPhotosForEachMonth objectAtIndex:([p month] - 1)];
        NSNumber *newNumberOfPhotos = [NSNumber numberWithInteger:[numberOfPhotos integerValue] + 1];
        [numberOfPhotosForEachMonth replaceObjectAtIndex:([p month] - 1) withObject:newNumberOfPhotos];
#endif
        
        if ([p saveToDatabase]) {
            [newPhotos addObject:p];
        }
    }
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Did parse photos from <%@>."
                   " Jan<%d>. Feb<%d>. Mar<%d>. Apr<%d>."
                   " May<%d>. Jun<%d>. Jul<%d>. Aug<%d>."
                   " Sep<%d>. Oct<%d>. Nov<%d>. Dec<%d>.",
                   (year == NSNotFound) ? @"unknown year" : [NSString stringWithFormat:@"%d", year, nil],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:0] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:1] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:2] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:3] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:4] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:5] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:6] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:7] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:8] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:9] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:10] integerValue],
                   [(NSNumber *)[numberOfPhotosForEachMonth objectAtIndex:11] integerValue]);
#endif
    
    _isParsingPhotos = NO;
    
    if (__isDumpingWikipedia) {
        NSDate *today = [NSDate date];
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];    
        NSDateComponents *todayComponents = [currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:today];
        
        NSUInteger currentMonth = [todayComponents month];
        NSUInteger currentYear = [todayComponents year];
        
        BOOL parseCurrentPhotos = NO;
        
        if (__currentMonth == 1) {
            __currentMonth = 7;
        } else {
            __currentYear = __currentYear + 1;
            __currentMonth = 1;
        }

        if (__currentYear > currentYear) {
            __isDumpingWikipedia = NO;
        } else if ((__currentYear == currentYear) && (__currentMonth >= currentMonth)) {
            parseCurrentPhotos = YES;
        }
        
        if (parseCurrentPhotos) {
            [self parseCurrentPhotos];
        } else if (__isDumpingWikipedia) {
            [self parsePhotosWithYear:__currentYear month:__currentMonth];
        } else {
            BAEndUnitOfWork(dumpWikipedia);
        }
    } else {
        BAEndUnitOfWork(parsePhotos);
    }
    
    if (!__isDumpingWikipedia) {
        NSNotification *note = [NSNotification notificationWithName:kDidParsePhotosNotification
                                                             object:newPhotos
                                                           userInfo:nil];
        [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                                   postingStyle:NSPostASAP
                                                   coalesceMask:NSNotificationNoCoalescing
                                                       forModes:nil];
    }

}


- (void)didFetchPhoto:(FPPhoto *)photo withWidth:(NSUInteger)photoWidth {
    
    @synchronized(self) {
        [_photosInProgress removeObjectForKey:[photo cacheURLWithWidth:photoWidth]];
    }
    
    NSNumber *photoWidthAsNumber = [NSNumber numberWithInteger:photoWidth];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:photoWidthAsNumber forKey:kDidFetchPhotoNotificationPhotoWidth];
    NSNotification *note = [NSNotification notificationWithName:kDidFetchPhotoNotification
                                                         object:photo
                                                       userInfo:userInfo];
    [[NSNotificationQueue defaultQueue] enqueueNotification:note
                                               postingStyle:NSPostWhenIdle
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];

    //BAEndUnitOfWork(fetchPhoto)
}


- (void)didFailToFetchPhoto:(FPPhoto *)photo withWidth:(NSUInteger)photoWidth forceFullResolution:(BOOL)forceFullResolution {
    
    if (forceFullResolution) {
        // we did retry with full resolution. time to give up
        [self didFetchPhoto:photo withWidth:photoWidth];
    } else {
        // retry for full resolution
        FPFetchPhotoOp *fetchPhotoOp = [[[FPFetchPhotoOp alloc] initWithPhoto:photo photoWidth:photoWidth forceFullResolution:YES] autorelease];
        [fetchPhotoOp setDelegate:self];
        [_operationsQueue addOperation:fetchPhotoOp];
    }
}


- (BOOL)isFetchingPhoto:(FPPhoto *)photo width:(NSUInteger)photoWidth {
    
    @synchronized(self) {
        NSNumber *photoWidthNumber = (NSNumber *)[_photosInProgress objectForKey:[photo cacheURLWithWidth:photoWidth]];
        
        if (!photoWidthNumber || ([photoWidthNumber integerValue] != photoWidth)) {
            return NO;
        }
        
        return YES;
    }
}


- (void)dumpWikipedia {
    
    if (__isDumpingWikipedia) {
        return;
    }
    
    BABeginUnitOfWork(dumpWikipedia);
    
    __currentYear = 2005;
    __currentMonth = 1;
    __isDumpingWikipedia = YES;

    [self parsePhotosWithYear:__currentYear month:__currentMonth];
}


@end
