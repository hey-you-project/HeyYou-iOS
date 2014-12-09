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

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.colors = [Colors singleton];
  self.usernameField.delegate = self;
  self.passwordField.delegate = self;
//  self.createUsernameField.delegate = self;
//  self.createPasswordField.delegate = self;
  self.createEmailField.delegate = self;
  self.birthdayPicker.delegate = self;
  self.birthdayPicker.dataSource = self;
  
  self.loginView.layer.cornerRadius = 20;
  self.loginView.layer.borderColor = [self.colors.flatBlue CGColor];
  self.loginView.layer.borderWidth = 4;

  
  //Set up animation speed
  self.duration = 0.5;
  
  //Set up transforms
  self.userPostsOffstage = CGAffineTransformMakeTranslation(-175, 0);
  self.createAccountOffstage = CGAffineTransformMakeTranslation(0, 250);
  self.bestofLoggedOut = CGAffineTransformMakeTranslation(0, -106);
  self.titleOffstage = CGAffineTransformMakeTranslation(0, -100);
  self.loginCreateOffstage = CGAffineTransformMakeTranslation(250, 0);
  
  if ([[NetworkController sharedController] token] != nil) {
    self.state = MenuStateLogOut;
    NSString *savedUsername = [[NetworkController sharedController] username];
    if (savedUsername != nil) {
      self.heyYouTitle.text = [NSString stringWithFormat:@"Hey %@!", savedUsername];
    }
  } else {
    self.state = MenuStateLogIn;
  }

  switch (self.state) {
    case MenuStateLogIn:
      self.logInConstraint.priority = 999;
      self.logOutConstraint.priority = 900;
      self.userPostsView.transform = CGAffineTransformIdentity;
      self.bestofView.transform = CGAffineTransformIdentity;
      self.logOutButton.alpha = 0;
      self.usernameField.alpha = 1;
      self.passwordField.alpha = 1;
      self.usernameLabel.alpha = 1;
      self.passwordLabel.alpha = 1;
      break;
    case MenuStateLogOut:
      self.createAccountButton.alpha = 0;
      self.loginButton.alpha = 0;
      self.loginButton.transform = CGAffineTransformIdentity;
      self.createAccountButton.transform = CGAffineTransformIdentity;
      break;
    default:
      NSLog(@"Invalid menu state");
      break;
  }
  
  //Prepare default locations
  self.createView.transform = CGAffineTransformIdentity;
  self.loginView.transform = CGAffineTransformIdentity;
  self.cancelButtonOne.transform = CGAffineTransformIdentity;
  self.cancelButtonTwo.transform = CGAffineTransformIdentity;
  
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
  
  UITapGestureRecognizer *userTapper = [UITapGestureRecognizer new];
  [userTapper addTarget:self action:@selector(didPressUserDotsLabel:)];
  [self.userDotsLabel addGestureRecognizer:userTapper];
  
  UITapGestureRecognizer *mapTapper = [UITapGestureRecognizer new];
  [mapTapper addTarget:self action:@selector(didPressMapLabel:)];
  [self.mapViewLabel addGestureRecognizer:mapTapper];
  
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
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
          [self switchToLogout:username];
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
      [self switchToCreate];
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
          [self switchToLogout:username];
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
  [self switchToLogin];
  
}


- (IBAction)pressedBirthday:(id)sender {
  UIButton *birthdayButton = sender;
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    birthdayButton.transform = CGAffineTransformMakeTranslation(200, 0);
    self.birthdayPickerView.hidden = NO;
  } completion:^(BOOL finished) {
    
  }];
}
//- (IBAction)pressedCancel:(id)sender {
//  if (self.state == MenuStateCreateAccountScreen || self.state == MenuStateLoginScreen) {
//    self.state = MenuStateLoggedOut;
//    [self layoutBackToNormal];
//  }
//}

#pragma mark Animation methods

- (void)switchToLogin {
  self.logInConstraint.priority = 999;
  self.logOutConstraint.priority = 900;
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [self.view layoutSubviews];
    self.heyYouTitle.transform = self.titleOffstage;
//    self.bestofView.transform = CGAffineTransformMakeTranslation(-175, -106);
//    self.createAccountButton.transform = self.createAccountOffstage;
//    self.loginView.transform = CGAffineTransformIdentity;
//    self.cancelButtonOne.transform = CGAffineTransformIdentity;
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
    self.createAccountButton.alpha = 0;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:self.duration - 0.2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.heyYouTitle.text = @"Hey you, log in!";
      self.heyYouTitle.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
  }];
}

