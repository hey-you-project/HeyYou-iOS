//
//  SideMenuViewController.h
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"
@import MessageUI;

@interface SideMenuViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *userPostsView;
@property (weak, nonatomic) IBOutlet UIView *bestofView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *createView;
@property (weak, nonatomic) IBOutlet UIView *birthdayPickerView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonOne;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonTwo;

@property (weak, nonatomic) IBOutlet UILabel *userDotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *heyYouTitle;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatPassword;


@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldTwo;

@property (weak, nonatomic) IBOutlet UITextField *createEmailField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logInConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logOutConstraint;

@property (weak, nonatomic) IBOutlet UIPickerView *birthdayPicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blueEffectView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

typedef NS_ENUM(NSInteger, MenuState) {
  MenuStateLogIn,
  MenuStateLogOut,
  MenuStateCreateAccountScreen
};