//
//  PBAppDelegate.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-07.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PBGoogleReaderAccount.h"
#import "PBUserCredentialsController.h"
#import "PBModel.h"
#import "KeychainItemWrapper.h"
#import "PBPasscodeScreenController.h"
#import "PBSubscriptionsViewerController.h"


@interface PBAppDelegate : NSObject <UIApplicationDelegate, SRGoogleReaderAccountDelegate, PBUserCredentialsDelegate, PBPasscodeScreenDelegate> {

@private
    PBModel *_model;
    KeychainItemWrapper *_userCredentialsKeychainWrapper;
}


@property (nonatomic, retain) PBSubscriptionsViewerController *subscriptionsViewerController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain, readonly) UINavigationController *navigationController;
@property (nonatomic, retain, readonly) PBGoogleReaderAccount *googleReaderAccount;
@property (nonatomic, readonly) BOOL isAuthenticating;


+ (BOOL)isLiteVersion;


+ (PBAppDelegate *)sharedAppDelegate;

+ (void)startNetworkIndicator;
+ (void)stopNetworkIndicator;

+ (NSURL *)applicationDocumentsDirectory;
+ (NSURL *)applicationCacheDirectory;


@end
