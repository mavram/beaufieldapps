//
//  PBPasscodeScreenController.h
//  Photoblogs
//
//  Created by Mircea Avram on 11-01-22.
//  Copyright 2011 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol PBPasscodeScreenDelegate <NSObject>

- (NSString *)passcodeToValidate;
- (void)didValidatePasscode:(NSString *)passcode;

@end


@interface PBPasscodeScreenController : UIViewController <UITextFieldDelegate> {

}


@property(nonatomic, retain) IBOutlet UIView *grouppingView;
@property(nonatomic, retain) IBOutlet UILabel* passcodeLabel;
@property(nonatomic, retain) IBOutlet UITextField* passcodeDigit1;
@property(nonatomic, retain) IBOutlet UITextField* passcodeDigit2;
@property(nonatomic, retain) IBOutlet UITextField* passcodeDigit3;
@property(nonatomic, retain) IBOutlet UITextField* passcodeDigit4;

@property(nonatomic, assign) id<PBPasscodeScreenDelegate> delegate;
@property(nonatomic, retain) NSString *passcodeToValidate;


- (id)initWithDelegate:(id<PBPasscodeScreenDelegate>) delegate;


@end

