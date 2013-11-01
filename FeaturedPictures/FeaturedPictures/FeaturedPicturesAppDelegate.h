//
//  FeaturedPicturesAppDelegate.h
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FPModel.h"
#import "FeaturedPicturesController.h"


@interface FeaturedPicturesAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    
@private
    FPModel *_model;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;


+ (FeaturedPicturesAppDelegate *)sharedAppDelegate;
+ (FeaturedPicturesController *)featuredPicturesController;

+ (void)startNetworkIndicator;
+ (void)stopNetworkIndicator;

+ (BOOL)isOffline;

+ (NSURL *)applicationDocumentsDirectory;
+ (NSURL *)applicationCacheDirectory;


@end
