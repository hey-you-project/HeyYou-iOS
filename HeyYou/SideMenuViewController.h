//
//  SideMenuViewController.h
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"

@interface SideMenuViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *userPostsView;
@property (weak, nonatomic) IBOutlet UIView *bestofView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *heyYouTitle;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIView *createView;
@property (weak, nonatomic) IBOutlet UITextField *createUsernameField;
@property (weak, nonatomic) IBOutlet UITextField *createPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *createEmailField;
@property (weak, nonatomic) IBOutlet UIView *birthdayPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *birthdayPicker;

@end

typedef NS_ENUM(NSInteger, MenuState) {
  MenuStateLoggedOut,
  MenuStateLoggedIn,
  MenuStateLoginScreen,
  MenuStateCreateAccountScreen
};