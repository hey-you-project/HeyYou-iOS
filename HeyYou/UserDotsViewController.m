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
  UIColor *newColor = [UIColor whiteColor];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":@"My Dots", @"color":newColor}];
  
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  [self retrieveDots];
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self removeDots];
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

- (void) removeDots {
  
  CGFloat delay = 0.1;
  
  for (UIView *view in self.scrollView.subviews) {
    if ([view isKindOfClass:[DotView class]]){
    [UIView animateWithDuration:0.7
                          delay:delay
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                       view.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
                     } completion:^(BOOL finished) {
                       
                     }];
    delay += 0.2;
    [view removeFromSuperview];
    }
  }
  
}

- (void)addDots {
  
  if(self.myDots.count > 0) {
    [UIView animateWithDuration:0.4 animations:^{
      self.emptyCaseView.alpha = 0;
    } completion:^(BOOL finished) {
      
    }];
  }

  NSDateComponents *previousDate;
   CGFloat offset = 0;
   CGFloat delay = 0.5;
  
  for (int i = self.myDots.count - 1; i >= 0 ; i--) {
    Dot *dot = self.myDots[i];
    DotView *circle = [DotView new];
    circle.dot = dot;
    circle.color = [self.colors getColorFromString:dot.color];
    circle.frame = CGRectMake(self.view.frame.size.width - 40, 100 + offset, 25, 25);
    circle.backgroundColor = [UIColor clearColor];
    circle.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width, 0);
    
    NSDateComponents *dotDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dot.timestamp];

    [self.scrollView addSubview:circle];
    
    [UIView animateWithDuration:0.7
                          delay:delay
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                       circle.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                       if (previousDate == nil || !([dotDate day] == [previousDate day] && [dotDate month] == [previousDate month] && [dotDate year] == [previousDate year])) {
                         NSString *date = [self getFuzzyDate:dot.timestamp];
                         UILabel *label = [[UILabel alloc] init];
                         label.text = date;
                         label.font = [UIFont fontWithName:@"Avenir-Roman" size:14];
                         label.frame = CGRectMake(self.view.frame.size.width - 50, 80 + offset, 50, 14);
                         
                         label.textColor = [UIColor whiteColor];
                         [self.view addSubview:label];
                         label.alpha = 0;
                         [UIView animateWithDuration:0.4 animations:^{
                           label.alpha = 1;
                         }];
                       }
                       
                     }];
    previousDate = dotDate;
    UITapGestureRecognizer *tapper = [UITapGestureRecognizer new];
    [tapper addTarget:self action:@selector(didTapView:)];
    [circle addGestureRecognizer:tapper];
    
    offset += 50;
    delay += 0.1;
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
  
  CGRect popupFrame = CGRectMake(self.view.frame.origin.x + 20, self.view.frame.origin.y + 60, self.view.frame.size.width - 70, 500);
  dotVC.view.frame = popupFrame;
  
  [self addChildViewController:dotVC];
  [self.scrollView addSubview:dotVC.view];
  [dotVC didMoveToParentViewController:self];
  
  dotVC.borderViewRightSideConstraint.constant = -30;
  dotVC.borderView.popFromSide = true;
  dotVC.borderView.touchPoint = [self.scrollView convertPoint:view.center toView:dotVC.view];
  
  dotVC.view.backgroundColor = [UIColor whiteColor];
  
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

- (NSString *) getFuzzyDate: (NSDate *)dotDate {
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSUInteger dayForDot = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:dotDate];
  NSUInteger dayForNow = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:[NSDate date]];
  
  if (dayForDot == dayForNow) {
    return @"Today";
  } else if (dayForDot == dayForNow - 1) {
    return @"Yesterday";
  } else if (dayForDot > dayForNow - 7){
    return @"Two Days Ago";
  }
  return @"Oops.";
  
}

@end
