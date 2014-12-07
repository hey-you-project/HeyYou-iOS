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
@property (nonatomic, strong) SideMenuViewController * sideMenuViewController;
@property (nonatomic, strong) UINavigationController * chatViewController;
@property (nonatomic, strong) UILabel *hamburgerLabel;
@property (nonatomic, strong) UIView *hamburgerWrapper;
@property (nonatomic, strong) Colors *colors;
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
  
  self.colors = [Colors singleton];
  
  //[self setupSideMenuViewController];
  [self setupMapViewController];
  [self setupButtons];
  [self addHamburgerMenuCircle];
  [self setupGestureRecognizers];
  
  UIVisualEffect *blurEffect;
  blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  
  self.coverView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

  //self.coverView = [UIView new];
  self.coverView.frame = self.view.bounds;
  //self.coverView.backgroundColor = [UIColor blackColor];
  self.coverView.alpha = 0.0;
  self.hamburgerMenuExpanded = false;
  
  self.headerLabel = [UILabel new];
  self.headerLabel.text = @"";
  self.headerLabel.frame = CGRectMake(0, 30, self.view.frame.size.width, 32);
  self.headerLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:24];
  self.headerLabel.textColor = [UIColor orangeColor];
  self.headerLabel.textAlignment = NSTextAlignmentCenter;
  self.headerLabel.shadowColor = [UIColor blackColor];
  [self.view addSubview:self.headerLabel];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(changeHeaderLabel:)
                                               name:@"ChangeHeaderLabel"
                                             object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
}

- (void)setupMapViewController {
  self.mapViewController = [MapViewController new];
  [self addChildViewController:self.mapViewController];
  self.mapViewController.view.frame = self.view.frame;
  [self.view addSubview:self.mapViewController.view];
  [self.mapViewController didMoveToParentViewController:self];
  self.mapViewController.mapView.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.mapViewController.mapView.layer.shadowOpacity = 0.6;
  self.mapViewController.mapView.layer.shadowRadius = 3.0;
  self.mapViewController.mapView.layer.shadowOffset = CGSizeMake(-5, 0);
  self.currentMainViewController = self.mapViewController;
}

- (void)setupSideMenuViewController {
  self.sideMenuViewController = [SideMenuViewController new];
  [self addChildViewController:self.sideMenuViewController];
  self.sideMenuViewController.view.frame = CGRectMake(0, 0, 200, self.view.frame.size.height);
  [self.view addSubview:self.sideMenuViewController.view];
  [self.sideMenuViewController didMoveToParentViewController:self];
}

- (void) addHamburgerMenuCircle{
  
  CGRect hamburgerRect = CGRectMake(self.view.frame.origin.x + 40, self.view.frame.size.height - 100, 60, 60);
  
  self.hamburgerWrapper = [[UIView alloc] initWithFrame:hamburgerRect];
  self.hamburgerWrapper.layer.cornerRadius = self.hamburgerWrapper.frame.size.height / 2;
  self.hamburgerWrapper.backgroundColor = self.colors.flatGreen;
  self.hamburgerWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.hamburgerWrapper.layer.shadowOpacity = 0.6;
  self.hamburgerWrapper.layer.shadowRadius = 3.0;
  self.hamburgerWrapper.layer.shadowOffset = CGSizeMake(0, 3);
  self.hamburgerWrapper.layer.masksToBounds = false;
  //self.hamburgerWrapper.layer.anchorPoint = CGPointMake(self.hamburgerWrapper.bounds.origin.x, self.hamburgerWrapper.bounds.origin.y);
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
  
  self.userDotsButton.backgroundColor = self.colors.flatRed;
  self.mapButton.backgroundColor = self.colors.flatBlue;
  self.chatButton.backgroundColor = self.colors.flatOrange;
  self.loginButton.backgroundColor = self.colors.flatYellow;

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
  
//  UIScreenEdgePanGestureRecognizer *edgePanRecognizer = [UIScreenEdgePanGestureRecognizer new];
//  [edgePanRecognizer addTarget:self action:@selector(receivedPanFromLeftEdge:)];
//  edgePanRecognizer.edges = UIRectEdgeLeft;
//  [self.view addGestureRecognizer:edgePanRecognizer];
  
  UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
  [tap addTarget:self action:@selector(receivedTapGestureOnCoverView:)];
  [self.coverView addGestureRecognizer:tap];
  
}

- (void) receivedTapGestureOnHamburgerButton:(UITapGestureRecognizer *)sender{
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self toggleRadialMenu];
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

- (void) toggleRadialMenu {
  

  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     if (self.hamburgerMenuExpanded) {
                       [self retractRadialView];
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
                     self.coverView.alpha = 1;
                     [self.view insertSubview:self.coverView aboveSubview:self.mapViewController.view];
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

- (void)retractRadialView {
  
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
                     //self.coverView.alpha = 0.0;
                       self.hamburgerMenuExpanded = false;
                       self.chatLabel.alpha = 0;
                       self.loginLabel.alpha = 0;
                       self.dotsLabel.alpha = 0;
                   }completion:^(BOOL finished) {
                     
                   }];
  
}

