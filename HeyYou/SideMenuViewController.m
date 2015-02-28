//
//  SideMenuViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "SideMenuViewController.h"
#import "NSString+Validate.h"
#import "ContainerViewController.h"
#import "Colors.h"
#import "TermsOfUseViewController.h"


@interface SideMenuViewController ()

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) CGAffineTransform userPostsOffstage;
@property (nonatomic) CGAffineTransform createAccountOffstage;
@property (nonatomic) CGAffineTransform bestofLoggedOut;
@property (nonatomic) CGAffineTransform titleOffstage;
@property (nonatomic) CGAffineTransform loginCreateOffstage;
@property (nonatomic) MenuState state;
@property (nonatomic, strong) TermsOfUseViewController *termsVC;

@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *dateArray;
@property (nonatomic, strong) NSMutableArray *yearArray;

@property (nonatomic, strong) NSCalendar *localCalendar;

@property (nonatomic, strong) UIColor *headerColor;
@property (nonatomic, strong) NSString *termsOfUse;
@property (nonatomic, strong) NSString *privacyPolicy;

@property BOOL termsVCActive;
@property BOOL deviceHasShortScreen;
@property BOOL deviceHasKindaShortScreen;

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.usernameField.delegate = self;
  self.passwordField.delegate = self;
  self.createEmailField.delegate = self;
  self.birthdayPicker.delegate = self;
  self.birthdayPicker.dataSource = self;
  self.headerColor = [Colors flatBlue];
  self.termsVCActive = false;
  
  self.loginView.backgroundColor = [Colors flatYellow];
  
  NSArray *textFieldArray = @[self.usernameField, self.passwordField, self.createEmailField, self.passwordFieldTwo];
  for (UITextField *textField in textFieldArray) {
    textField.layer.shadowColor = [[UIColor blackColor] CGColor];
    textField.layer.shadowOpacity = 0.6;
    textField.layer.shadowRadius = 2.0;
    textField.layer.shadowOffset = CGSizeMake(0, 2);
    textField.clipsToBounds = false;
  }
  
  //Set up animation speed
  self.duration = 0.5;
  
  //Set up transforms
  self.userPostsOffstage = CGAffineTransformMakeTranslation(-175, 0);
  self.createAccountOffstage = CGAffineTransformMakeTranslation(0, 250);
  self.bestofLoggedOut = CGAffineTransformMakeTranslation(0, -106);
  self.titleOffstage = CGAffineTransformMakeTranslation(0, -100);
  self.loginCreateOffstage = CGAffineTransformMakeTranslation(250, 0);
  NSString *savedUsername;
  
  if ([[NSUserDefaults standardUserDefaults] stringForKey:@"token"] != nil) {
    self.state = MenuStateLogOut;
    savedUsername = [[NetworkController sharedController] username];
  }
  switch (self.state) {
    case MenuStateLogIn:
      [self switchToLogin:false];
      break;
    case MenuStateLogOut:
      [self switchToLogoutWithUsername: savedUsername andAnimation:false];
      break;
    default:
      break;
  }
  
  //Prepare default locations
  self.loginView.transform = CGAffineTransformIdentity;
  self.cancelButtonOne.transform = CGAffineTransformIdentity;
  self.cancelButtonOne.alpha = 0;
  
  //Prepare date picker arrays
  self.monthArray = @[@"January",
                      @"February",
                      @"March",
                      @"April",
                      @"May",
                      @"June",
                      @"July",
                      @"August",
                      @"September",
                      @"October",
                      @"November",
                      @"December"];
  
  self.dateArray = @[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31];
  NSLocale *currentLocale = [NSLocale currentLocale];
  self.localCalendar = [currentLocale objectForKey:NSLocaleCalendar];
  NSDateComponents *components = [self.localCalendar components:NSCalendarUnitYear fromDate:[NSDate date]];
  NSInteger maxYear = [components year] - 18;
  NSInteger minYear = maxYear - 81;
  self.yearArray = [[NSMutableArray alloc] init];
  for (NSInteger i = maxYear; i >= minYear; i--) {
    [self.yearArray addObject:[NSNumber numberWithInteger:i]];
  }
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if ([[UIScreen mainScreen] bounds].size.height < 500) {
    self.deviceHasShortScreen = true;
  } else if ([[UIScreen mainScreen] bounds].size.height < 600) {
    self.deviceHasKindaShortScreen = true;
  }
  
  NSString *savedUsername;
  
  if ([[NSUserDefaults standardUserDefaults] stringForKey:@"token"] != nil) {
    self.state = MenuStateLogOut;
    savedUsername = [[NetworkController sharedController] username];
    if (savedUsername != nil) {
      NSString *newText = [NSString stringWithFormat:@"Hey %@!", savedUsername];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":newText,@"color":self.headerColor}];
    }
  } else {
    self.state = MenuStateLogIn;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":@"Login",@"color":self.headerColor}];
  }
  
  UITapGestureRecognizer *tapper = [UITapGestureRecognizer new];
  [tapper addTarget:self action:@selector(didTapView:)];
  [self.view addGestureRecognizer:tapper];
  
}

