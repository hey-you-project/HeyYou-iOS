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
#import "DotAnnotationView.h"

@interface UserDotsViewController ()

@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) NSArray *myDots;

@end

@implementation UserDotsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.networkController = [NetworkController sharedController];
  [self.networkController getAllMyDotsWithCompletionHandler:^(NSError *error, NSArray *dots) {
    if (error == nil) {
      self.myDots = dots;
      [self addDots];
    }
  }];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
 

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

- (void)addDots {
   CGFloat offset = 0;
  for (Dot *dot in self.myDots) {
    NSLog(@"Adding dot!");
    UIView *circle = [UIView new];
    circle.frame = CGRectMake(100, 100 + offset, 25, 25);
    circle.backgroundColor = [UIColor blackColor];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      [self.view addSubview:circle];
    }];
    
    offset += 50;
  }
}

@end
