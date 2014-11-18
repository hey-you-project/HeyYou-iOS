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

@interface PostViewController ()

@property (nonatomic, strong) NSArray *colorConstraints;
@end

@implementation PostViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UIPanGestureRecognizer *colorPanner = [[UIPanGestureRecognizer alloc] init];
  [colorPanner addTarget:self action:@selector(receivedPanEventFromColorWrapper:)];
  [self.colorWrapper addGestureRecognizer:colorPanner];
  self.color = @"orange";
  self.colorConstraints = @[self.orangeConstraint, self.blueConstraint, self.greenConstraint, self.yellowConstraint, self.tealConstraint, self.pinkConstraint, self.purpleConstraint];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return 4;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  return @"Fart";
}

- (IBAction)didPressPostButton:(id)sender {
  NetworkController *networkController = [NetworkController sharedController];
  NSString *title = self.titleTextField.text;
  NSString *body = self.bodyTextField.text;
  
  Dot *dot = [[Dot alloc] initWithLocation:self.location color:self.color title:title body:body];
  
  [networkController postDot:dot completionHandler:^(NSString *error, bool success) {
    NSLog(success ? @"Success" : @"Fail");
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

-(void) receivedPanEventFromColorWrapper:(UITapGestureRecognizer *)sender {
  CGPoint point = ([sender locationInView:self.colorWrapper]);
  NSLog(@"Tap received!");
  if (point.x < self.colorWrapper.frame.size.width / 7) {
    NSLog(@"First one panned on!");
    if (![self.color  isEqual: @"green"]) {
      self.color = @"green";
      [self toggleColorToColor:self.greenConstraint];
      [self.delegate changeDotColor:@"green"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 2) {
    NSLog(@"Second one panned on!");
    if (![self.color  isEqual: @"yellow"]) {
      self.color = @"yellow";
      [self toggleColorToColor:self.yellowConstraint];
      [self.delegate changeDotColor:@"yellow"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 3) {
    NSLog(@"Third one panned on!");
    if (![self.color  isEqual: @"teal"]) {
      self.color = @"teal";
      [self toggleColorToColor:self.tealConstraint];
      [self.delegate changeDotColor:@"teal"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 4) {
    NSLog(@"Fourth one panned on!");
    if (![self.color  isEqual: @"purple"]) {
      self.color = @"purple";
      [self toggleColorToColor:self.purpleConstraint];
      [self.delegate changeDotColor:@"purple"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 5) {
    NSLog(@"Fifth one panned on!");
    if (![self.color  isEqual: @"blue"]) {
      self.color = @"blue";
      [self toggleColorToColor:self.blueConstraint];
      [self.delegate changeDotColor:@"blue"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 6) {
    NSLog(@"Sixth one panned on!");
    if (![self.color  isEqual: @"orange"]) {
      self.color = @"orange";
      [self toggleColorToColor:self.orangeConstraint];
      [self.delegate changeDotColor:@"orange"];
    }
  } else {
    NSLog(@"Seventh one panned on!");
    NSLog(@"Sixth one panned on!");
    if (![self.color  isEqual: @"pink"]) {
      self.color = @"pink";
      [self toggleColorToColor:self.pinkConstraint];
      [self.delegate changeDotColor:@"green"];
    }
  }
}

@end
