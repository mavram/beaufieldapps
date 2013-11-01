//
//  FPParsePhotosOp.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-05.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FPParsePhotosOp.h"
#import "NSErrorExtensions.h"
#import "FPPhoto.h"
#import "TFHpple.h"
#import "TFHppleElement.h"


BADefineUnitOfWork(parsePhotosOp);


static NSString *kWikipediaFavoritePicturesURL = @"http://commons.wikimedia.org/wiki/Commons:Featured_pictures/chronological";


@interface FPParsePhotosOp(__Internal__)

- (NSUInteger)_monthNameToIndex;
- (NSArray *)_parsePhotosWithYear:(NSUInteger)year
                            month:(NSUInteger)month
                         xpathIdx:(NSUInteger)xpathIdx
                      xpathEngine:(TFHpple *)xpathEngine;

@end


@implementation FPParsePhotosOp


@synthesize delegate = _delegate;


- (id)_initWithWikipediaURL:(NSString *)urlAsString {

    NSURL *url = [NSURL URLWithString:urlAsString];
    
    if (!(self = [super initWithURL:url])) {
        return self;
    }
    
    _month = NSNotFound;
    
    return self;
}


- (id)init {
    
    return [self _initWithWikipediaURL:kWikipediaFavoritePicturesURL];
}


- (id)initWithYear:(NSUInteger)year month:(NSUInteger)month dumpMode:(BOOL)dumpMode {
    
    NSString *urlAsString = kWikipediaFavoritePicturesURL;
    NSString *halfOfTheYear = @"A";
    if (month > 6) {
        halfOfTheYear = @"B";
    }
    NSString *section = [NSString stringWithFormat:@"%d-%@", year, halfOfTheYear];
    urlAsString = [urlAsString stringByAppendingPathComponent:section];

    if (!(self = [self _initWithWikipediaURL:urlAsString])) {
        return self;
    }
    
    // if we are dumping parse the whole page as we do for current photos page
    if (!dumpMode) {
        _month = month;
    }
    
    return self;
}


- (void)dealloc {
    
    [super dealloc];
}


- (NSUInteger)_monthWithMonthName:(NSString *)monthName {
    
    if ([monthName isEqualToString:@"January"]) {
        return 1;
    } else if ([monthName isEqualToString:@"February"]) {
        return 2;
    } else if ([monthName isEqualToString:@"March"]) {
        return 3;
    } else if ([monthName isEqualToString:@"April"]) {
        return 4;
    } else if ([monthName isEqualToString:@"May"]) {
        return 5;
    } else if ([monthName isEqualToString:@"June"]) {
        return 6;
    } else if ([monthName isEqualToString:@"July"]) {
        return 7;
    } else if ([monthName isEqualToString:@"August"]) {
        return 8;
    } else if ([monthName isEqualToString:@"September"]) {
        return 9;
    } else if ([monthName isEqualToString:@"October"]) {
        return 10;
    } else if ([monthName isEqualToString:@"November"]) {
        return 11;
    } else if ([monthName isEqualToString:@"December"]) {
        return 12;
    } 
    
    NSAssert(NO, @"Invalid month name");
    
    return NSNotFound;
}


