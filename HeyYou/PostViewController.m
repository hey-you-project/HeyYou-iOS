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
@property (nonatomic, strong) NetworkController* networkController;
@end

@implementation PostViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  UIPanGestureRecognizer *colorPanner = [[UIPanGestureRecognizer alloc] init];
  [colorPanner addTarget:self action:@selector(receivedPanEventFromColorWrapper:)];
  [self.colorWrapper addGestureRecognizer:colorPanner];
  UITapGestureRecognizer *colorTapper = [[UITapGestureRecognizer alloc] init];
  [colorTapper addTarget:self action:@selector(receivedPanEventFromColorWrapper:)];
  [self.colorWrapper addGestureRecognizer:colorTapper];
  
  self.color = @"orange";
  self.colorConstraints = @[self.orangeConstraint, self.blueConstraint, self.greenConstraint, self.yellowConstraint, self.tealConstraint, self.pinkConstraint, self.purpleConstraint];
  self.networkController = [NetworkController sharedController];
  
  self.bodyTextField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
  self.titleTextField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
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
  NSString *title = self.titleTextField.text;
  NSString *body = self.bodyTextField.text;
  NSLog(@"Post button pressed!");
  Dot *dot = [[Dot alloc] initWithLocation:self.location color:self.color title:title body:body];
  
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self.delegate addNewAnnotationForDot:dot];
    [self.delegate unpopCurrentComment];
    [self.delegate returnDragCircleToHomeBase];
  }];
  
  [self.networkController postDot:dot completionHandler:^(NSError *error, bool success) {
    if (success) {
      
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
      self.color = @"turquoise";
      [self toggleColorToColor:self.greenConstraint];
      [self.delegate changeDotColor:@"turquoise"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 2) {
    if (![self.color  isEqual: @"green"]) {
      self.color = @"green";
      [self toggleColorToColor:self.yellowConstraint];
      [self.delegate changeDotColor:@"green"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 3) {
    if (![self.color  isEqual: @"blue"]) {
      self.color = @"blue";
      [self toggleColorToColor:self.tealConstraint];
      [self.delegate changeDotColor:@"blue"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 4) {
    if (![self.color  isEqual: @"purple"]) {
      self.color = @"purple";
      [self toggleColorToColor:self.purpleConstraint];
      [self.delegate changeDotColor:@"purple"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 5) {
    if (![self.color  isEqual: @"yellow"]) {
      self.color = @"yellow";
      [self toggleColorToColor:self.blueConstraint];
      [self.delegate changeDotColor:@"yellow"];
    }
  } else if (point.x < (self.colorWrapper.frame.size.width / 7) * 6) {
    if (![self.color  isEqual: @"orange"]) {
      self.color = @"orange";
      [self toggleColorToColor:self.orangeConstraint];
      [self.delegate changeDotColor:@"orange"];
    }
  } else {
    if (![self.color  isEqual: @"red"]) {
      self.color = @"red";
      [self toggleColorToColor:self.pinkConstraint];
      [self.delegate changeDotColor:@"red"];
    }
  }
}

@end
