//
//  NSErrorExtensions.m
//  BeaufieldUtilitiesLib
//
//  Created by mircea on 10-07-28.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//


#import "NSErrorExtensions.h"



@implementation NSError(__LoggingExtensions__)


- (void)printErrorToConsoleWithMessage:(NSString *)message {
    BAErrorMessage(@"domain<%d> code<%d> description<%@> message<%@>",
                   self.domain, self.code, self.localizedDescription, message);
}


@end
