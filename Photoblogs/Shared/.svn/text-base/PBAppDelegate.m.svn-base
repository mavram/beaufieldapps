//
//  PBAppDelegate.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-07.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBAppDelegate.h"
#import "PBSubscriptionsViewerController.h"
#import "NSErrorExtensions.h"
#import "PBModel.h"



extern CFAbsoluteTime __elapsedTimeSinceApplicationStarted;


@interface PBAppDelegate (__Internal__)

- (BOOL)needsPasscode;
- (BOOL)needsToResetUserCredentials;
- (void)resetUserCredentials;
- (NSString *)username;
- (NSString *)password;
- (void)saveUserCredentialsWithUsername:(NSString *)username password:(NSString *)password;    

@end


@implementation PBAppDelegate


static NSString *kResetCredentials  = @"resetCredentials";
static NSString *kPasscodeLock = @"passcodeLock";

static NSUInteger __networkIndicatorCounter = 0;
static CFAbsoluteTime __networkTime;

@synthesize window = _window;
@synthesize subscriptionsViewerController = _subscriptionsViewerController;
@synthesize navigationController = _navigationController;
@synthesize googleReaderAccount = _googleReaderAccount;
@synthesize isAuthenticating = _isAuthenticating;


+ (BOOL)isLiteVersion {
    
#ifdef __LITE_VERSION__
    return YES;
#else
    return NO;
#endif
}


+ (PBAppDelegate *)sharedAppDelegate {
    return (PBAppDelegate *)[[UIApplication sharedApplication] delegate];
}


