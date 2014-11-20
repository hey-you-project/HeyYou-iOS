//
//  SideMenuViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "SideMenuViewController.h"
#import "NSString+Validate.h"

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

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.usernameField.delegate = self;
  self.passwordField.delegate = self;
  self.createUsernameField.delegate = self;
  self.createPasswordField.delegate = self;
  self.createEmailField.delegate = self;
  self.birthdayPicker.delegate = self;
  self.birthdayPicker.dataSource = self;
  
  //Set up animation speed
  self.duration = 0.5;
  
  //Set up transforms
  self.userPostsOffstage = CGAffineTransformMakeTranslation(-175, 0);
  self.createAccountOffstage = CGAffineTransformMakeTranslation(0, 250);
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
      self.loginButton.transform = self.loginCreateOffstage;
      self.createAccountButton.transform = self.loginCreateOffstage;
      break;
    default:
      NSLog(@"Invalid menu state");
      break;
  }
  
  //Prepare default locations
  self.createView.transform = self.loginCreateOffstage;
  self.loginView.transform = self.loginCreateOffstage;
  
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

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  
  [UIView animateWithDuration:40.0
                        delay:0.0
                      options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut)
                   animations:^{
    self.imageView.transform = CGAffineTransformMakeTranslation(-2150, 0);
                 } completion:^(BOOL finished) {
                              }];

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
      NSString *username = self.usernameField.text;
      [self.activityIndicator startAnimating];
      [[NetworkController sharedController] fetchTokenWithUsername:username password:self.passwordField.text completionHandler:^(NSString *error, bool success) {
        if (success) {
          [self.activityIndicator stopAnimating];
          [self removeLoginAnimation:username];
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

- (IBAction)pressedCreate:(id)sender {
  switch (self.state) {
    case MenuStateLoggedOut:
      self.state = MenuStateCreateAccountScreen;
      [self addCreateAnimation];
      break;
    case MenuStateCreateAccountScreen: {
      [self.activityIndicator startAnimating];
      NSString *username = self.createUsernameField.text;
      NSString *password = self.createPasswordField.text;
      NSString *email = self.createEmailField.text;
      NSDate *birthday = [self dateFromBirthdayPicker:self.birthdayPicker];
      [[NetworkController sharedController] createUserWithUsername:username password:password birthday:birthday email:email completionHandler:^(NSString *error, bool success) {
        if (success) {
          [self.activityIndicator stopAnimating];
          self.state = MenuStateLoggedIn;
          [self removeCreateAnimation:username];
          NSLog(@"User created!");
        }
      }];
      
    }
    default:
      break;
  }
}

- (IBAction)pressedBirthday:(id)sender {
  UIButton *birthdayButton = sender;
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    birthdayButton.transform = CGAffineTransformMakeTranslation(200, 0);
    self.birthdayPickerView.hidden = NO;
  } completion:^(BOOL finished) {
    
  }];
}

#pragma mark Animation methods

- (void)addLoginAnimation {
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.heyYouTitle.transform = self.titleOffstage;
    self.bestofView.transform = CGAffineTransformMakeTranslation(-175, -106);
    self.createAccountButton.transform = self.createAccountOffstage;
    self.loginView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:self.duration - 0.2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.heyYouTitle.text = @"Hey you, Log In!";
      self.heyYouTitle.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
  }];
}

- (void)removeLoginAnimation: (NSString*)username {
  self.bestofView.transform = CGAffineTransformMakeTranslation(-175, 0);
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.heyYouTitle.transform = self.titleOffstage;
    self.userPostsView.transform = CGAffineTransformIdentity;
    self.bestofView.transform = CGAffineTransformIdentity;
    self.loginButton.transform = self.createAccountOffstage;
    self.loginView.transform = self.loginCreateOffstage;
  } completion:^(BOOL finished) {
    self.heyYouTitle.text = [NSString stringWithFormat:@"Hey %@!", username];
    [UIView animateWithDuration:self.duration - 0.2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.heyYouTitle.transform = CGAffineTransformIdentity;
    } completion: nil];
  }];
}

- (void)addCreateAnimation {
  [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.heyYouTitle.transform = self.titleOffstage;
    self.bestofView.transform = CGAffineTransformMakeTranslation(-175, -106);
    self.loginButton.transform = self.createAccountOffstage;
    self.createView.transform = CGAffineTransformIdentity;
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
  } completion:^(BOOL finished) {
    self.heyYouTitle.text = [NSString stringWithFormat:@"Hey %@!", username];
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
    CGRect warningRect = CGRectMake(textField.center.x - (textField.bounds.size.width / 2) + 12, textField.center.y + textField.bounds.size.height + 8, textField.frame.size.width, 40);
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
      return 75;
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
  
  pickerViewLabel.font = [UIFont fontWithName: @"Heavyweight" size:16];
  pickerViewLabel.textColor = [UIColor orangeColor];
  
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

@end
