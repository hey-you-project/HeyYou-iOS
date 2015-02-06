//
//  PostViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "PostViewController.h"
#import "NetworkController.h"
#import "MapViewController.h"
#import "Colors.h"

@interface PostViewController ()

@property (nonatomic, strong) NSArray *colorConstraints;
@property (nonatomic, strong) NetworkController* networkController;
@end

@implementation PostViewController

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupGestureRecognizers];
  
  self.color = @"purple";
  self.colorConstraints = @[self.orangeConstraint, self.blueConstraint, self.greenConstraint, self.yellowConstraint, self.tealConstraint, self.pinkConstraint, self.purpleConstraint];
  self.networkController = [NetworkController sharedController];
  
  self.bodyTextField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
  self.titleTextField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.borderView.strokeColor = [Colors flatPurple];
  self.bodyTextField.layer.cornerRadius = 10;
  self.titleTextField.layer.cornerRadius = 10;
  
  if (self.view.superview.frame.size.height < 500) {
    self.bodyFieldHeight.constant = 60;
  }
}

#pragma mark Helper Methods

-(void) setupGestureRecognizers {
  
  UIPanGestureRecognizer *colorPanner = [[UIPanGestureRecognizer alloc] init];
  [colorPanner addTarget:self action:@selector(receivedPanEventFromColorWrapper:)];
  [self.colorWrapper addGestureRecognizer:colorPanner];
  
  UITapGestureRecognizer *colorTapper = [[UITapGestureRecognizer alloc] init];
  [colorTapper addTarget:self action:@selector(receivedPanEventFromColorWrapper:)];
  [self.colorWrapper addGestureRecognizer:colorTapper];
  
}

- (IBAction)didPressPostButton:(id)sender {
  NSString *title = self.titleTextField.text;
  NSString *body = self.bodyTextField.text;
  Dot *dot = [[Dot alloc] initWithLocation:self.location color:self.color title:title body:body];
  dot.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
  
  [self.networkController postDot:dot completionHandler:^(NSError *error, bool success) {
    if (success) {
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.delegate requestDots];
        [self.delegate unpopCurrentComment];
        [self.delegate returnDragCircleToHomeBase];
      }];
      
    } else {
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

-(void) toggleColorToColor:(NSLayoutConstraint*) constraint {
  
  for (NSLayoutConstraint *con in self.colorConstraints) {
    con.constant = 0;
  }
  constraint.constant = -16;
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        [self.colorWrapper layoutSubviews];
                 } completion:^(BOOL finished) {
                  
                 }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.bodyTextField resignFirstResponder];
  [self.titleTextField resignFirstResponder];
}

-(void) receivedPanEventFromColorWrapper:(UIGestureRecognizer *)sender {
  CGPoint point = ([sender locationInView:self.colorWrapper]);

  if (point.x < self.colorWrapper.frame.size.width / 7) {
    if (![self.color  isEqual: @"turquoise"]) {
      [self changeAllTheThingsToColor:@"turquoise"];
      [self toggleColorToColor:self.greenConstraint];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 2) {
    if (![self.color  isEqual: @"green"]) {
      [self changeAllTheThingsToColor:@"green"];
      [self toggleColorToColor:self.yellowConstraint];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 3) {
    if (![self.color  isEqual: @"blue"]) {
      [self changeAllTheThingsToColor:@"blue"];
      [self toggleColorToColor:self.tealConstraint];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 4) {
    if (![self.color  isEqual: @"purple"]) {
      [self changeAllTheThingsToColor:@"purple"];
      [self toggleColorToColor:self.purpleConstraint];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 5) {
    if (![self.color  isEqual: @"yellow"]) {
      [self changeAllTheThingsToColor:@"yellow"];
      [self toggleColorToColor:self.blueConstraint];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 6) {
    if (![self.color  isEqual: @"orange"]) {
      [self changeAllTheThingsToColor:@"orange"];
      [self toggleColorToColor:self.orangeConstraint];
    }
  } else {
    if (![self.color  isEqual: @"red"]) {
      [self changeAllTheThingsToColor:@"red"];
      [self toggleColorToColor:self.pinkConstraint];
    }
  }
}

-(void) changeAllTheThingsToColor: (NSString *)color {
  self.color = color;
  UIColor *colorUI = [Colors getColorFromString:color];
  self.borderView.strokeColor = colorUI;
  //self.titleLabel.textColor = colorUI;
  [self.borderView setNeedsDisplay];
  [self.delegate changeDotColor:colorUI];
  
}

@end
