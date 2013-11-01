//
//  NSErrorExtensions.h
//  BeaufieldUtilitiesLib
//
//  Created by mircea on 10-07-28.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef __DEBUG__
    #define BADebugMessage( s, ... ) NSLog( @":(%d):%s:%@", __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
    #define BADebugMessage( s, ... ) 
#endif
    

#define BAInfoMessage( s, ... ) NSLog( @":(%d):%s:%@", __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define BAErrorMessage( s, ... ) NSLog( @":(%d):%s:%@", __LINE__, __PRETTY_FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )


#ifdef __DEBUG_EXECUTION_TIME__
    #define BADefineUnitOfWork( id ) static CFAbsoluteTime __unitOfWork_##id;
    #define BABeginUnitOfWork( id ) __unitOfWork_##id = CFAbsoluteTimeGetCurrent();
    #define BAEndUnitOfWork( id ) BAInfoMessage(@"<%s> in %f seconds", #id, CFAbsoluteTimeGetCurrent() - __unitOfWork_##id);
#else
    #define BADefineUnitOfWork( id )
    #define BABeginUnitOfWork( id )
    #define BAEndUnitOfWork( id )
#endif


@interface NSError(__LoggingExtensions__)

- (void)printErrorToConsoleWithMessage:(NSString *)message;

@end
