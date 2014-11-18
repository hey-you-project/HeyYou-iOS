//
//  PostViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "PostViewController.h"
#import "NetworkController.h"

@interface PostViewController ()

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
  NSString *body = self.titleTextField.text;
  self.color = @"Orange";
  
  Dot *dot = [[Dot alloc] initWithLocation:self.location color:self.color title:title body:body];
  
  [networkController postDot:dot completionHandler:^(NSString *error, bool success) {
    NSLog(success ? @"Success" : @"Fail");
  }];
  
}

@end
