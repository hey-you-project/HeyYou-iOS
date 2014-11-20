//
//  BrowseViewController.h
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dot.h"
#import "CommentCell.h"
#import "Comment.h"
#import "User.h"

@interface BrowseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *body;
@property (weak, nonatomic) IBOutlet UILabel *username;

@property (nonatomic, strong) Dot *dot;

@property (nonatomic, strong) NSArray *comments;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatConstraint;
@property (weak, nonatomic) IBOutlet UITextView *writeCommentTextField;

@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyTopConstraint;
@property (nonatomic, strong) UIColor *color;

@end
