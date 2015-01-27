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


@interface SideMenuViewController ()

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) CGAffineTransform userPostsOffstage;
@property (nonatomic) CGAffineTransform createAccountOffstage;
@property (nonatomic) CGAffineTransform bestofLoggedOut;
@property (nonatomic) CGAffineTransform titleOffstage;
@property (nonatomic) CGAffineTransform loginCreateOffstage;
@property (nonatomic) MenuState state;

@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *dateArray;
@property (nonatomic, strong) NSMutableArray *yearArray;

@property (nonatomic, strong) NSCalendar *localCalendar;

@property (nonatomic, strong) Colors *colors;
@property (nonatomic, strong) UIColor *headerColor;

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.colors = [Colors singleton];
  self.usernameField.delegate = self;
  self.passwordField.delegate = self;
  self.createEmailField.delegate = self;
  self.birthdayPicker.delegate = self;
  self.birthdayPicker.dataSource = self;
  self.headerColor = [UIColor blackColor];
  
  self.loginView.backgroundColor = self.colors.flatYellow;
  
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
      NSLog(@"Invalid menu state");
      break;
  }
  
  //Prepare default locations
  self.loginView.transform = CGAffineTransformIdentity;
  self.cancelButtonOne.transform = CGAffineTransformIdentity;
  self.cancelButtonOne.alpha = 0;
  
  //Prepare date picker arrays
  self.monthArray = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
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
  
}

#pragma mark Button Actions

- (IBAction)pressedLogin:(id)sender {
      NSString *username = self.usernameField.text;
      [self.activityIndicator startAnimating];
      [[NetworkController sharedController] fetchTokenWithUsername:username password:self.passwordField.text completionHandler:^(NSError *error, bool success) {
        if (success) {
          [self.activityIndicator stopAnimating];
          [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
          [[NSUserDefaults standardUserDefaults] synchronize];
          [self switchToLogoutWithUsername:username andAnimation:true];
          self.state = MenuStateLogOut;
          NSLog(@"You are logged in!!!");
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
      NSLog(@"Add Login Called");
      self.state = MenuStateCreateAccountScreen;
      [self switchToCreate:true];
      break;
    case MenuStateCreateAccountScreen: {
      [self.activityIndicator startAnimating];
      NSString *username = self.usernameField.text;
      NSString *password = self.passwordField.text;
      NSString *email = self.createEmailField.text;
      NSDate *birthday = [self dateFromBirthdayPicker:self.birthdayPicker];
      [[NetworkController sharedController] createUserWithUsername:username password:password birthday:birthday email:email completionHandler:^(NSError *error, bool success) {
        if (success) {
          [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
          [[NSUserDefaults standardUserDefaults] synchronize];
          [self.activityIndicator stopAnimating];
          self.state = MenuStateLogOut;
          [self switchToLogoutWithUsername:username andAnimation:true];
          NSLog(@"User created!");
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
    default:
      break;
  }
}

- (IBAction)pressedLogOut:(id)sender {
  
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"username"];
  [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"token"];
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
                   } completion:^(BOOL finished) {

  }];
}

- (void)switchToCreate:(BOOL)animated {
  self.logOutConstraint.priority = 900;
  self.logInConstraint.priority = 900;
  self.topConstraint.constant = 75;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":@"Create Account",@"color":self.headerColor}];
  [UIView animateWithDuration:animated ? self.duration : 0
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.5
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.loginView layoutSubviews];
                     self.loginButton.alpha = 0;
                     self.createAccountButton.transform = CGAffineTransformMakeTranslation(0, -16);
                     self.repeatPassword.alpha = 1;
                     self.passwordFieldTwo.alpha = 1;
                     self.emailLabel.alpha = 1;
                     self.createEmailField.alpha = 1;
                     self.birthdayPicker.alpha = 1;
                     self.birthdayPickerView.alpha = 1;
                     self.cancelButtonOne.alpha = 1;
                   } completion:^(BOOL finished) {
    
  }];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

  if (![string validate]) {
    CGSize warningSize = CGSizeMake(textField.frame.size.width, 40);
    CGRect warningRect = CGRectMake(100 - warningSize.width / 2, textField.center.y + textField.bounds.size.height + 8, textField.frame.size.width, 40);
    UILabel *warningLabel = [[UILabel alloc] init];
    warningLabel.frame = warningRect;
    warningLabel.backgroundColor = [UIColor redColor];
    warningLabel.textColor = [UIColor whiteColor];
    warningLabel.minimumScaleFactor = 0.8;
    warningLabel.font = [UIFont fontWithName: @"Heavyweight" size:12];
    warningLabel.textAlignment = NSTextAlignmentCenter;
    warningLabel.layer.cornerRadius = 8;
    warningLabel.clipsToBounds = YES;
    warningLabel.alpha = 0;
    warningLabel.text = [NSString stringWithFormat: @"%@ does not support spaces", textField.placeholder];
    [self.view addSubview:warningLabel];
    [UIView animateWithDuration:0.8 delay:0.0 options:0 animations:^{
      warningLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.8 delay:2.0 options:0 animations:^{
        warningLabel.alpha = 0.0;
      } completion: nil];
    }];
  }
  return [string validate];
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
  } else {
      NSLog(@"Bad component for view");
      NSLog(@"tried to get component %ld", (long)component);
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
  [messageVC setBody:@"Check out this great new app! http://itunes.com/app/HeyYou"];
  [self presentViewController:messageVC animated:true completion:nil];
  
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
  [self dismissViewControllerAnimated:true completion:nil];
}

@end
