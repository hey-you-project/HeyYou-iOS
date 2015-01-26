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
#import "NetworkController.h"

@interface ChatListViewController ()

@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) NSArray *partners;

@end

@implementation ChatListViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.alpha = 0;
  self.networkController = [NetworkController sharedController];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.emptyCaseView.alpha = 0;
  [self getChatPartners];
  [self.navigationController setNavigationBarHidden:true];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  UIColor *newColor = [UIColor whiteColor];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel" object:nil userInfo:@{@"text":@"My Chat Partners", @"color":newColor}];
  [self getChatPartners];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.partners.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:@"CHAT_BUDDY_CELL" forIndexPath:indexPath];
  cell.username.text = self.partners[indexPath.row];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
  SingleChatViewController *destinationVC = [storyboard instantiateViewControllerWithIdentifier:@"SINGLE"];
  
  destinationVC.otherUser = self.partners[indexPath.row];
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    destinationVC.tableView.alpha = 0;
  }];
  [self.networkController getMessagesFromUser:self.partners[indexPath.row] withCompletionHandler:^(NSError *error, NSArray *messages) {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      destinationVC.messages = [[NSMutableArray alloc] initWithArray:messages];
      [destinationVC.tableView reloadData];

      [destinationVC.tableView scrollRectToVisible:destinationVC.bottomPadView.frame animated:false];
      [UIView animateWithDuration:0.4 animations:^{
        destinationVC.tableView.alpha = 1;
      }];
    }];
    
  }];
  
  [self.navigationController pushViewController:destinationVC animated:false];
}

-(void)beginNewChatWithUsername:(NSString *) username {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
  SingleChatViewController *destinationVC = [storyboard instantiateViewControllerWithIdentifier:@"SINGLE"];
  destinationVC.otherUser = username;
  [self.navigationController pushViewController:destinationVC animated:false];
  for (NSDictionary * dict in self.messages) {
    if([username isEqualToString:dict[@"username"]]){
      destinationVC.messages = [[NSMutableArray alloc] initWithArray:dict[@"items"]];
      break;
    }
  }
}

-(void)getChatPartners {
  
  [self.networkController getAllChatPartnersWithCompletionHandler:^(NSError *error, NSArray *messages) {
    self.partners = messages;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      if (self.partners.count == 0) {
        [UIView animateWithDuration:0.4 animations:^{
          self.emptyCaseView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
      }
      [self.tableView reloadData];
      [UIView animateWithDuration:0.4 animations:^{
        self.tableView.alpha = 1;
      }];
    }];
  }];
  
}


@end