- (void)toggleSideMenu {
  
  CGRect newCurrentViewFrame = self.currentMainViewController.view.frame;

  CGRect newHamburgerFrame = self.hamburgerWrapper.frame;
  CGRect newHamLabelFrame = self.hamburgerLabel.frame;
  NSString *newString;
  CGAffineTransform transform;
  
  if (self.currentMainViewController.view.frame.origin.x == 0){
    [self.mapViewController returnDragCircleToHomeBase];
    self.sideMenuViewController.blueEffectView.hidden = NO;
    newCurrentViewFrame.origin.x += 200;
    newHamburgerFrame.origin.x += 30;
    newHamLabelFrame.origin.x += 6;
    newString = @"\ue122";
    transform = CGAffineTransformMakeScale(1.4, 1.4);
  } else {
    newCurrentViewFrame.origin.x -= 200;
    newHamburgerFrame.origin.x -= 30;
    newHamLabelFrame.origin.x -= 6;
    newString = @"\ue116";
    transform = CGAffineTransformIdentity;
  }
  [self.mapViewController unpopCurrentComment];
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     self.currentMainViewController.view.frame = newCurrentViewFrame;
                     self.hamburgerWrapper.frame = newHamburgerFrame;
                     self.hamburgerLabel.frame = newHamLabelFrame;
                     self.hamburgerLabel.text = newString;
                     self.hamburgerLabel.transform = transform;
                   } completion:^(BOOL finished) {
                     if (self.mapViewController.view.frame.origin.x == 0){
                       self.sideMenuViewController.blueEffectView.hidden = YES;
                     }
                   }];
}


- (void) receivedPanFromLeftEdge:(UIScreenEdgePanGestureRecognizer *)sender {
  
  //  if (sender.state == UIGestureRecognizerStateChanged) {
  //    CGPoint offsetX = [sender locationInView:self.view];
  //    self.mapView.frame.origin.x = offsetX.x;
  //
  //  }
  
}

- (void) switchToMapView {
  
  if (![self.currentMainViewController isKindOfClass:[MapViewController class]]) {
    [self.userDotsViewController removeDots];
    UIColor *newColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":@"", @"color":newColor}];
    [UIView animateWithDuration:0.4
                     animations:^{
                       self.currentMainViewController.view.alpha = 0;
                       self.coverView.alpha = 0;
                     } completion:^(BOOL finished) {
                       [self.currentMainViewController.view removeFromSuperview];
                       [self.currentMainViewController removeFromParentViewController];
                       self.currentMainViewController = self.mapViewController;
                       
                     }];
  }
}

- (void) switchToUserDotView {
  if (![self.currentMainViewController isKindOfClass:[UserDotsViewController class]]) {
    self.userDotsViewController = [UserDotsViewController new];
    [self addChildViewController:self.userDotsViewController];
    [self.view insertSubview:self.userDotsViewController.view aboveSubview:self.coverView];
    [self.userDotsViewController didMoveToParentViewController:self];
    self.userDotsViewController.view.frame = self.currentMainViewController.view.frame;
    self.userDotsViewController.view.alpha = 0;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                       self.userDotsViewController.view.alpha = 1;
                       //self.coverView.alpha = 0;
                  } completion:^(BOOL finished) {
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.chatViewController = [storyboard instantiateViewControllerWithIdentifier:@"CHAT"];
    [self addChildViewController:self.chatViewController];
    [self.view insertSubview:self.chatViewController.view aboveSubview:self.coverView];
    [self.chatViewController didMoveToParentViewController:self];
    self.chatViewController.view.frame = self.mapViewController.view.frame;
    self.chatViewController.view.alpha = 0;
    
    [UIView animateWithDuration:0.4
                     animations:^{
                       self.chatViewController.view.alpha = 1;
                       //self.coverView.alpha = 0;
                     } completion:^(BOOL finished) {
                       if (![self.currentMainViewController isKindOfClass:[MapViewController class]]){
                         [self.currentMainViewController.view removeFromSuperview];
                         [self.currentMainViewController removeFromParentViewController];
                       }
                       self.currentMainViewController = self.chatViewController;
                     }];
    
  }
}

-(void) receivedTapGestureOnSmallButton:(UITapGestureRecognizer *)sender {
  NSLog(@"Got small button tap!");
  if (sender.state == UIGestureRecognizerStateEnded) {
    if (sender.view == self.mapButton) {
      [self switchToMapView];
    } else if (sender.view == self.userDotsButton) {
      [self switchToUserDotView];
    } else if (sender.view == self.chatButton) {
      [self switchToChatView];
    }
    [self toggleRadialMenu];
  }
}

- (void) receivedTapGestureOnCoverView:(UITapGestureRecognizer *)sender {
  NSLog(@"Received tap!");
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self toggleRadialMenu];
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
                  } completion:nil];
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
