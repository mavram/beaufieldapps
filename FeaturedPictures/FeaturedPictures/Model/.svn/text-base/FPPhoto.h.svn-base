//
//  FPPhoto.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-05.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"


@interface FPPhoto : NSObject {
    
}


@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) BOOL isStarred;

@property (nonatomic, retain) NSString *thumbGeneratorURL;
@property (nonatomic, retain) NSString *photoPageURL;
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, assign) NSUInteger month;
@property (nonatomic, assign) NSUInteger positionInMonth;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSDate *creationDate;


+ (NSString *)monthNameWithName:(NSUInteger)month;


+ (BOOL)createSchemaSQL:(FMDatabase *)db;

+ (NSUInteger)currentMonth;
+ (NSUInteger)currentYear;
+ (NSUInteger)firstYear;

+ (NSUInteger)numberOfPhotos;
+ (NSArray *)photosWithYear:(NSUInteger)year month:(NSUInteger)month;
+ (NSArray *)allStarredPhotos;
+ (FPPhoto *)photoWithPhotoPageURL:(NSString *)photoPageURL;

- (id)initWithImgSrc:(NSString *)imgSrc imgWidth:(NSUInteger)imgWidth;

- (BOOL)saveToDatabase;

- (NSString *)monthName;

- (NSString *)fullResolutionPhotoURL;

// Local Cache methods
- (NSString*)thumbGeneratorURLWithWidth:(NSUInteger)width;
- (NSString*)cacheURLWithWidth:(NSUInteger)width;

- (BOOL)hasCachedImageWithWidth:(NSUInteger)width;
- (UIImage *)cachedImageWithWidth:(NSUInteger)width;

@end
