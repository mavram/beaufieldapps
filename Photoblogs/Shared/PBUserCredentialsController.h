//
//  PBUserCredentialsController.h
//  Photoblogs
//
//  Created by mircea on 10-07-26.
//  Copyright 2010 BeaufieldAtelier. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol PBUserCredentialsDelegate <NSObject>
- (void)authenticateUsername:(NSString *)username
                    password:(NSString *)password;
@end


@interface PBUserCredentialsController : UIViewController<UITextFieldDelegate> {

@private
    IBOutlet UIView *grouppingView;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIActivityIndicatorView *activityIndicatorView;
}


@property(nonatomic, retain) IBOutlet UIView *grouppingView;
@property(nonatomic, retain) IBOutlet UITextField *usernameField;
@property(nonatomic, retain) IBOutlet UITextField *passwordField;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSString *password;
@property(nonatomic, assign) id<PBUserCredentialsDelegate> delegate;


- (id)initWithDelegate:(id<PBUserCredentialsDelegate>) delegate username:(NSString *)username password:(NSString *)password;
- (void)resetCredentials;



@end
