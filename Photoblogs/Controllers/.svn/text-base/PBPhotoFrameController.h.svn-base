//
//  PBPhotoFrameController.h
//  Photoblogs
//
//  Created by Mircea Avram on 10-10-22.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBPhoto.h"
#import "PBEntry.h"
#import "PBPhotoFrameView.h"


@interface PBPhotoFrameController : NSObject<PBPhotoFrameDelegate> {

}

@property(nonatomic, retain, readonly) PBPhotoFrameView *view;
@property(nonatomic, retain) PBPhoto *photo;
@property(nonatomic, retain) PBEntry *entry;
@property(nonatomic) NSUInteger photoIdx;


- (id)initWithPhoto:(PBPhoto *)photo entry:(PBEntry *) entry photoIdx:(NSUInteger)photoIdx;


@end
