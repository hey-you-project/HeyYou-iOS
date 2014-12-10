//
//  SingleChatViewController.h
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSString *otherUser;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *textBar;
@property (weak, nonatomic) IBOutlet UIView *bottomPadView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBarConstraint;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end
