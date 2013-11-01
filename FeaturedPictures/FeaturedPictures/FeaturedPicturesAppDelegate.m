//
//  FeaturedPicturesAppDelegate.m
//  FeaturedPictures
//
//  Created by Mircea Avram on 11-05-04.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "FeaturedPicturesAppDelegate.h"
#import "NSErrorExtensions.h"
#import "FPWikipediaManager.h"


@implementation FeaturedPicturesAppDelegate


static NSUInteger __networkIndicatorCounter = 0;
static BOOL __isOffline = NO;


@synthesize window = _window;


#pragma mark - Application's Singleton


+ (FeaturedPicturesAppDelegate *)sharedAppDelegate {
    return (FeaturedPicturesAppDelegate *)[[UIApplication sharedApplication] delegate];
}


+ (FeaturedPicturesController *)featuredPicturesController {
    return (FeaturedPicturesController *)[[[FeaturedPicturesAppDelegate sharedAppDelegate] window] rootViewController];
}


#pragma mark - Application's Network Indicator


+ (void)startNetworkIndicator {
    
    __networkIndicatorCounter += 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


+ (void)stopNetworkIndicator {
    
    assert(__networkIndicatorCounter > 0);
    __networkIndicatorCounter -= 1;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (__networkIndicatorCounter != 0);
}


+ (BOOL)isOffline {
    return __isOffline;
}


#pragma mark - Application's Directories


+ (NSURL *)applicationDocumentsDirectory {
    
    // get documents directory
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


+ (NSURL *)applicationCacheDirectory {
    
    // get cache directory
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Network failure notification


- (void)didDetectNetworkFailure:(NSNotification*)note {
    
    NSError *error = (NSError *)[note object];
    [error printErrorToConsoleWithMessage:@"Did detect network error !!!"];
    
    // error codes for offline mode
    if (([error code] != EINVAL) &&
        ([error code] != NSURLErrorNotConnectedToInternet)) {
        return;
    }
    
    if (__isOffline == NO) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Info"
                                                             message:@"The Internet connection appears to be offline. Application will run in offline mode."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }
    __isOffline = YES;
}


#pragma mark - Application's Life Cycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // initialize the model
    _model = [FPModel sharedModel];
    NSURL *documentsDirectory = [FeaturedPicturesAppDelegate applicationDocumentsDirectory];
    [_model setSqliteURL:[documentsDirectory URLByAppendingPathComponent:@"FeaturedPictures.sqlite"]];
    
    // sqlite store initialization
    if (![[FPModel sharedModel] initSqliteStore]) {
        // no recovery; let user know and exit
        [[[[UIAlertView alloc] initWithTitle:@"Error"
                                     message:NSLocalizedString(@"Failed to initialize the application. If the problem persist please remove current version and try to reinstall.", nil)
                                    delegate:self
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];
        return NO;
    }
    
    
    // register for network failures notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDetectNetworkFailure:)
                                                 name:kDidDetectNetworkFailureNotification
                                               object:nil];
    
    // init with most recent year/month
    FeaturedPicturesController *featuredPicturesController = [[FeaturedPicturesController new] autorelease];
    
    // init UI
    [_window setBackgroundColor:[UIColor blackColor]];
    [_window setRootViewController:featuredPicturesController];
    [_window makeKeyAndVisible];        
    
    return YES;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_window release];
    [_model release];
    
    [super dealloc];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[FeaturedPicturesAppDelegate featuredPicturesController] syncronizeWithWikimedia];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	
    // reset offline status
    __isOffline = NO;
}


#pragma mark - AlertView Delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // just exit
    exit(0);
}


@end
