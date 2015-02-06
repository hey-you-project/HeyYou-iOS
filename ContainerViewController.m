//
//  ContainerViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/26/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "ContainerViewController.h"
#import "SideMenuViewController.h"
#import "MapViewController.h"
#import "UserDotsViewController.h"
#import "Colors.h"
#import "HamburgerWrapperView.h"
#import "ChatListViewController.h"

@interface ContainerViewController ()

@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) UserDotsViewController *userDotsViewController;
@property (nonatomic, strong) SideMenuViewController * loginViewController;
@property (nonatomic, strong) UINavigationController * chatViewController;
@property (nonatomic, strong) UILabel *hamburgerLabel;
@property (nonatomic, strong) UIView *hamburgerWrapper;
@property (nonatomic, strong) UIViewController *currentMainViewController;
@property (nonatomic, strong) UIView *userDotsButton;
@property (nonatomic, strong) UIView *chatButton;
@property (nonatomic, strong) UIView *loginButton;
@property (nonatomic, strong) UIView *mapButton;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) UILabel *chatLabel;
@property (nonatomic, strong) UILabel *dotsLabel;
@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) UILabel *headerLabel;

@property BOOL hamburgerMenuExpanded;

@end

@implementation ContainerViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self setupMapViewController];
  [self setupHeaderLabel];
  [self setupButtons];
  [self addHamburgerMenuCircle];
  [self setupGestureRecognizers];
  
  UIVisualEffect *blurEffect;
  blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  
  self.coverView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

  self.coverView.frame = self.view.bounds;

  self.coverView.hidden = true;
  [self.view insertSubview:self.coverView aboveSubview:self.mapViewController.view];
  self.hamburgerMenuExpanded = false;
  
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(changeHeaderLabel:)
                                               name:@"ChangeHeaderLabel"
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(chatWithUser:)
                                               name:@"SwitchToChatView"
                                             object:nil];
  
  //[self addLoginScreen];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
}

-(void)setupHeaderLabel {
  
  self.headerLabel = [UILabel new];
  self.headerLabel.text = @"";
  self.headerLabel.frame = CGRectMake(0, 30, self.view.frame.size.width, 32);
  self.headerLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:24];
  self.headerLabel.textColor = [UIColor orangeColor];
  self.headerLabel.textAlignment = NSTextAlignmentCenter;
  self.headerLabel.shadowColor = [UIColor blackColor];
  [self.view addSubview:self.headerLabel];

}

- (void)setupMapViewController {
  self.mapViewController = [MapViewController new];
  [self addChildViewController:self.mapViewController];
  self.mapViewController.view.frame = self.view.frame;
  [self.view addSubview:self.mapViewController.view];
  [self.mapViewController didMoveToParentViewController:self];
  self.currentMainViewController = self.mapViewController;
}

- (void) addHamburgerMenuCircle{
  
  CGRect hamburgerRect = CGRectMake(self.view.frame.origin.x + 40, self.view.frame.size.height - 100, 60, 60);
  
  self.hamburgerWrapper = [[UIView alloc] initWithFrame:hamburgerRect];
  self.hamburgerWrapper.layer.cornerRadius = self.hamburgerWrapper.frame.size.height / 2;
  self.hamburgerWrapper.backgroundColor = [Colors flatGreen];
  self.hamburgerWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.hamburgerWrapper.layer.shadowOpacity = 0.6;
  self.hamburgerWrapper.layer.shadowRadius = 3.0;
  self.hamburgerWrapper.layer.shadowOffset = CGSizeMake(0, 3);
  self.hamburgerWrapper.layer.masksToBounds = false;
  [self.view addSubview:self.hamburgerWrapper];
  
  CGRect labelRect = CGRectMake(self.hamburgerWrapper.frame.origin.x + 19, self.hamburgerWrapper.frame.origin.y + 17.5, 25, 25);
  
  self.hamburgerLabel = [[UILabel alloc] initWithFrame:labelRect];
  self.hamburgerLabel.text = @"\ue116";
  self.hamburgerLabel.font = [UIFont fontWithName:@"typicons" size:30];
  self.hamburgerLabel.textColor = [UIColor whiteColor];
  
  self.hamburgerLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.hamburgerLabel.layer.shadowOpacity = 0.8;
  self.hamburgerLabel.layer.shadowRadius = 1.0;
  self.hamburgerLabel.layer.shadowOffset = CGSizeMake(0, 2);
  [self.view addSubview:self.hamburgerLabel];
  
  UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
  [tap addTarget:self action:@selector(receivedTapGestureOnHamburgerButton:)];
  [self.hamburgerWrapper addGestureRecognizer:tap];
  
}

