//
//  PBAppSettings.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-09.
//  Copyright (c) 2011 Beaufield Atelier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PBAppSettings : NSManagedObject {

}


@property (nonatomic, retain) NSString * passcode;
@property (nonatomic, retain) NSNumber * synchronizeTimeInterval;


@end
