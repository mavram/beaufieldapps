//
//  FPModel.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-04.
//  Copyright 2010 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"


@interface FPModel : NSObject {
    
@private
    FMDatabase *_db;
    NSUInteger *_dbCounter;

}


@property (nonatomic, retain) NSURL *sqliteURL;


+ (FPModel*)sharedModel;

- (FMDatabase *)DB;
- (void)releaseDB;

- (BOOL)initSqliteStore;
- (BOOL)resetSqliteStore;


@end