- (void) setupButtons {
  self.userDotsButton = [UIView new];
  self.mapButton = [UIView new];
  self.chatButton = [UIView new];
  self.loginButton = [UIView new];
  
  self.userDotsButton.backgroundColor = [Colors flatRed];
  self.mapButton.backgroundColor = [Colors flatBlue];
  self.chatButton.backgroundColor = [Colors flatOrange];
  self.loginButton.backgroundColor = [Colors flatYellow];

  NSArray *buttonArray = @[self.userDotsButton, self.mapButton, self.chatButton, self.loginButton];
  for (UIView *button in buttonArray) {
    button.frame = CGRectMake(self.view.frame.origin.x + 55, self.view.frame.size.height - 85, 40, 40);
    button.layer.shadowColor = [[UIColor blackColor] CGColor];
    button.layer.cornerRadius = button.frame.size.height / 2;
    button.layer.shadowOpacity = 0.6;
    button.layer.shadowRadius = 3.0;
    button.layer.shadowOffset = CGSizeMake(0, 3);
    [self.view addSubview:button];
  }
  
  UILabel *userDotsLabel = [UILabel new];
  UILabel *mapLabel = [UILabel new];
  UILabel *chatLabel = [UILabel new];
  UILabel *loginLabel = [UILabel new];
  
  [self.userDotsButton addSubview:userDotsLabel];
  [self.mapButton addSubview:mapLabel];
  [self.chatButton addSubview:chatLabel];
  [self.loginButton addSubview:loginLabel];
  
  userDotsLabel.text = @"\ue0b1";
  mapLabel.text = @"\ue0a6";
  chatLabel.text = @"\ue0b9";
  loginLabel.text = @"\ue030";
  
  NSArray *labelArray = @[userDotsLabel, mapLabel, chatLabel, loginLabel];
  for (UILabel *label in labelArray) {
    label.font = [UIFont fontWithName:@"typicons" size:24];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = label.superview.bounds;
  }
  
  UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
  [tap addTarget:self action:@selector(receivedTapGestureOnSmallButton:)];
  [self.userDotsButton addGestureRecognizer:tap];
  
  UITapGestureRecognizer *tap2 = [UITapGestureRecognizer new];
  [tap2 addTarget:self action:@selector(receivedTapGestureOnSmallButton:)];
  [self.mapButton addGestureRecognizer:tap2];
  
  UITapGestureRecognizer *tap3 = [UITapGestureRecognizer new];
  [tap3 addTarget:self action:@selector(receivedTapGestureOnSmallButton:)];
  [self.chatButton addGestureRecognizer:tap3];
  
  UITapGestureRecognizer *tap4 = [UITapGestureRecognizer new];
  [tap4 addTarget:self action:@selector(receivedTapGestureOnSmallButton:)];
  [self.loginButton addGestureRecognizer:tap4];


}

- (void) setupGestureRecognizers {
  
  UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
  [tap addTarget:self action:@selector(receivedTapGestureOnCoverView:)];
  [self.coverView addGestureRecognizer:tap];
  
}

- (void) receivedTapGestureOnHamburgerButton:(UITapGestureRecognizer *)sender{
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self toggleRadialMenuAndHideBlurView:([self.currentMainViewController isKindOfClass:[MapViewController class]])];
  }
  
}

- (void) expandHamburgerMenuToPopup {
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     if (self.hamburgerMenuExpanded) {
                       self.hamburgerWrapper.frame = CGRectMake(self.view.frame.origin.x + 40, self.view.frame.size.height - 100, 60, 60);
                       self.hamburgerMenuExpanded = false;
                     } else {
                       self.hamburgerWrapper.frame = CGRectMake(self.view.frame.origin.x + 40, self.view.frame.size.height - 240, 300, 200);
                       self.hamburgerMenuExpanded = true;
                     }
                     [self.hamburgerWrapper setNeedsDisplay];
                   } completion:^(BOOL finished) {
                     
                   }];
  
}

- (void) toggleRadialMenuAndHideBlurView:(BOOL)willHideBlurView {
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     if (self.hamburgerMenuExpanded) {
                       [self retractRadialViewAndHideBlurView:willHideBlurView];
                     } else {
                       [self expandRadialView];
                     }} completion:^(BOOL finished) {
                       
                     }];
                  
}

