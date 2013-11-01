//
//  FeaturedPicturesAppDelegate_iPad.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FeaturedPicturesAppDelegate_iPad.h"
#import "NSErrorExtensions.h"
#import "FeaturedPicturesHeaderController.h"
#import "FeaturedPicturesGridController.h"


extern CFAbsoluteTime __elapsedTimeSinceApplicationStarted;


@implementation FeaturedPicturesAppDelegate_iPad


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // sizes (these should go first)
    [FeaturedPicturesHeaderController setHeight:110];
    [FeaturedPicturesGridController setHeight:128];
    [FeaturedPicturesGridController setThumbnailWidth:256];
    [FeaturedPicturesGridController setThumbnailInset:7];
    
    if (![super application:application didFinishLaunchingWithOptions:launchOptions]) {
        return NO;
    }
    
#ifdef __DEBUG_EXECUTION_TIME__
    BAInfoMessage(@"%f seconds", CFAbsoluteTimeGetCurrent() - __elapsedTimeSinceApplicationStarted);
#endif
    
    return YES;
}


- (void)dealloc {
	[super dealloc];
}


@end
