//
//  SingleChatViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "SingleChatViewController.h"
#import "Message.h"
#import "RightSideChatCell.h"
#import "LeftSideChatCell.h"
#import "Colors.h"

@interface SingleChatViewController ()

@property (nonatomic, strong) NSString *thisUser;
@property (nonatomic, strong) UIView *largeCircle;
@property (nonatomic, strong) UILabel *plusLabel;
@property (nonatomic, strong) Colors *colors;

@end

@implementation SingleChatViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.thisUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
  NSLog(@"%@", self.thisUser);
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.colors = [Colors singleton];
  [self addCircleView];
  [self.navigationController setNavigationBarHidden:true];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  
  UIColor *newColor = [UIColor whiteColor];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:self userInfo:@{@"text":self.otherUser, @"color":newColor}];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void) addCircleView {
  
  self.largeCircle = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 100, 60, 60)];
  self.largeCircle.layer.cornerRadius = self.largeCircle.frame.size.height / 2;
  self.largeCircle.layer.backgroundColor = [self.colors.flatGreen CGColor];
  self.largeCircle.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.largeCircle.layer.shadowOpacity = 0.6;
  self.largeCircle.layer.shadowRadius = 3.0;
  self.largeCircle.layer.shadowOffset = CGSizeMake(0, 3);
  [self.view addSubview:self.largeCircle];
  
  CGRect labelRect = CGRectMake(self.largeCircle.frame.origin.x + 19, self.largeCircle.frame.origin.y + 17.5, 25, 25);
  
  self.plusLabel = [[UILabel alloc] initWithFrame:labelRect];
  self.plusLabel.text = @"\ue0cf";
  self.plusLabel.font = [UIFont fontWithName:@"typicons" size:30];
  self.plusLabel.textColor = [UIColor whiteColor];
  
  self.plusLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.plusLabel.layer.shadowOpacity = 0.8;
  self.plusLabel.layer.shadowRadius = 1.0;
  self.plusLabel.layer.shadowOffset = CGSizeMake(0, 2);
  
  [self.view addSubview:self.plusLabel];
  
  UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
  [tap addTarget:self action:@selector(receivedTapGestureOnPlusButton:)];
  [self.largeCircle addGestureRecognizer:tap];
  
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Message *message = self.messages[indexPath.row];
  NSLog(@"Comparing %@ and %@",message.fromUser, self.thisUser);
  
  if ([message.fromUser isEqualToString:self.thisUser]) {
    NSLog(@"Dequeueing right cell");
    RightSideChatCell *cell = (RightSideChatCell *)[tableView dequeueReusableCellWithIdentifier:@"RIGHT" forIndexPath:indexPath];
    cell.body.text = message.body;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
  } else {
    LeftSideChatCell *cell = (LeftSideChatCell *)[tableView dequeueReusableCellWithIdentifier:@"LEFT" forIndexPath:indexPath];
    cell.body.text = message.body;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
  }
}

- (void) receivedTapGestureOnPlusButton: (UITapGestureRecognizer *)sender {
  NSLog(@"Received Tap!");
  [self.textField becomeFirstResponder];
}

- (IBAction)didPressSendButton:(id)sender {
  
  
}

- (void)keyboardWillShow:(NSNotification *)n {
  
  NSDictionary* userInfo = [n userInfo];
  CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  [self.view layoutIfNeeded];
  self.textBarConstraint.constant += 47.0 + keyboardSize.height;
  
  [UIView animateWithDuration:0.2f animations:^{
    [self.view layoutIfNeeded];
  } completion:^(BOOL finished) {
    
  }];
}
- (IBAction)didPressBackButton:(id)sender {
  
  [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end