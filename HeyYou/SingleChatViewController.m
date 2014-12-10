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
#import "NetworkController.h"

@interface SingleChatViewController ()

@property (nonatomic, strong) NSString *thisUser;
@property (nonatomic, strong) UIView *largeCircle;
@property (nonatomic, strong) UILabel *plusLabel;
@property (nonatomic, strong) Colors *colors;
@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SingleChatViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.thisUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.textField.delegate = self;
  self.colors = [Colors singleton];
  self.networkController = [NetworkController sharedController];
  [self addCircleView];
  self.bottomPadView.frame = CGRectMake(self.bottomPadView.frame.origin.x, self.bottomPadView.frame.origin.y, self.bottomPadView.frame.size.width, 110);
  [self.navigationController setNavigationBarHidden:true];
  
  self.dateFormatter = [[NSDateFormatter alloc] init];
  [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
  [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillChange:)
                                               name:UIKeyboardWillChangeFrameNotification
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
  
  CGRect labelRect = CGRectMake(self.largeCircle.frame.origin.x + 19, self.largeCircle.frame.origin.y + 17.5, 25, 25);
  
  self.plusLabel = [[UILabel alloc] initWithFrame:labelRect];
  self.plusLabel.text = @"\ue0cf";
  self.plusLabel.font = [UIFont fontWithName:@"typicons" size:30];
  self.plusLabel.textColor = [UIColor whiteColor];
  
  self.plusLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.plusLabel.layer.shadowOpacity = 0.8;
  self.plusLabel.layer.shadowRadius = 1.0;
  self.plusLabel.layer.shadowOffset = CGSizeMake(0, 2);
  
  UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
  [tap addTarget:self action:@selector(receivedTapGestureOnPlusButton:)];
  [self.largeCircle addGestureRecognizer:tap];
  
  [self.view addSubview:self.largeCircle];
  [self.view addSubview:self.plusLabel];
  self.largeCircle.alpha = 0;
  self.plusLabel.alpha = 0;
  [UIView animateWithDuration:0.4 animations:^{
    self.largeCircle.alpha = 1;
    self.plusLabel.alpha = 1;
  }];
  
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Message *message = self.messages[indexPath.row];
  
  if ([message.fromUser isEqualToString:self.thisUser]) {
    RightSideChatCell *cell = (RightSideChatCell *)[tableView dequeueReusableCellWithIdentifier:@"RIGHT" forIndexPath:indexPath];
    cell.body.text = message.body;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Message *previousMessage;
    if (indexPath.row > 0){
      previousMessage = self.messages[indexPath.row - 1];
    }
    
    if (indexPath.row == 0 || [message.timestamp timeIntervalSinceDate:previousMessage.timestamp] > 60 * 60) {
      cell.bodyViewConstraint.priority = 997;
      cell.timeLabel.text = [self.dateFormatter stringFromDate:message.timestamp];
    } else {
      cell.timeLabel.text = @"";
    }
    return cell;
  } else {
    LeftSideChatCell *cell = (LeftSideChatCell *)[tableView dequeueReusableCellWithIdentifier:@"LEFT" forIndexPath:indexPath];
    cell.body.text = message.body;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Message *previousMessage;
    if (indexPath.row > 0){
      previousMessage = self.messages[indexPath.row - 1];
    }
    if (indexPath.row == 0 || [message.timestamp timeIntervalSinceDate:previousMessage.timestamp] > 60 * 60) {
      cell.bodyViewConstraint.priority = 997;
      cell.timeLabel.text = [self.dateFormatter stringFromDate:message.timestamp];
    } else {
      cell.timeLabel.text = @"";
    }
    return cell;
  }
}

- (void) receivedTapGestureOnPlusButton: (UITapGestureRecognizer *)sender {
  [self.textField becomeFirstResponder];
}

- (IBAction)didPressSendButton:(id)sender {
  [self postMessage];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self postMessage];
  return true;
}

- (void)postMessage {
  [self.networkController postMessage:self.textField.text toUser:self.otherUser withCompletionHandler:^(NSError *error, bool success) {
    if (success) {
      [self.textField resignFirstResponder];
      [self.messages addObject:[[Message alloc] initWithFrom:self.thisUser To:self.otherUser AndText:self.textField.text]];
      [self.tableView reloadData];
    }
  }];
}

- (void)keyboardWillShow:(NSNotification *)n {
  
  NSDictionary* userInfo = [n userInfo];
  CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  [self.view layoutIfNeeded];
  self.textBarConstraint.constant = keyboardSize.height;
  self.bottomPadView.frame = CGRectMake(self.bottomPadView.frame.origin.x, self.bottomPadView.frame.origin.y, self.bottomPadView.frame.size.width, 10);
  
  
  [UIView animateWithDuration:0.2f animations:^{
    [self.tableView scrollRectToVisible:self.bottomPadView.frame animated:false];
    [self.view layoutIfNeeded];
  } completion:^(BOOL finished) {
    
  }];
}

-(void) keyboardWillHide:(NSNotification *)n {
  
  [self.view layoutIfNeeded];
  self.textBarConstraint.constant = -47;

  [UIView animateWithDuration:0.2f animations:^{
    [self.view layoutIfNeeded];
    
  } completion:^(BOOL finished) {
    
  }];
  
}

-(void) keyboardWillChange:(NSNotification *)n {
  
  NSDictionary* userInfo = [n userInfo];
  CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  [self.view layoutIfNeeded];
  self.textBarConstraint.constant = keyboardSize.height;
  
  [UIView animateWithDuration:0.2f animations:^{
    
    [self.view layoutIfNeeded];
  } completion:^(BOOL finished) {
    
  }];
}

- (IBAction)didPressBackButton:(id)sender {
  [self.navigationController popToRootViewControllerAnimated:false];
}

-(void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end