- (void) expandRadialView {
  
  CGAffineTransform labelTransform = CGAffineTransformMakeScale(1.4, 1.4);
  labelTransform = CGAffineTransformTranslate(labelTransform, 4, 0);
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     self.mapButton.transform = CGAffineTransformMakeTranslation(-30, -60);
                     self.userDotsButton.transform = CGAffineTransformMakeTranslation(17, -62);
                     self.chatButton.transform = CGAffineTransformMakeTranslation(50, -27);
                     self.loginButton.transform = CGAffineTransformMakeTranslation(48, 22);
                     self.hamburgerLabel.transform = labelTransform;
                     self.hamburgerLabel.text = @"\ue122";
                     self.coverView.hidden = false;
                     
                     self.hamburgerMenuExpanded = true;
                   } completion:^(BOOL finished) {
                       self.chatLabel = [UILabel new];
                       self.dotsLabel = [UILabel new];
                       self.loginLabel  = [UILabel new];
                       self.chatLabel.text = @"Chat";
                       self.dotsLabel.text = @"Mine";
                       self.loginLabel.text = @"Login";
                       self.dotsLabel.textColor = [UIColor whiteColor];
                       self.loginLabel.textColor = [UIColor whiteColor];
                       self.chatLabel.textColor = [UIColor whiteColor];
                       self.chatLabel.frame = self.chatButton.frame;
                       self.dotsLabel.frame = self.userDotsButton.frame;
                       self.loginLabel.frame = self.loginButton.frame;
                       self.chatLabel.font = [UIFont fontWithName:@"Avenir Light" size:14];
                       self.loginLabel.font = [UIFont fontWithName:@"Avenir Light" size:14];
                       self.dotsLabel.font = [UIFont fontWithName:@"Avenir Light" size:14];
                       self.chatLabel.transform = CGAffineTransformMakeTranslation(43, 0);
                       self.dotsLabel.transform = CGAffineTransformMakeTranslation(43, 0);
                       self.loginLabel.transform = CGAffineTransformMakeTranslation(43, 0);
                       self.chatLabel.alpha = 0;
                       self.loginLabel.alpha = 0;
                       self.dotsLabel.alpha = 0;
                       [self.view addSubview:self.chatLabel];
                       [self.view addSubview:self.loginLabel];
                       [self.view addSubview:self.dotsLabel];
                       
                       [UIView animateWithDuration: 0.4
                                        animations:^{
//                                          self.chatLabel.alpha = 1;
//                                          self.loginLabel.alpha = 1;
//                                          self.dotsLabel.alpha = 1;
                                        }];
                   }];
}

- (void) retractRadialViewAndHideBlurView:(BOOL) willHideBlurView {
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                       self.mapButton.transform = CGAffineTransformIdentity;
                       self.loginButton.transform = CGAffineTransformIdentity;
                       self.chatButton.transform = CGAffineTransformIdentity;
                       self.userDotsButton.transform = CGAffineTransformIdentity;
                       self.hamburgerLabel.text =  @"\ue116";
                       self.hamburgerLabel.transform = CGAffineTransformIdentity;
                       if (willHideBlurView){
                          self.coverView.hidden = true;
                       }
                       self.hamburgerMenuExpanded = false;
                       self.chatLabel.alpha = 0;
                       self.loginLabel.alpha = 0;
                       self.dotsLabel.alpha = 0;
                   }completion:^(BOOL finished) {
                     
                   }];
  
}

- (void) switchToMapView {
  
  if (![self.currentMainViewController isKindOfClass:[MapViewController class]]) {

    UIColor *newColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":@"", @"color":newColor}];
    
    UIView *expandingView = [UIView new];
    expandingView.frame = self.mapButton.frame;
    expandingView.backgroundColor = [UIColor whiteColor];
    expandingView.layer.cornerRadius = expandingView.frame.size.height/2;

    [self.mapViewController.view removeFromSuperview];
    [self.view insertSubview:self.mapViewController.view belowSubview:self.headerLabel];
    [self.mapViewController.view addSubview:expandingView];
    self.mapViewController.view.layer.mask = expandingView.layer;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       expandingView.transform = CGAffineTransformMakeScale(30, 30);
                     }
                     completion:^(BOOL finished) {
                       [expandingView removeFromSuperview];
                       [self.currentMainViewController.view removeFromSuperview];
                       [self.currentMainViewController removeFromParentViewController];
                       self.currentMainViewController = self.mapViewController;
                     }];

  }
  
}

- (void) switchToUserDotView {
  if (![self.currentMainViewController isKindOfClass:[UserDotsViewController class]]) {
    self.userDotsViewController = [UserDotsViewController new];
    
    UIView *expandingView = [UIView new];
    expandingView.frame = self.userDotsButton.frame;
    expandingView.backgroundColor = self.userDotsButton.backgroundColor;
    expandingView.layer.cornerRadius = expandingView.frame.size.height/2;

    self.userDotsViewController = [UserDotsViewController new];
    [self addChildViewController:self.userDotsViewController];
    [self.view insertSubview:self.userDotsViewController.view belowSubview:self.headerLabel];
    [self.userDotsViewController didMoveToParentViewController:self];
    self.userDotsViewController.view.frame = self.currentMainViewController.view.frame;
    self.userDotsViewController.view.backgroundColor = expandingView.backgroundColor;
    self.userDotsViewController.view.layer.mask = expandingView.layer;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       expandingView.transform = CGAffineTransformMakeScale(30, 30);
                     }
                     completion:^(BOOL finished) {
                       [expandingView removeFromSuperview];
                       if (![self.currentMainViewController isKindOfClass:[MapViewController class]]){
                         [self.currentMainViewController.view removeFromSuperview];
                         [self.currentMainViewController removeFromParentViewController];
                       }
                       self.currentMainViewController = self.userDotsViewController;
                     }];
  }
}

