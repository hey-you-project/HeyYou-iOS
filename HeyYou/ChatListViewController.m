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

- (void) viewDidLoad {
  [super viewDidLoad];
  self.tableView.alpha = 0;
  self.networkController = [NetworkController sharedController];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.emptyCaseView.alpha = 0;
  [self.navigationController setNavigationBarHidden:true];
  
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 40;
}

- (void) viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeHeaderLabel"
                                                      object:nil
                                                    userInfo:@{@"text" : @"My Chat Partners",
                                                               @"color" : [UIColor whiteColor]}];
  NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
  
  if (username) {
    NSLog(@"Got username");
    [self getChatPartners];
  } else {
    NSLog(@"Did not get username");
    self.emptyCaseTop.text = @"Not Logged In";
    self.emptyCaseBottom.text = @"Your chat partners will appear here once you login!";
    [self showEmptyCaseView];
  }
  
  
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.partners.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:@"CHAT_BUDDY_CELL" forIndexPath:indexPath];
  cell.username.text = self.partners[indexPath.row];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [self showSingleChatControllerForUser:self.partners[indexPath.row]];

}

- (void) beginNewChatWithUsername: (NSString *) username {
  
  [self showSingleChatControllerForUser:username];

}

- (void) showSingleChatControllerForUser: (NSString *) user {
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
  SingleChatViewController *destinationVC = [storyboard instantiateViewControllerWithIdentifier:@"SINGLE"];
  destinationVC.otherUser = user;
  [self.navigationController pushViewController:destinationVC animated:false];
  
}

- (void) getChatPartners {
  
  [self.networkController getAllChatPartnersWithCompletionHandler:^(NSError *error, NSArray *partners) {
    self.partners = partners;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      
      if (self.partners.count == 0) {
        
        [self showEmptyCaseView];
        
      } else {
        
        [self.tableView reloadData];
        [UIView animateWithDuration:0.4 animations:^{
          self.tableView.alpha = 1;
        }];
  
      }
      
    }];
  }];
  
}

- (void) showEmptyCaseView {
  
  [UIView animateWithDuration:0.4 animations:^{
    self.emptyCaseView.alpha = 1;
  }];
  
}


@end
