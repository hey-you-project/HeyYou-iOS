//
//  TermsOfUseViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 1/27/15.
//  Copyright (c) 2015 Hey You!. All rights reserved.
//

#import "TermsOfUseViewController.h"
#import "Colors.h"

@interface TermsOfUseViewController ()

@end

@implementation TermsOfUseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.view.layer.cornerRadius = 20;
  self.view.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.view.layer.shadowOpacity = 0.6;
  self.view.layer.shadowRadius = 3.0;
  self.view.layer.shadowOffset = CGSizeMake(0, 3);
  self.view.layer.borderWidth = 4;
  self.view.layer.borderColor = [[Colors flatTurquoise] CGColor];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
}

@end
