//
//  UserDotsViewController.h
//  HeyYou
//
//  Created by Cameron Klein on 11/25/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDotsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *emptyCaseView;
@property (weak, nonatomic) IBOutlet UILabel *emptyCaseTop;
@property (weak, nonatomic) IBOutlet UILabel *emptyCaseBottom;

- (void) removeDots;

@end
