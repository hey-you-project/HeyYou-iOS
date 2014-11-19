//
//  SideMenuViewController.h
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"

@interface SideMenuViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *userPostsView;
@property (weak, nonatomic) IBOutlet UIView *bestofView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *heyYouTitle;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

typedef NS_ENUM(NSInteger, MenuState) {
  MenuStateLoggedOut,
  MenuStateLoggedIn,
  MenuStateLoginScreen,
  MenuStateCreateAccountScreen
};