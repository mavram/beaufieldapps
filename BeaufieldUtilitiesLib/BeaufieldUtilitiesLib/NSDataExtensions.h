//
//  NSDataExtensions.h
//  BeaufieldUtilitiesLib
//
//  Created by mircea on 10-08-11.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData(__WriteToFileExtension__)

- (BOOL)writeToFileEx:(NSString *)path;
- (BOOL)writeToFileEx:(NSString *)path error:(NSError **)error;

@end
