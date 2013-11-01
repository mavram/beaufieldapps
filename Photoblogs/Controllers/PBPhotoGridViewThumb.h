//
//  PBPhotoGridViewThumb.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-04-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBGridViewThumb.h"
#import "PBEntry.h"


extern NSString *kDidFetchThumbPhotoNotification;


@interface PBPhotoGridViewThumb : PBGridViewThumb {
 
}

@property(nonatomic, assign) NSObject *parent;
@property(nonatomic, retain) PBEntry *entry;


- (id)initWithEntry:(PBEntry *)entry parent:(NSObject*)parent;


@end
