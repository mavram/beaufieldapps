//
//  NSDataExtensions.m
//  BeaufieldUtilitiesLib
//
//  Created by mircea on 10-08-11.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import "NSDataExtensions.h"
#import "NSErrorExtensions.h"


@implementation NSData(__WriteToFileExtension__)

- (BOOL)writeToFileEx:(NSString *)path {

    return [self writeToFileEx:path error:nil];
}

- (BOOL)writeToFileEx:(NSString *)path error:(NSError **)error {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 4000
    if ([self writeToFile:path options:NSDataWritingAtomic error:error] == NO) {
#else
    if ([self writeToFile:path options:NSAtomicWrite error:error] == NO) {
#endif
        [*error printErrorToConsoleWithMessage:[NSString stringWithFormat:@"Failed to write data to %@", path]];

        return NO;
    }
        
    return YES;    
}

@end