#pragma mark Button Actions

- (IBAction)pressedLogin:(id)sender {
      NSString *username = self.usernameField.text;
      [self.activityIndicator startAnimating];
      [[NetworkController sharedController] fetchTokenWithUsername:username password:self.passwordField.text completionHandler:^(NSError *error, bool success) {
        if (success) {
          [self.activityIndicator stopAnimating];
          [self switchToLogoutWithUsername:username andAnimation:true];
          self.state = MenuStateLogOut;
        } else {
          [self.activityIndicator stopAnimating];
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[error localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
          if (error == nil) {
            alert.message = @"An error occurred. Please try again later.";
          }
          [alert show];
        }
      }];
}

- (IBAction)pressedCreate:(id)sender {
  switch (self.state) {
    case MenuStateLogIn:
      self.state = MenuStateCreateAccountScreen;
      [self switchToCreate:true];
      break;
    case MenuStateCreateAccountScreen: {
      if (self.deviceHasKindaShortScreen || self.deviceHasShortScreen) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@""
                                    message:@"I agree to the Terms of Use and Privacy Policy."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction: [UIAlertAction actionWithTitle:@"No"
                                                   style: UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction *action) {
                                                   [alert dismissViewControllerAnimated:true completion:nil];
                                                 }]];
        
        [alert addAction: [UIAlertAction actionWithTitle:@"Yes"
                                                   style: UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                   [alert dismissViewControllerAnimated:true completion:nil];
                                                   [self createAccount];
                                                 }]];
        
        [self presentViewController:alert animated:true completion:nil];
        
      } else {
        [self createAccount];
      }
      
    }
    default:
      break;
  }

}

- (void) createAccount {
  
  [self.activityIndicator startAnimating];
  NSString *username = self.usernameField.text;
  NSString *password = self.passwordField.text;
  NSString *email = self.createEmailField.text;
  NSDate *birthday = [self dateFromBirthdayPicker:self.birthdayPicker];
  [[NetworkController sharedController] createUserWithUsername:username
                                                      password:password
                                                      birthday:birthday
                                                         email:email
                                             completionHandler:^(NSError *error, bool success) {
                                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                 if (success) {
                                                   [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   [self.activityIndicator stopAnimating];
                                                   self.state = MenuStateLogOut;
                                                   [self switchToLogoutWithUsername:username andAnimation:true];
                                                 } else {
                                                   [self.activityIndicator stopAnimating];
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                   message:[error localizedDescription]
                                                                                                  delegate:nil
                                                                                         cancelButtonTitle:@"OK"
                                                                                         otherButtonTitles:nil];
                                                   if (error == nil) {
                                                     alert.message = @"An error occurred. Please try again later.";
                                                   }
                                                   [alert show];
                                                 }
                                               }];
  }];
}