- (NSArray *)_parsePhotosWithYear:(NSUInteger)year
                            month:(NSUInteger)month
                         xpathIdx:(NSUInteger)xpathIdx
                      xpathEngine:(TFHpple *)xpathEngine
            positionInMonthOffset:(NSUInteger)positionInMonthOffset {

    NSMutableArray *imgSrcs = [[NSMutableArray new] autorelease];
    NSMutableArray *imgWidths = [[NSMutableArray new] autorelease];
    NSMutableArray *photoPageURLs = [[NSMutableArray new] autorelease];
    NSMutableArray *titles = [[NSMutableArray new] autorelease];
    
    NSString *tPath = [NSString stringWithFormat:@"//ul[@class='gallery'][%d]/li[@class='gallerybox']/div", xpathIdx];
    NSArray *tags = [xpathEngine search:tPath];

    NSString *preMay2008TitlePath = [NSString stringWithFormat:@"//ol[%d]/li", xpathIdx];
    NSArray *preMay2008TitleElements = nil;
    if ((year < 2008) || ((year == 2008) && (month < 5))) {
        preMay2008TitleElements = [xpathEngine search:preMay2008TitlePath];
    }
    
//#ifdef __DEBUG_APP_LIFECYCLE__
//    BADebugMessage(@"%d/%d: Found <%d> tags", month, year, [tags count]);
//    if (preMay2008TitleElements) {
//        BADebugMessage(@"%d/%d: Found <%d> (old style) titles", month, year, [preMay2008TitleElements count]);
//    }
//#endif//__DEBUG_APP_LIFECYCLE__

    for (TFHppleElement *e in tags) {
        // thumbs
        // @"//ul[@class='gallery'][%d]/li[@class='gallerybox']/div/div[@class='thumb']/div/a"

        TFHppleElement *thumbDivElement = [[[TFHppleElement alloc] initWithNode:[[e children] objectAtIndex:0]] autorelease];
        TFHppleElement *thumbInnerDivElement = [[[TFHppleElement alloc] initWithNode:[[thumbDivElement children] objectAtIndex:0]] autorelease];
        TFHppleElement *hrefElement = [[[TFHppleElement alloc] initWithNode:[[thumbInnerDivElement children] objectAtIndex:0]] autorelease];
        
        // a:href attribute
        NSString *photoPageURL = [NSString stringWithFormat:@"http://commons.wikimedia.org%@", [hrefElement objectForKey:@"href"], nil];

        //a/img:src & a/img:width
        TFHppleElement *imgElement = [[[TFHppleElement alloc] initWithNode:[[hrefElement children] objectAtIndex:0]] autorelease];

        NSString *src = [imgElement objectForKey:@"src"];
        NSString *width = [imgElement objectForKey:@"width"];
        
        // title
        NSString *title = nil;

        // @"//ul[@class='gallery'][%d]/li[@class='gallerybox']/div/div[@class='gallerytext']/p"
        TFHppleElement *textGalleryDivElement = [[[TFHppleElement alloc] initWithNode:[[e children] objectAtIndex:1]] autorelease];
        TFHppleElement *pElement = [[[TFHppleElement alloc] initWithNode:[[textGalleryDivElement children] objectAtIndex:0]] autorelease];

        // new gallery box is used since May 2008
        if ((year < 2008) || ((year == 2008) && (month < 5))) {
            // this contains the index of the title in the preMay2008TitleElements
            NSUInteger titleIdx = [[pElement content] intValue];
            
            if (titleIdx <= [preMay2008TitleElements count]) {
                TFHppleElement *titleElement = [preMay2008TitleElements objectAtIndex:titleIdx - 1];             
                for (NSDictionary *d in [titleElement children]) {
                    TFHppleElement *c = [[[TFHppleElement alloc] initWithNode:d] autorelease];
                    if (([[c tagName] isEqualToString:@"a"]) && ([c hasChildren])) {
                        for (NSDictionary *dd in [c children]) {
                            TFHppleElement *cc = [[[TFHppleElement alloc] initWithNode:dd] autorelease];
                            if ([[cc tagName] isEqualToString:@"b"]) {
                                // @"//ol[%d]/li/a/b"
                                title = [cc content];
                            }
                            
                            if ([[cc tagName] isEqualToString:@"i"]) {
                                if ([cc hasChildren]) {
                                    for (NSDictionary *ddd in [cc children]) {
                                        TFHppleElement *ccc = [[[TFHppleElement alloc] initWithNode:ddd] autorelease];
                                        if ([[ccc tagName] isEqualToString:@"b"]) {
                                            // @"//ol[%d]/li/a/i/b"
                                            title = [ccc content];
                                            break;
                                        }
                                    }
                                }
                                
                                // @"//ol[%d]/li/a/i"
                                if (title == nil) {
                                    title = [cc content];
                                }
                            }
                                    
                            // have we found a title?
                            if (title) {
                                break;
                            }
                        }
                    }
                    
                    // have we found a title?
                    if (title) {
                        break;
                    }
                }
                
                if ((title == nil) && [titleElement hasChildren]) {
                    // @"//ol[%d]/li/a[0]"
                    NSDictionary *d = [[titleElement children] objectAtIndex:0];
                    TFHppleElement *c = [[[TFHppleElement alloc] initWithNode:d] autorelease];
                    title = [c objectForKey:@"title"];
                }
            }
        } else {
            for (NSDictionary *d in [pElement children]) {
                TFHppleElement *c = [[[TFHppleElement alloc] initWithNode:d] autorelease];
                
                // @"//ul[@class='gallery'][%d]/li[@class='gallerybox']/div/div[@class='gallerytext']/p/b"
                if ([[c tagName] isEqualToString:@"b"]) {
                    title = [c content];    
                }
                
                if ([[c tagName] isEqualToString:@"i"]) {
                    if ([c hasChildren]) {
                        for (NSDictionary *dd in [c children]) {
                            TFHppleElement *cc = [[[TFHppleElement alloc] initWithNode:dd] autorelease];
                            
                            if ([[cc tagName] isEqualToString:@"b"]) {
                                // @"//ul[@class='gallery'][%d]/li[@class='gallerybox']/div/div[@class='gallerytext']/p/i/b"
                                title = [cc content];
                                if (title) {
                                    break;
                                }
                                
                                if ([cc hasChildren]) {
                                    for (NSDictionary *ddd in [cc children]) {
                                        TFHppleElement *ccc = [[[TFHppleElement alloc] initWithNode:ddd] autorelease];
                                        
                                        if ([[ccc tagName] isEqualToString:@"a"]) {
                                            // @"//ul[@class='gallery'][%d]/li[@class='gallerybox']/div/div[@class='gallerytext']/p/i/b/a"
                                            title = [ccc content];
                                            if (title) {
                                                break;
                                            }
                                        }
                                    }
                                }
                            }

                            if (title) {
                                break;
                            }    
                        }
                    }

                    if (title == nil) {
                        // @"//ul[@class='gallery'][%d]/li[@class='gallerybox']/div/div[@class='gallerytext']/p/i"
                        title = [c content];    
                    }
                }
                
                // have we found title?
                if (title) {
                    break;
                }
            }

            // @"//ul[@class='gallery'][%d]/li[@class='gallerybox']/div/div[@class='gallerytext']/p"
            if (title == nil) {
                title = [pElement content];
            }
        }
        
        // skip nil values
        if ((photoPageURL == nil) || (src == nil) || (width == nil) || (title == nil)) {
#ifdef __DEBUG_APP_LIFECYCLE__
            BADebugMessage(@"Thumb will be skipped.[year:%d; month:%d; title:%@; src:%@; width:%@; URL:%@]", year, month, title, src, width, photoPageURL);
#endif
            continue;
        }
        
        [photoPageURLs addObject:photoPageURL];
        [imgSrcs addObject:src];
        [imgWidths addObject:width];
        [titles addObject:title];
    }
    
    // create photos array
    NSMutableArray *photos = [[NSMutableArray new] autorelease];
    NSUInteger numberOfPhotos = [imgSrcs count];
    
    for (NSUInteger i = 0; i < numberOfPhotos; i ++) {
        NSString *imgSrc = [imgSrcs objectAtIndex:i];
        NSString *imgWidth = [imgWidths objectAtIndex:i];
        NSString *photoPageURL = [photoPageURLs objectAtIndex:i];
        NSString *title = [titles objectAtIndex:i];
        
        FPPhoto *photo = [[[FPPhoto alloc] initWithImgSrc:imgSrc imgWidth:[imgWidth integerValue]] autorelease];
        [photo setPhotoPageURL:[NSURL URLWithString:photoPageURL]];
        [photo setTitle:title];
        [photo setYear:year];
        [photo setMonth:month];
        [photo setPositionInMonth:positionInMonthOffset + i + 1];
        [photos addObject:photo];
    }
    
    return photos;
}


