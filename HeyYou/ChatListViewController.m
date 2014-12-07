//
//  ChatViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatListCell.h"
#import "Message.h"
#import "SingleChatViewController.h"

@interface ChatListViewController ()


@end

@implementation ChatListViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.messages = [Message parseJSONIntoMessages:nil];
  [self.navigationController setNavigationBarHidden:true];
  
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  UIColor *newColor = [UIColor whiteColor];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":@"My Chat Partners", @"color":newColor}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:@"CHAT_BUDDY_CELL" forIndexPath:indexPath];
  NSDictionary *thisDictionary = self.messages[indexPath.row];
  cell.username.text = thisDictionary[@"username"];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
  SingleChatViewController *destinationVC = [storyboard instantiateViewControllerWithIdentifier:@"SINGLE"];
  
  NSDictionary *thisDictionary = self.messages[indexPath.row];
  destinationVC.otherUser = thisDictionary[@"username"];
  destinationVC.messages = thisDictionary[@"items"];
  
  [self.navigationController pushViewController:destinationVC animated:true];
}


@end