- (void) switchToChatView {
  if (![self.currentMainViewController isKindOfClass:[ChatListViewController class]]) {
    
    UIView *expandingView = [UIView new];
    expandingView.frame = self.chatButton.frame;
    expandingView.backgroundColor = self.chatButton.backgroundColor;
    expandingView.layer.cornerRadius = expandingView.frame.size.height/2;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.chatViewController = [storyboard instantiateViewControllerWithIdentifier:@"CHAT"];
    [self addChildViewController:self.chatViewController];
    [self.mapViewController unpopCurrentComment];
    [self.view insertSubview:self.chatViewController.view belowSubview:self.headerLabel];
    [self.chatViewController didMoveToParentViewController:self];
    self.chatViewController.view.frame = self.mapViewController.view.frame;
    self.chatViewController.view.backgroundColor = expandingView.backgroundColor;
    self.chatViewController.view.layer.mask = expandingView.layer;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       expandingView.transform = CGAffineTransformMakeScale(30, 30);
                     }
                     completion:^(BOOL finished) {
                       [expandingView removeFromSuperview];
                       if (![self.currentMainViewController isKindOfClass:[MapViewController class]]){
                         [self.currentMainViewController.view removeFromSuperview];
                         [self.currentMainViewController removeFromParentViewController];
                       }
                       self.currentMainViewController = self.chatViewController;
                     }];
  }
}

- (void) switchToLoginView {
  if (![self.currentMainViewController isKindOfClass:[SideMenuViewController class]]) {
    
    UIView *expandingView = [UIView new];
    expandingView.frame = self.loginButton.frame;
    expandingView.backgroundColor = self.loginButton.backgroundColor;
    expandingView.layer.cornerRadius = expandingView.frame.size.height/2;
    
    self.loginViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:[NSBundle mainBundle]];
    [self addChildViewController:self.loginViewController];
    [self.mapViewController unpopCurrentComment];
    [self.view insertSubview:self.loginViewController.view belowSubview:self.headerLabel];
    [self.loginViewController didMoveToParentViewController:self];
    self.loginViewController.view.frame = self.mapViewController.view.frame;
    self.loginViewController.view.layer.mask = expandingView.layer;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       expandingView.transform = CGAffineTransformMakeScale(30, 30);
                     } completion:^(BOOL finished) {
                       self.loginViewController.view.backgroundColor = expandingView.backgroundColor;
                       [expandingView removeFromSuperview];
                       if (![self.currentMainViewController isKindOfClass:[MapViewController class]]){
                         [self.currentMainViewController.view removeFromSuperview];
                         [self.currentMainViewController removeFromParentViewController];
                       }
                       self.currentMainViewController = self.loginViewController;
                     }];
  }
}

-(void) receivedTapGestureOnSmallButton:(UITapGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateEnded) {
    if (sender.view == self.mapButton) {
      [self switchToMapView];
      [self toggleRadialMenuAndHideBlurView:true];
    } else if (sender.view == self.userDotsButton) {
      [self switchToUserDotView];
      [self toggleRadialMenuAndHideBlurView:false];
    } else if (sender.view == self.chatButton) {
      [self switchToChatView];
      [self toggleRadialMenuAndHideBlurView:false];
    } else if (sender.view == self.loginButton) {
      [self switchToLoginView];
      [self toggleRadialMenuAndHideBlurView:false];
    }
    
  }
}

- (void) receivedTapGestureOnCoverView:(UITapGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self toggleRadialMenuAndHideBlurView:true];
  }
  
}

- (void) changeHeaderLabel: (NSNotification *)notification {
  
  NSDictionary* userInfo = [notification userInfo];
  NSString *newString = [userInfo objectForKey:@"text"];
  UIColor *newColor = [userInfo objectForKey:@"color"];

  [UIView transitionWithView:self.headerLabel
                    duration:0.5
                     options:UIViewAnimationOptionTransitionFlipFromBottom
                  animations:^{
                    self.headerLabel.textColor = newColor;
                    self.headerLabel.text = newString;
                  }
                  completion:nil];
}

- (void) chatWithUser: (NSNotification *)notification {
  NSDictionary* userInfo = [notification userInfo];
  NSString *otherUser = userInfo[@"user"];
  
  [self switchToChatView];
  ChatListViewController *chatList = self.chatViewController.viewControllers[0];
  [chatList beginNewChatWithUsername:otherUser];
  
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