- (void)switchToLogout: (NSString*)username {
  self.logOutConstraint.priority = 999;
  self.logInConstraint.priority = 900;
  self.bestofView.transform = CGAffineTransformMakeTranslation(-175, 0);
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [self.view layoutSubviews];
    self.repeatPassword.alpha = 0;
    self.passwordFieldTwo.alpha = 0;
    self.emailLabel.alpha = 0;
    self.createEmailField.alpha = 0;
    self.birthdayPicker.alpha = 0;
    self.birthdayPickerView.alpha = 0;
    self.usernameField.alpha = 0;
    self.passwordField.alpha = 0;
    self.usernameLabel.alpha = 0;
    self.passwordLabel.alpha = 0;
    self.logOutButton.alpha = 1;
    self.loginButton.alpha = 0;
    self.createAccountButton.alpha = 0;
  } completion:^(BOOL finished) {
    self.heyYouTitle.text = [NSString stringWithFormat:@"Hey %@!", username];
    [UIView animateWithDuration:self.duration - 0.2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.heyYouTitle.transform = CGAffineTransformIdentity;
    } completion: nil];
  }];
}

- (void)switchToCreate {
  self.logOutConstraint.priority = 900;
  self.logInConstraint.priority = 900;
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    [self.view layoutSubviews];
    self.heyYouTitle.transform = self.titleOffstage;
    self.bestofView.transform = CGAffineTransformMakeTranslation(-175, -106);
    self.loginButton.transform = self.createAccountOffstage;
    self.createView.transform = CGAffineTransformIdentity;
    //self.createAccountButton.transform = CGAffineTransformMakeTranslation(0, -80);
    self.cancelButtonTwo.transform = CGAffineTransformMakeTranslation(0, -80);
    self.repeatPassword.alpha = 1;
    self.passwordFieldTwo.alpha = 1;
    self.emailLabel.alpha = 1;
    self.createEmailField.alpha = 1;
    self.birthdayPicker.alpha = 1;
    self.birthdayPickerView.alpha = 1;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:self.duration - 0.2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.heyYouTitle.text = @"Hey, create an account!";
      self.heyYouTitle.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
  }];
}

- (void)removeCreateAnimation: (NSString*)username {
  self.bestofView.transform = CGAffineTransformMakeTranslation(-175, 0);
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.heyYouTitle.transform = self.titleOffstage;
    self.userPostsView.transform = CGAffineTransformIdentity;
    self.bestofView.transform = CGAffineTransformIdentity;
    self.createAccountButton.transform = self.createAccountOffstage;
    self.createView.transform = self.loginCreateOffstage;
    self.cancelButtonTwo.transform = self.loginCreateOffstage;
  } completion:^(BOOL finished) {
    self.heyYouTitle.text = [NSString stringWithFormat:@"Hey %@!", username];
    [UIView animateWithDuration:self.duration - 0.2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.heyYouTitle.transform = CGAffineTransformIdentity;
    } completion: nil];
  }];
}

- (void)layoutBackToNormal {
  self.bestofView.transform = CGAffineTransformMakeTranslation(-175, -106);
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.heyYouTitle.transform = self.titleOffstage;
    self.bestofView.transform = self.bestofLoggedOut;
    self.loginView.transform = self.loginCreateOffstage;
    self.createView.transform = self.loginCreateOffstage;
    self.cancelButtonOne.transform = self.loginCreateOffstage;
    self.cancelButtonTwo.transform = self.loginCreateOffstage;
    self.loginButton.transform = CGAffineTransformIdentity;
    self.createAccountButton.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    self.heyYouTitle.text = [NSString stringWithFormat:@"Hey You!"];
    [UIView animateWithDuration:self.duration - 0.2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.heyYouTitle.transform = CGAffineTransformIdentity;
    } completion: nil];
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

- (void) didPressUserDotsLabel: (UITapGestureRecognizer *)sender {
  NSLog(@"DidPRess!");
  if (sender.state == UIGestureRecognizerStateEnded) {
    ContainerViewController *parent = (ContainerViewController *)[self parentViewController];
    [parent switchToUserDotView];
  }
}

- (void) didPressMapLabel: (UITapGestureRecognizer *)sender {
  NSLog(@"DidPRess!");
  if (sender.state == UIGestureRecognizerStateEnded) {
    ContainerViewController *parent = (ContainerViewController *)[self parentViewController];
    [parent switchToMapView];
  }
}

@end