- (IBAction)pressedLogOut:(id)sender {
  
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"username"];
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"token"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [self switchToLogin:true];
  
}


- (IBAction)pressedBirthday:(id)sender {
  
  UIButton *birthdayButton = sender;
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    birthdayButton.transform = CGAffineTransformMakeTranslation(200, 0);
    self.birthdayPickerView.hidden = NO;
  } completion:^(BOOL finished) {
    
  }];
}
- (IBAction)pressedCancel:(id)sender{
  self.state = MenuStateLogIn;
  [self switchToLogin:true];
}

#pragma mark Animation methods

- (void)switchToLogin:(BOOL)animated {
  
  self.state = MenuStateLogIn;
  self.logInConstraint.priority = 999;
  self.logOutConstraint.priority = 900;
  self.topConstraint.constant = 125;
  
  self.usernameField.text = @"";
  self.passwordField.text = @"";
  self.passwordField.text = @"";
  self.createEmailField.text = @"";
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":@"Login",@"color":self.headerColor}];
  [UIView animateWithDuration:animated ? self.duration : 0
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.5
                      options:0
                   animations:^{
                     [self.loginView layoutSubviews];
                     self.usernameField.alpha = 1;
                     self.passwordField.alpha = 1;
                     self.usernameLabel.alpha = 1;
                     self.passwordLabel.alpha = 1;
                     self.logOutButton.alpha = 0;
                     self.loginButton.alpha = 1;
                     self.repeatPassword.alpha = 0;
                     self.passwordFieldTwo.alpha = 0;
                     self.emailLabel.alpha = 0;
                     self.createEmailField.alpha = 0;
                     self.birthdayPicker.alpha = 0;
                     self.birthdayPickerView.alpha = 0;
                     self.cancelButtonOne.alpha = 0;
                     self.loginButton.alpha = 1;
                     self.createAccountButton.alpha = 1;
                     self.createAccountButton.transform = CGAffineTransformIdentity;
                     self.termsConfirmationLabel.alpha = 0;
                   } completion:^(BOOL finished) {
                   }];
}

- (void)switchToLogoutWithUsername: (NSString*)username andAnimation:(BOOL)animated {
  
  self.logOutConstraint.priority = 999;
  self.logInConstraint.priority = 900;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":[NSString stringWithFormat:@"Hey %@!", username],@"color":self.headerColor}];
  [UIView animateWithDuration:animated ? self.duration : 0
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.5
                      options:0
                   animations:^{
                     [self.loginView layoutSubviews];
                     self.repeatPassword.alpha = 0;
                     self.passwordFieldTwo.alpha = 0;
                     self.emailLabel.alpha = 0;
                     self.createEmailField.alpha = 0;
                     self.birthdayPicker.alpha = 0;
                     self.cancelButtonOne.alpha = 0;
                     self.birthdayPickerView.alpha = 0;
                     self.usernameField.alpha = 0;
                     self.passwordField.alpha = 0;
                     self.usernameLabel.alpha = 0;
                     self.passwordLabel.alpha = 0;
                     self.logOutButton.alpha = 1;
                     self.loginButton.alpha = 0;
                     self.createAccountButton.alpha = 0;
                     self.cancelButtonOne.alpha = 0;
                     self.termsConfirmationLabel.alpha = 0;
                   } completion:^(BOOL finished) {

  }];
}

