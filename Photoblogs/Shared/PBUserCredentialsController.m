//
//  PBUserCredentialsController.m
//  Photoblogs
//
//  Created by mircea on 10-07-26.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NSErrorExtensions.h"
#import "PBUserCredentialsController.h"


@implementation PBUserCredentialsController


@synthesize grouppingView;
@synthesize usernameField;
@synthesize passwordField;
@synthesize activityIndicatorView;

@synthesize username = _username;
@synthesize password = _password;
@synthesize delegate = _delegate;


- (BOOL)_hasCredentials {
    
    // check if both username and password are set
    return (_username && [_username length] && _password && [_password length]);
}


- (id)initWithDelegate:(id<PBUserCredentialsDelegate>) delegate username:(NSString *)username password:(NSString *)password {
       
    NSString *nibTitle = @"PBUserCredentialsController_iPad";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibTitle = @"PBUserCredentialsController_iPhone";
    }
    self = [super initWithNibName:nibTitle bundle:nil];
    if (self) {
        [self setDelegate:delegate];
        [self setUsername:username];
        [self setPassword:password];
    }
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // iPhone supports only portrait
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            return YES;
        }
        return NO;
    }
    return YES;
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    if ([self _hasCredentials]) {
        [usernameField setHidden:YES];
        [passwordField setHidden:YES];
    }
}


- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    if (![self _hasCredentials]) {
        // remove self as observer for keyboard notifications        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }

    // release outlets
    [self setGrouppingView:nil];
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [self setActivityIndicatorView:nil];
}


- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if ([self _hasCredentials]) {
        [activityIndicatorView startAnimating];
        [_delegate authenticateUsername:_username password:_password];
    } else {
        // Observe keyboard hide and show notifications to resize the view appropriately.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

        // set username as first responder
        [usernameField becomeFirstResponder];
    }
}


- (void)viewDidDisappear:(BOOL)animated {
	
	[super viewDidDisappear:animated];
    
    // remove self as observer for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)dealloc {

    [grouppingView release];
    [usernameField release];
    [passwordField release];
    [activityIndicatorView release];
    
    [_username release];
    [_password release];

    [super dealloc];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if ([textField isEqual:usernameField]) {
        [passwordField becomeFirstResponder];
    } else {
        if ([activityIndicatorView isAnimating]) {
            // not re-entrant
            return NO;
        }
        
        NSString *username = [usernameField text];
        NSString *password = [passwordField text];
        
        [activityIndicatorView startAnimating];
        
        [_delegate authenticateUsername:username password:password];
    }

    return YES;
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    // get keyboard frame
    NSDictionary *userInfo = [notification userInfo];
    NSValue* keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // compute keyboard frame within view coordinates
    CGRect keyboardRect = [keyboardFrameValue CGRectValue];
    keyboardRect = [[self view] convertRect:keyboardRect fromView:nil];
	
    // compute visible frame
	CGRect visibleFrame = [[self view] bounds];
	visibleFrame.size.height = keyboardRect.origin.y;
	
    // get keyboard animation duration
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];
    
    // initialize animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animationDuration];
    
    // re-center credentials widget
	CGPoint centerWhileEditing = CGPointMake(CGRectGetMidX(visibleFrame), CGRectGetMidY(visibleFrame));
	[grouppingView setCenter:centerWhileEditing];
	
	[UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
	
	NSDictionary* userInfo = [notification userInfo];
	
    // get keyboard animation duration
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];
    
    // initialize animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animationDuration];
    
    // re-center within own's view
	CGPoint centerWhileEditing = CGPointMake(CGRectGetMidX([[self view] bounds]), CGRectGetMidY([[self view] bounds]));
	[grouppingView setCenter:centerWhileEditing];
    
	[UIView commitAnimations];
}


- (void)resetCredentials {
    
    [activityIndicatorView stopAnimating];
    [usernameField setHidden:NO];
    [usernameField setText:nil];
    [passwordField setHidden:NO];
    [passwordField setText:nil];
    [usernameField becomeFirstResponder];
    
    [self setUsername:nil];
    [self setPassword:nil];
}



@end
