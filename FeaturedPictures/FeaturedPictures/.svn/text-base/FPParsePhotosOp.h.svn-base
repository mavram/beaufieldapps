//
//  FPParsePhotosOp.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-05.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FPFetchHTTPDataOperation.h"


@protocol FPParsePhotosOpDelegate <NSObject>

- (void)didParsePhotos:(NSArray *)photos;

@end


@interface FPParsePhotosOp : FPFetchHTTPDataOperation {

@private
    NSUInteger _month;
}


@property (nonatomic, assign) id<FPParsePhotosOpDelegate> delegate;


- (id)initWithYear:(NSUInteger)year month:(NSUInteger)month dumpMode:(BOOL)dumpMode;


@end
