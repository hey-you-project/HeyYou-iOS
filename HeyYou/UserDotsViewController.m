//
//  UserDotsViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/25/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "UserDotsViewController.h"
#import "NetworkController.h"
#import "Dot.h"
#import "DotView.h"
#import "Colors.h"
#import "BrowseViewController.h"

@interface UserDotsViewController ()

@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) NSArray *myDots;
@property (nonatomic, strong) Colors *colors;
@property (nonatomic, strong) BrowseViewController *currentVC;

@end

@implementation UserDotsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.networkController = [NetworkController sharedController];
  self.colors = [Colors new];

}

- (void)viewWillAppear:(BOOL)animated{
  
  [super viewWillAppear:animated];
  [self retrieveDots];
  
}

- (void)didReceiveMemoryWarning {
  
    [super didReceiveMemoryWarning];
  
}

- (void) retrieveDots {
  
  [self.networkController getAllMyDotsWithCompletionHandler:^(NSError *error, NSArray *dots) {
    if (error == nil) {
      self.myDots = dots;
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addDots];
      }];
    }
  }];
  
}

- (void)addDots {
  
   CGFloat offset = 0;
   CGFloat delay = 0.1;
  
  for (Dot *dot in self.myDots) {
    NSLog(@"Adding dot!");
    DotView *circle = [DotView new];
    circle.dot = dot;
    circle.color = [self.colors getColorFromString:dot.color];
    circle.frame = CGRectMake(self.view.frame.size.width - 40, 100 + offset, 25, 25);
    circle.backgroundColor = [UIColor clearColor];
    circle.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);

    [self.scrollView addSubview:circle];
    
    [UIView animateWithDuration:0.7
                          delay:delay
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                       circle.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                       
                     }];
    
    UITapGestureRecognizer *tapper = [UITapGestureRecognizer new];
    [tapper addTarget:self action:@selector(didTapView:)];
    [circle addGestureRecognizer:tapper];
    
    offset += 50;
    delay += 0.2;
  }
}

-(void)didTapView:(UITapGestureRecognizer *)sender {
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    DotView *view = (DotView *)sender.view;

    [UIView animateWithDuration:0.2
                          delay:0.0
         usingSpringWithDamping:0.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionAllowUserInteraction animations:^{
                          self.currentVC.view.alpha = 0;
                        } completion:^(BOOL finished) {
                          [self.currentVC.view removeFromSuperview];
                          [self.currentVC removeFromParentViewController];
                          [self spawnPopupFromDotView:view];
                        }];
    
  }
}

-(void) spawnPopupFromDotView: (DotView *)view {
  
  BrowseViewController *dotVC = [BrowseViewController new];
  self.currentVC = dotVC;
  dotVC.color = [self.colors getColorFromString:view.dot.color];
  dotVC.dot = view.dot;
  
  CGRect popupFrame = CGRectMake(self.view.frame.origin.x + 20, self.view.frame.origin.y + 50, self.view.frame.size.width - 70, 500);
  dotVC.view.frame = popupFrame;
  
  [self addChildViewController:dotVC];
  [self.scrollView addSubview:dotVC.view];
  [dotVC didMoveToParentViewController:self];
  
  dotVC.borderView.popFromSide = true;
  dotVC.borderView.touchPoint = [self.scrollView convertPoint:view.center toView:dotVC.view];
  
  dotVC.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
  
  dotVC.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
  dotVC.view.alpha = 0;
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.6
        initialSpringVelocity:0.2
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     dotVC.view.alpha = 1;
                     dotVC.view.transform = CGAffineTransformMakeScale(1, 1);
                   } completion:^(BOOL finished) {
                     
                   }];
  
}

@end
