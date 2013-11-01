//
//  GDataQueryGoogleReader.m
//  GoogleReaderLib
//
//  Created by mircea on 10-07-05.
//  Copyright BeaufieldAtelier 2010. All rights reserved.
//


#import "GDataQueryGoogleReader.h"


static NSString *const kCountParamName = @"n";
static NSString *const kOrderParamName = @"r";
static NSString *const kStartTimeParamName = @"ot";
static NSString *const kExcludeTargetParamName = @"xt";
static NSString *const kContinuationParamName = @"c";

static NSString *const kOrderAscendingValue = @"o";
static NSString *const kOrderDescendingValue = @"d";


@implementation GDataQueryGoogleReader


+ (GDataQueryGoogleReader *)readerQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}


- (NSInteger)count {
    return [super intValueForParameterWithName:kCountParamName
                         missingParameterValue:0];
}

- (void)setCount:(NSInteger)number {
    [self addCustomParameterWithName:kCountParamName
                            intValue:number
                      removeForValue:0];
}

- (NSDate *)startTime {
    return [[self dateTimeForParameterWithName:kStartTimeParamName] date];
}

- (void)setStartTime:(NSDate *)date {
    GDataDateTime* dateTime = [GDataDateTime dateTimeWithDate:date timeZone:nil];
    [self addCustomParameterWithName:kStartTimeParamName dateTime:dateTime];
    // start_time only works for order r=o mode
    [self addCustomParameterWithName:kOrderParamName value:kOrderAscendingValue];
}

- (NSString *)continuation {
    return [self valueForParameterWithName:kContinuationParamName];
}

- (void)setContinuation:(NSString *)str {
  [self addCustomParameterWithName:kContinuationParamName
                             value:str];
}

- (NSString *)excludeTarget {
    return [self valueForParameterWithName:kExcludeTargetParamName];
}

- (void)setExcludeTarget:(NSString *)str {
    [self addCustomParameterWithName:kExcludeTargetParamName
                               value:str];
}


@end
