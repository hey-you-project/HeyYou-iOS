//
//  SideMenuViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) CGAffineTransform userPostsOffstage;
@property (nonatomic) CGAffineTransform createAccountOffstage;
@property (nonatomic) CGAffineTransform bestofLoggedOut;
@property (nonatomic) CGAffineTransform titleOffstage;
@property (nonatomic) CGAffineTransform loginCreateOffstage;
@property (nonatomic) MenuState state;

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.usernameField.delegate = self;
  self.passwordField.delegate = self;
  
  //Set up animation speed
  self.duration = 0.5;
  
  //Set up transforms
  self.userPostsOffstage = CGAffineTransformMakeTranslation(-175, 0);
  self.createAccountOffstage = CGAffineTransformMakeTranslation(0, 150);
  self.bestofLoggedOut = CGAffineTransformMakeTranslation(0, -106);
  self.titleOffstage = CGAffineTransformMakeTranslation(0, -100);
  self.loginCreateOffstage = CGAffineTransformMakeTranslation(250, 0);
  
  if ([[NetworkController sharedController] token] != nil) {
    self.state = MenuStateLoggedIn;
  } else {
    self.state = MenuStateLoggedOut;
  }

  switch (self.state) {
    case MenuStateLoggedOut:
      //Set to logged out view
      self.userPostsView.transform = self.userPostsOffstage;
      self.bestofView.transform = self.bestofLoggedOut;
      break;
    case MenuStateLoggedIn:
      break;
    default:
      NSLog(@"Invalid menu state");
      break;
  }

  
  //Prepare default locations
  self.loginView.transform = self.loginCreateOffstage;
}

#pragma mark Button actions

- (IBAction)pressedLogin:(id)sender {
  switch (self.state) {
    case MenuStateLoggedOut:
    {
      self.state = MenuStateLoginScreen;
      [self addLoginAnimation];
      break;
    }
    case MenuStateLoginScreen:
    {
      [[NetworkController sharedController] fetchTokenWithUsername:self.usernameField.text password:self.passwordField.text completionHandler:^(NSString *error, bool success) {
        if (success) {
          self.state = MenuStateLoggedIn;
          NSLog(@"You are logged in!!!");
        }
      }];
      break;
    }
    default:
      break;
  }
}

#pragma mark Animation methods

- (void)addLoginAnimation {
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.heyYouTitle.transform = self.titleOffstage;
    self.bestofView.transform = CGAffineTransformMakeTranslation(-175, -106);
    self.createAccountOffstage = self.titleOffstage;
    self.loginView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:self.duration - 0.2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.heyYouTitle.text = @"Hey you, Log In!";
      self.heyYouTitle.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
      
    }];
  }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

@end
