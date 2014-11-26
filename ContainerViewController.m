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
#import "Colors.h"

@interface ContainerViewController ()

@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) SideMenuViewController * sideMenuViewController;
@property (nonatomic, strong) UILabel *hamburgerLabel;
@property (nonatomic, strong) UIView *hamburgerWrapper;
@property (nonatomic, strong) Colors *colors;

@end

@implementation ContainerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.colors = [Colors singleton];
  
  [self setupSideMenuViewController];
  [self setupMapViewController];
  [self addHamburgerMenuCircle];
  
  [self setupGestureRecognizers];
  
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
  self.hamburgerWrapper.backgroundColor = [UIColor whiteColor];
  self.hamburgerWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.hamburgerWrapper.layer.shadowOpacity = 0.6;
  self.hamburgerWrapper.layer.shadowRadius = 3.0;
  self.hamburgerWrapper.layer.shadowOffset = CGSizeMake(0, 3);
  [self.view addSubview:self.hamburgerWrapper];
  
  CGRect labelRect = CGRectMake(self.hamburgerWrapper.bounds.origin.x + 19, self.hamburgerWrapper.bounds.origin.y + 17.5, 25, 25);
  
  self.hamburgerLabel = [[UILabel alloc] initWithFrame:labelRect];
  self.hamburgerLabel.text = @"\ue116";
  self.hamburgerLabel.font = [UIFont fontWithName:@"typicons" size:30];
  self.hamburgerLabel.textColor = self.colors.flatPurple;
  
  self.hamburgerLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.hamburgerLabel.layer.shadowOpacity = 0.8;
  self.hamburgerLabel.layer.shadowRadius = 1.0;
  self.hamburgerLabel.layer.shadowOffset = CGSizeMake(0, 2);
  
  [self.hamburgerWrapper addSubview:self.hamburgerLabel];
  
  UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
  [tap addTarget:self action:@selector(receivedTapGestureOnHamburgerButton:)];
  [self.hamburgerWrapper addGestureRecognizer:tap];
  
}

- (void) setupGestureRecognizers {
  
  UIScreenEdgePanGestureRecognizer *edgePanRecognizer = [UIScreenEdgePanGestureRecognizer new];
  [edgePanRecognizer addTarget:self action:@selector(receivedPanFromLeftEdge:)];
  edgePanRecognizer.edges = UIRectEdgeLeft;
  [self.view addGestureRecognizer:edgePanRecognizer];
  
}

- (void) receivedTapGestureOnHamburgerButton:(UITapGestureRecognizer *)sender{
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self toggleSideMenu];
  }
  
}

- (void)toggleSideMenu {
  
  CGRect newMapViewFrame = self.mapViewController.view.frame;

  CGRect newHamburgerFrame = self.hamburgerWrapper.frame;
  CGRect newHamLabelFrame = self.hamburgerLabel.frame;
  NSString *newString;
  CGAffineTransform transform;
  
  if (self.mapViewController.view.frame.origin.x == 0){
    [self.mapViewController returnDragCircleToHomeBase];
    self.sideMenuViewController.blueEffectView.hidden = NO;
    newMapViewFrame.origin.x += 200;
    newHamburgerFrame.origin.x += 30;
    newHamLabelFrame.origin.x += 6;
    newString = @"\ue122";
    transform = CGAffineTransformMakeScale(1.4, 1.4);
  } else {
    newMapViewFrame.origin.x -= 200;
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
                     self.mapViewController.view.frame = newMapViewFrame;
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

@end
