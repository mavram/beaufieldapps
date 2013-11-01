//
//  main.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <UIKit/UIKit.h>

CFAbsoluteTime __elapsedTimeSinceApplicationStarted;

int main(int argc, char *argv[]) {
    
    __elapsedTimeSinceApplicationStarted = CFAbsoluteTimeGetCurrent();

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
