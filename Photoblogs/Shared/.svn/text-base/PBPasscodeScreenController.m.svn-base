//
//  PBPasscodeScreenController.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-01-22.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import "PBPasscodeScreenController.h"
#import "NSErrorExtensions.h"



@implementation PBPasscodeScreenController


@synthesize grouppingView = _grouppingView;
@synthesize passcodeLabel = _passcodeLabel;
@synthesize passcodeDigit1 = _passcodeDigit1;
@synthesize passcodeDigit2 = _passcodeDigit2;
@synthesize passcodeDigit3 = _passcodeDigit3;
@synthesize passcodeDigit4 = _passcodeDigit4;
@synthesize delegate = _delegate;
@synthesize passcodeToValidate = _passcodeToValidate;


- (id)initWithDelegate:(id<PBPasscodeScreenDelegate>) delegate; {

    NSString *nibTitle = @"PBPasscodeScreenController_iPad";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        nibTitle = @"PBPasscodeScreenController_iPhone";
    }
    self = [super initWithNibName:nibTitle bundle:nil];
    if (self) {
        [self setDelegate:delegate];
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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad {
	
	[super viewDidLoad];
}

- (void)viewDidUnload {

    [super viewDidUnload];
    
    [self setGrouppingView:nil];
	[self setPasscodeLabel:nil];
	[self setPasscodeDigit1:nil];
	[self setPasscodeDigit2:nil];
	[self setPasscodeDigit3:nil];
	[self setPasscodeDigit4:nil];
    [self setPasscodeToValidate:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // Observe keyboard hide and show notifications to resize the view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
	[_passcodeDigit1 becomeFirstResponder];
}


- (void)viewDidDisappear:(BOOL)animated {
	
	[super viewDidDisappear:animated];

    // remove self as observer for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)dealloc {
    [super dealloc];

    [_grouppingView release];
	[_passcodeLabel release];
	[_passcodeDigit1 release];
	[_passcodeDigit2 release];
	[_passcodeDigit3 release];
	[_passcodeDigit4 release];
    [_passcodeToValidate release];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	[self performSelector:@selector(textFieldShouldReturn:) withObject:textField afterDelay:0.1];

	return YES;
}


- (void)_resetPasscodeDigits {

    [_passcodeDigit4 setText:@""];
    [_passcodeDigit3 setText:@""];
    [_passcodeDigit2 setText:@""];
    [_passcodeDigit1 becomeFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
    if ([textField isEqual:_passcodeDigit1]) {
        [_passcodeDigit2 becomeFirstResponder];
	} else if ([textField isEqual:_passcodeDigit2]) {
		[_passcodeDigit3 becomeFirstResponder];
	} else if ([textField isEqual:_passcodeDigit3]) {
		[_passcodeDigit4 becomeFirstResponder];
	} else if ([textField isEqual:_passcodeDigit4]) {
        // if no password to validate get it from delegate
        if (_passcodeToValidate == nil) {
            [self setPasscodeToValidate:[_delegate passcodeToValidate]];
        }

		NSString *currentPasscodeToValidate = @"";
		currentPasscodeToValidate = [currentPasscodeToValidate stringByAppendingString:[_passcodeDigit1 text]];
		currentPasscodeToValidate = [currentPasscodeToValidate stringByAppendingString:[_passcodeDigit2 text]];
		currentPasscodeToValidate = [currentPasscodeToValidate stringByAppendingString:[_passcodeDigit3 text]];
		currentPasscodeToValidate = [currentPasscodeToValidate stringByAppendingString:[_passcodeDigit4 text]];
        
        // are we setting a new passcode ?
        if (_passcodeToValidate == nil) {
            [self setPasscodeToValidate:currentPasscodeToValidate];

            [_passcodeLabel setText:@"Confirm Passcode"];
            [self _resetPasscodeDigits];

            return NO;
        }
        
        // is the passcode correct ?
        if (![_passcodeToValidate isEqualToString:currentPasscodeToValidate]) {
            [self setPasscodeToValidate:nil];

            [_passcodeLabel setText:@"Enter Passcode"];            
            [self _resetPasscodeDigits];
            
            return NO;
        }
        
        [_delegate didValidatePasscode:_passcodeToValidate];
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
	[_grouppingView setCenter:centerWhileEditing];
	
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
	[_grouppingView setCenter:centerWhileEditing];
    
	[UIView commitAnimations];
}



@end