+ (void)startNetworkIndicator {

    if (__networkIndicatorCounter == 0) {
        __networkTime = CFAbsoluteTimeGetCurrent();
    }
    __networkIndicatorCounter += 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


+ (void)stopNetworkIndicator {
    
    assert(__networkIndicatorCounter > 0);
    __networkIndicatorCounter -= 1;
    
    if (__networkIndicatorCounter == 0) {        
#ifdef __DEBUG_NETWORK_EXECUTION_TIME__
        BAInfoMessage(@"%f seconds", CFAbsoluteTimeGetCurrent() - __networkTime);
#endif
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = (__networkIndicatorCounter != 0);
}



#pragma mark - Application Lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _isAuthenticating = NO;
    _subscriptionsViewerController = nil;
    
    // initialize the model
    _model = [PBModel sharedModel];
    NSURL *documentsDirectory = [PBAppDelegate applicationDocumentsDirectory];
    [_model setCoreDataURL:[documentsDirectory URLByAppendingPathComponent:@"PhotoBlogs.coredata"]];
    [_model setSqliteURL:[documentsDirectory URLByAppendingPathComponent:@"PhotoBlogs.sqlite"]];

    // initialize user credentials keychain wrapper
    _userCredentialsKeychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.beaufieldatelier.PhotoBlogsReader.GoogleReaderAccount" accessGroup:nil];

    if ([self needsToResetUserCredentials]) {
#ifdef __DEBUG_APP_LIFECYCLE__
        BADebugMessage(@"Resetting user credentials.");
#endif
        // reset user credentials
        [self resetUserCredentials];
    }
    
    // create google reader account, setup the delegate and setup
    // the credentials with keychain data
    _googleReaderAccount = [[PBGoogleReaderAccount alloc] init];
    [_googleReaderAccount setDelegate:self];
    [_googleReaderAccount setUserCredentialsWithUsername:[self username] password:[self password]];
    
    // set status bar style
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    }

    // trigger sqlite store initialization
    if (![[PBModel sharedModel] initSqliteStore]) {
        // no recovery; let user know and exit
        [[[[UIAlertView alloc] initWithTitle:@"Error"
                                     message:@"Failed to initialize the application. If the problem persist please remove current version and try to reinstall."
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
    
    // boostrap the UI
    if ([self needsPasscode]) {
        // needs passcode
        PBPasscodeScreenController *passcodeScreenController = [[[PBPasscodeScreenController alloc] initWithDelegate:self] autorelease];
        _navigationController = [[UINavigationController alloc] initWithRootViewController:passcodeScreenController];    
    } else {
        PBUserCredentialsController *userCredentialsController = [[[PBUserCredentialsController alloc] initWithDelegate:self
                                                                                                               username:[self username]
                                                                                                               password:[self password]] autorelease];
        _navigationController = [[UINavigationController alloc] initWithRootViewController:userCredentialsController];
    }
    [_navigationController setNavigationBarHidden:YES animated:NO];
    [_window addSubview:[_navigationController view]];
    [_window setBackgroundColor:[UIColor blackColor]];     
    [_window makeKeyAndVisible];        
        
#ifdef __DEBUG_EXECUTION_TIME__
    BAInfoMessage(@"%f seconds", CFAbsoluteTimeGetCurrent() - __elapsedTimeSinceApplicationStarted);
#endif

    return YES;
}


- (void)_showNeedsResetMessage {
    
    // show a message to user informing that credentials will be reset and exit
    [[[[UIAlertView alloc] initWithTitle:@"Info"
                                 message:@"'Credentials and Passcode' settings require application restart."
                                delegate:self
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil] autorelease] show];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
	// otherwise defaults might be stale
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    // prepare passcode screen
    if ([self needsPasscode]) {
        // if not active
        if (![[_navigationController topViewController] isKindOfClass:[PBPasscodeScreenController class]]) {
            [self _showNeedsResetMessage];
        }
    } else {
        if ([self needsToResetUserCredentials]) {
            [self _showNeedsResetMessage];
        } else {
            // nothing to do. credentials controller is already on the screen and
            // viewWillAppear will trigger authentication process
        }
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	
    // in case subscription editor is on we need to dismiss it
    // by the time didEnterBackground is processed in SubscriptionsViewController
    // modalViewController ivar is null
    if ([[_navigationController topViewController] modalViewController]) {
        [[_navigationController topViewController] dismissModalViewControllerAnimated:NO];
    }
    
    // prepare passcode screen
    if ([self needsPasscode]) {
        // if not active
        if (![[_navigationController topViewController] isKindOfClass:[PBPasscodeScreenController class]]) {
            PBPasscodeScreenController *passcodeScreenController = [[[PBPasscodeScreenController alloc] initWithDelegate:self] autorelease];
            [_navigationController setViewControllers:[NSArray arrayWithObject:passcodeScreenController] animated:NO];
        }
    } else if (![[_navigationController topViewController] isKindOfClass:[PBUserCredentialsController class]]) {
        PBUserCredentialsController *userCredentialsController = [[[PBUserCredentialsController alloc] initWithDelegate:self
                                                                                                               username:[self username]
                                                                                                               password:[self password]] autorelease];
        [_navigationController setViewControllers:[NSArray arrayWithObject:userCredentialsController] animated:NO];
    }
    
    [self setSubscriptionsViewerController:nil];
    
    // reset offline status
    [_googleReaderAccount setIsOffline:NO];
}


- (void)applicationWillTerminate:(UIApplication *)application {

    // Saves changes in the application's managed object context before the application terminates.
    [[PBModel sharedModel] saveContext];
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_subscriptionsViewerController release];
    [_window release];
    [_navigationController release];
    [_model release];
    [_userCredentialsKeychainWrapper release];
    [_googleReaderAccount release];

    [super dealloc];
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


#pragma mark - AlertView Delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    // just exit
    exit(0);
}



#pragma - Passcode management


- (BOOL) needsPasscode {
    
    PBAppSettings *appSettings = [[PBModel sharedModel] appSettings];
    
    // if there is a passcode present we need to show the lock screen
    if ([appSettings passcode] != nil) {
        return YES;
    }
    
    // check if we need to set a new one?
	return [[NSUserDefaults standardUserDefaults] boolForKey:kPasscodeLock];
}



#pragma mark - PBPasscodeScreenDelegate


- (NSString *)passcodeToValidate {
    
    return [[[PBModel sharedModel] appSettings] passcode];
}


- (void)didValidatePasscode:(NSString *)passcode {	
    
    PBAppSettings *appSettings = [[PBModel sharedModel] appSettings];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPasscodeLock] == NO) {
        // clear passcode since is not needed anymore
        [appSettings setPasscode:nil];
        [[PBModel sharedModel] saveContext];
    } else {
        // save if is a new passcode
        if ([appSettings passcode] == nil) {
            [appSettings setPasscode:passcode];
            [[PBModel sharedModel] saveContext];
        }
    }
    
    if ([self needsToResetUserCredentials]) {
        [self _showNeedsResetMessage];
    } else {
        PBUserCredentialsController *userCredentialsController = [[[PBUserCredentialsController alloc] initWithDelegate:self
                                                                                                               username:[self username]
                                                                                                               password:[self password]] autorelease];
        [_navigationController setViewControllers:[NSArray arrayWithObject:userCredentialsController] animated:YES];
    }
}


#pragma mark - Credentials management


- (BOOL)needsToResetUserCredentials {

    // did the user asked for reset?
    return [[NSUserDefaults standardUserDefaults] boolForKey:kResetCredentials];
}


- (NSString *)username {
    
    // username
    return [_userCredentialsKeychainWrapper objectForKey:(id)kSecAttrAccount];
}


- (NSString *)password {

    // password
    return [_userCredentialsKeychainWrapper objectForKey:(id)kSecValueData];
}


- (void)resetUserCredentials {
	
    // reset keychain data
	[_userCredentialsKeychainWrapper resetKeychainItem];	

    // reset model stores
    [_model resetCoreDataStore];
    [_model resetSqliteStore];
    
    // reset user settings flag
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kResetCredentials];
}


- (void)saveUserCredentialsWithUsername:(NSString *)username password:(NSString *)password {
	
    NSString *u = [self username];
    NSString *p = [self password];

    // If we don't check for value keychain wrapper throws an exception
    // when trying to overwrite existing values
    if (!u || ([u length] == 0)) {
        [_userCredentialsKeychainWrapper setObject:username forKey:(id)kSecAttrAccount];
    }
    if (!p || ([p length] == 0)) {
        [_userCredentialsKeychainWrapper setObject:password forKey:(id)kSecValueData];
    }
}



#pragma mark - PBGoogleReaderAccountDelegate


- (void)didAuthenticateUsername:(NSString *)username password:(NSString *)password {
    
    // internally it will save only if needed
    [self saveUserCredentialsWithUsername:username password:password];
    
#ifdef __DEBUG_APP_LIFECYCLE__
    BADebugMessage(@"Did authenticate <%@>.", username);
#endif
    
    // at this point we can start the UI
    _subscriptionsViewerController = [PBSubscriptionsViewerController new];
    [_navigationController setViewControllers:[NSArray arrayWithObject:_subscriptionsViewerController] animated:YES];
}


- (void)didFailToAuthenticate {
    
    UIViewController *topController = [_navigationController topViewController];
    if ([topController isKindOfClass:[PBUserCredentialsController class]]) {
        PBUserCredentialsController *userCredentialsController = (PBUserCredentialsController *)topController;
        [userCredentialsController resetCredentials];
    } else {
        PBUserCredentialsController *userCredentialsController = [[[PBUserCredentialsController alloc] initWithDelegate:self
                                                                                                               username:nil
                                                                                                               password:nil] autorelease];
        [_navigationController setViewControllers:[NSArray arrayWithObject:userCredentialsController] animated:YES];
    }
}



#pragma mark - SRUserCredentialsDelegate


- (void)authenticateUsername:(NSString *)username
                    password:(NSString *)password {
    
    // set Google Reader Account credentails with latest credentials data
    [_googleReaderAccount setUserCredentialsWithUsername:username password:password];
    // start authentication
    [_googleReaderAccount authenticate];
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

    // if already in offline mode; silently drop the other messages
    if (![_googleReaderAccount isOffline]) {    
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Info"
                                                             message:@"The Internet connection appears to be offline. Application will run in offline mode."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }    
    [_googleReaderAccount setIsOffline:YES];
    
    // if we are authenticating and offline show subscriptions viewer 
    UIViewController *topController = [_navigationController topViewController];
    if ([topController isKindOfClass:[PBUserCredentialsController class]]) {
        // at this point we can start the UI
        _subscriptionsViewerController = [PBSubscriptionsViewerController new];
        [_navigationController setViewControllers:[NSArray arrayWithObject:_subscriptionsViewerController] animated:YES];
    }

}



@end