- (void)finishedWithData:(NSData *)data {
    
    BABeginUnitOfWork(parsePhotosOp);
    
    NSArray *photos = [[NSArray new] autorelease];
    
    TFHpple * xpathEngine = [[[TFHpple alloc] initWithHTMLData:data] autorelease];
    
    NSArray *elements = [xpathEngine search:@"//h2/span[@class='mw-headline']"];
    NSUInteger xpathIdx = 1;
    for (TFHppleElement *e in elements) {
        NSArray *components = [[e content] componentsSeparatedByString:@" "]; 

        // skip if invalid content found
        if ([components count] != 2) {
            // check if is the current month
            if ([components count] != 4) {
                // unknown headline
                continue;
            }
        }

        NSUInteger year = [(NSString *)[components objectAtIndex:1] integerValue];
        NSString *month = (NSString *)[components objectAtIndex:0];
        NSUInteger monthAsNumber = [self _monthWithMonthName:month];
        
        if ((_month != NSNotFound) && (_month != monthAsNumber)) {
            xpathIdx = xpathIdx + 1;
            continue;
        }
        
        if (year == 2009) {
            if ((monthAsNumber == 5) || (monthAsNumber == 6) || (monthAsNumber > 7)) {
                // april & july have two ul tags; we need to skip them for
                // the months that follow in the section
                xpathIdx = xpathIdx + 1;
            } else {
                // nothing to do
            }
        }

        NSArray *currentPhotos = [self _parsePhotosWithYear:year
                                                      month:monthAsNumber
                                                   xpathIdx:xpathIdx
                                                xpathEngine:xpathEngine
                                      positionInMonthOffset:0];
        if ([currentPhotos count]) {
            photos = [photos arrayByAddingObjectsFromArray:currentPhotos];
        }

        // heuristics. in April 2009 and July 2009 we have two <ul> tags
        if ((year == 2009) && ((monthAsNumber == 4) || (monthAsNumber == 7))) {
            xpathIdx = xpathIdx + 1;
            currentPhotos = [self _parsePhotosWithYear:year
                                                 month:monthAsNumber
                                              xpathIdx:xpathIdx
                                           xpathEngine:xpathEngine
                                 positionInMonthOffset:[photos count]];
            if ([currentPhotos count]) {
                photos = [photos arrayByAddingObjectsFromArray:currentPhotos];
            }
        }
        
        if (_month == monthAsNumber) {
            break;
        }
            
        xpathIdx = xpathIdx + 1;
    }
    
    //BAEndUnitOfWork(parsePhotosOp);

    NSObject *delegateAsObject = (NSObject *)_delegate;
    [delegateAsObject performSelectorOnMainThread:@selector(didParsePhotos:)
                                       withObject:photos
                                    waitUntilDone:NO];
}


- (void)failedWithError:(NSError *)error {
    
    [error printErrorToConsoleWithMessage:@"Failed to parse photos"];
    
    // nothing was fetched
    NSObject *delegateAsObject = (NSObject *)_delegate;
    [delegateAsObject performSelectorOnMainThread:@selector(didParsePhotos:)
                                       withObject:[[NSArray new] autorelease]
                                    waitUntilDone:NO];
}


@end