- (void)switchToCreate:(BOOL)animated {
  self.logOutConstraint.priority = 900;
  self.logInConstraint.priority = 900;
  self.topConstraint.constant = self.deviceHasShortScreen ? 24 : 75;
  NSString *header = self.deviceHasShortScreen ? @"" : @"Create Account";
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":header,@"color":self.headerColor}];
  
  if (self.deviceHasShortScreen) {
    self.emailLabelVerticalConstraint.constant = -48;
  }

  [UIView animateWithDuration:animated ? self.duration : 0
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.5
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.loginView layoutSubviews];
                     self.loginButton.alpha = 0;
                     self.createAccountButton.transform = CGAffineTransformMakeTranslation(0, -16);
                     self.repeatPassword.alpha = self.deviceHasShortScreen ? 0 : 1;
                     self.passwordFieldTwo.alpha = self.deviceHasShortScreen ? 0 : 1;
                     self.emailLabel.alpha = 1;
                     self.createEmailField.alpha = 1;
                     self.birthdayPicker.alpha = 1;
                     self.birthdayPickerView.alpha = 1;
                     self.cancelButtonOne.alpha = 1;
                     self.termsConfirmationLabel.alpha = self.deviceHasKindaShortScreen || self.deviceHasShortScreen ? 0 : 1;
                   } completion:^(BOOL finished) {
    
  }];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

  BOOL validated = [string validate];
  if (!validated) {
    
    textField.layer.borderColor = [UIColor clearColor].CGColor;
    textField.layer.borderWidth = 2;
    
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"borderColor";
    animation.fromValue = (__bridge id)([[UIColor clearColor] CGColor]);
    animation.toValue = (__bridge id)([[UIColor redColor] CGColor]);
    [textField.layer addAnimation:animation forKey:@"borderColor"];
    
  }
  return validated;
}

#pragma mark UIPickerViewDatasource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  switch (component) {
    case 0:
      return 12;
      break;
    case 1:
      return 31;
    case 2:
      return 81;
    default:
      return 0;
      break;
  }
}

#pragma mark UIPickerViewDelegate methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 20.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
  switch (component) {
    case 0:
      return 90;
    case 1:
      return 25;
    case 2:
      return 50;
    default:
      return 0;
      break;
  }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
  UILabel *pickerViewLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
  
  if (component == 0) {
      pickerViewLabel.text = [NSString stringWithFormat:@"%@", self.monthArray[row]];
      pickerViewLabel.textAlignment = NSTextAlignmentLeft;
  } else if (component == 1) {
      pickerViewLabel.text = [NSString stringWithFormat:@"%@", self.dateArray[row]];
    pickerViewLabel.textAlignment = NSTextAlignmentCenter;
  } else if (component == 2) {
      pickerViewLabel.text = [NSString stringWithFormat:@"%@", self.yearArray[row]];
    pickerViewLabel.textAlignment = NSTextAlignmentRight;
  }
  
  pickerViewLabel.font = [UIFont fontWithName: @"Avenir" size:16];
  pickerViewLabel.textColor = [UIColor blackColor];
  
  return pickerViewLabel;
  
}

#pragma mark date helper methods

- (NSDate*)dateFromBirthdayPicker: (UIPickerView *) pickerView {
    NSDateComponents *components = [[NSDateComponents alloc] init];
  NSInteger month = [pickerView selectedRowInComponent: 0] + 1;
  NSInteger day = [pickerView selectedRowInComponent:1] + 1;
  NSInteger year = [self.yearArray[[pickerView selectedRowInComponent:2]] integerValue];
    [components setYear: year];
    [components setMonth:month];
    [components setDay:day];
    return [self.localCalendar dateFromComponents:components];
}

- (IBAction)didPressShare:(id)sender {
  
  MFMessageComposeViewController *messageVC = [MFMessageComposeViewController new];
  
  messageVC.messageComposeDelegate = self;
  [messageVC setBody:@"Check out this great new app! https://appsto.re/i6By8ZN"];
  [self presentViewController:messageVC animated:true completion:nil];
  
}

- (IBAction)didPressTermsOfUse:(id)sender {
  [self showTermsViewControllerWithTitle:@"Terms of Use" andText:self.termsOfUse];
}

- (IBAction)didPressPrivacyPolicy:(id)sender {
  [self showTermsViewControllerWithTitle:@"Privacy Policy" andText:self.privacyPolicy];
}

