//
//  FeaturedPicturesAppDelegate_iPhone.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FeaturedPicturesAppDelegate_iPhone.h"
#import "NSErrorExtensions.h"
#import "FeaturedPicturesGridController.h"
#import "FeaturedPicturesHeaderController.h"


extern CFAbsoluteTime __elapsedTimeSinceApplicationStarted;


@implementation FeaturedPicturesAppDelegate_iPhone


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // sizes (these should go first)
    [FeaturedPicturesHeaderController setHeight:64];
    [FeaturedPicturesGridController setHeight:64];
    [FeaturedPicturesGridController setThumbnailWidth:255];
    [FeaturedPicturesGridController setThumbnailInset:5];
    
    if (![super application:application didFinishLaunchingWithOptions:launchOptions]) {
        return NO;
    }
    
    // set status bar style
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
#ifdef __DEBUG_EXECUTION_TIME__
    BAInfoMessage(@"%f seconds", CFAbsoluteTimeGetCurrent() - __elapsedTimeSinceApplicationStarted);
#endif
    
    return YES;
}


- (void)dealloc {
    
	[super dealloc];
}


@end
