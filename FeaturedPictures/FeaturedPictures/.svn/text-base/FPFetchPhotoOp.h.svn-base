//
//  FPFetchPhotoOp.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-05.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FPFetchHTTPDataOperation.h"
#import "FPPhoto.h"


@protocol FPFetchPhotoOpDelegate <NSObject>

- (void)didFetchPhoto:(FPPhoto *)photo withWidth:(NSUInteger)photoWidth;
- (void)didFailToFetchPhoto:(FPPhoto *)photo withWidth:(NSUInteger)photoWidth forceFullResolution:(BOOL)forceFullResolution;

@end


@interface FPFetchPhotoOp : FPFetchHTTPDataOperation {
}


@property (nonatomic, retain) FPPhoto *photo;
@property (nonatomic, assign) NSUInteger photoWidth;
@property (nonatomic, assign) BOOL forceFullResolution;
@property (nonatomic, assign) id<FPFetchPhotoOpDelegate> delegate;


- (id)initWithPhoto:(FPPhoto *)photo photoWidth:(NSUInteger)photoWidth forceFullResolution:(BOOL)forceFullResolution;


@end