- (void) showTermsViewControllerWithTitle:(NSString *) title andText: (NSString *) text {
  
  if (!self.termsVCActive){
    
    if (self.termsVC == nil) {
      self.termsVC = [TermsOfUseViewController new];
      self.termsVC.view.frame = CGRectInset(self.view.frame, 50, 100);
    }
    
    self.termsVCActive = true;
    
    self.termsVC.scrollView.contentOffset = CGPointZero;
    self.termsVC.scrollView.showsVerticalScrollIndicator = false;
    
    self.termsVC.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    [self addChildViewController:self.termsVC];
    [self.termsVC didMoveToParentViewController:self];
    
    self.termsVC.titleLabel.text = title;
    self.termsVC.bodyLabel.text = text;
    
    [self.view addSubview:self.termsVC.view];
    
    [UIView animateWithDuration:0.7
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.4
                        options:0
                     animations:^{
                       self.termsVC.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                       
                     }];
  }
 
}

- (void) hideTermsViewController {
  
  self.termsVCActive = false;
  
  [UIView animateWithDuration:0.7
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:0
                   animations:^{
                     self.termsVC.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
                   }
                   completion:^(BOOL finished) {
                     
                   }];
  
  
}


-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
  [self dismissViewControllerAnimated:true completion:nil];
}

- (void) didTapView: (UITapGestureRecognizer *) sender {
 
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self hideTermsViewController];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.passwordFieldTwo resignFirstResponder];
    [self.createEmailField resignFirstResponder];
  }
  
}



-(NSString *)termsOfUse {
  
  NSString *returnString = @"";
  returnString = [returnString stringByAppendingString:@"By accessing this app, you are agreeing to be bound by these terms and conditions of use, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. If you do not agree with any of these terms, you are prohibited from using or accessing this app. The materials contained in this app are protected by applicable copyright and trade mark law."];
  returnString = [returnString stringByAppendingString:@"\n\nThe materials in this app are provided \"as is\". Hey You and its developers make no warranties, expressed or implied, and hereby disclaim and negate all other warranties, including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights. Further, we do not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the materials on its app or otherwise relating to such materials or on any sites linked to this app."];
  returnString = [returnString stringByAppendingString:@"\n\nIn no event shall Hey You or its suppliers or developers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption,) arising out of the use or inability to use the materials on Hey You's app, even if Hey You or a Hey You authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you."];
  returnString = [returnString stringByAppendingString:@"\n\nHey You has not reviewed all content linked to its app and is not responsible for user generated content. The inclusion of content does not imply endorsement by Hey You or its developers of the content. Viewing of any such content is at the user's own risk."];
  returnString = [returnString stringByAppendingString:@"\n\nThat said, we take inappropriate content very seriously. Content that has been flagged as inappropriate will be reviewed and possibly removed. Users that post such content may be banned from the service."];

  return returnString;
  
}

- (NSString *)privacyPolicy {
  
  NSString *returnString = @"";
  returnString = [returnString stringByAppendingString:@"Your privacy is very important to us. Accordingly, we have developed this Policy in order for you to understand how we collect, use, communicate and disclose and make use of personal information. The following outlines our privacy policy."];
  returnString = [returnString stringByAppendingString:@"\n\nWe require users to login in order to prevent abuse. The purpose of collecting email addresses is for abuse prevention. Birthdays are collected to ensure that users are 18 years of age or over. This information will not be used for spam or for any other purpose."];
  returnString = [returnString stringByAppendingString:@"\n\nWe will collect and use of personal information solely with the objective of fulfilling those purposes specified by us and for other compatible purposes, unless we obtain the consent of the individual concerned or as required by law."];
  returnString = [returnString stringByAppendingString:@"\n\nWe will collect personal information by lawful and fair means and, where appropriate, with the knowledge or consent of the individual concerned."];
  returnString = [returnString stringByAppendingString:@"\n\nPersonal data should be relevant to the purposes for which it is to be used, and, to the extent necessary for those purposes, should be accurate, complete, and up-to-date."];
  returnString = [returnString stringByAppendingString:@"\n\nWe will protect personal information by reasonable security safeguards against loss or theft, as well as unauthorized access, disclosure, copying, use or modification."];;
  
  return returnString;
  
}



@end
