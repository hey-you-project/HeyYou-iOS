//
//  BrowseViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "BrowseViewController.h"

@interface BrowseViewController ()

@property BOOL commentWriterDisplayed;
@property BOOL isTouching;
@property CGPoint lastOffset;

@end

@implementation BrowseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.tableView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"COMMENT_CELL"];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.commentWriterDisplayed = NO;
  self.isTouching = NO;
  self.lastOffset = CGPointMake(0, 0);
  
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.username.text = self.dot.username;
  self.titleLabel.text = self.dot.title;
  self.body.text = self.dot.body;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COMMENT_CELL" forIndexPath:indexPath];
  Comment *comment = self.comments[indexPath.row];
  cell.bodyLabel.text = comment.body;
  cell.usernameLabel.text = comment.user.username;
  
  return cell;
}
- (IBAction)commentButtonPressed:(id)sender {
  
  if (self.commentWriterDisplayed == NO) {
    self.commentWriterDisplayed = YES;
  
    self.commentConstraint.constant += 140;
    self.chatConstraint.constant += 140;
    self.writeCommentTextField.hidden = false;
    self.writeCommentTextField.alpha = 0;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionAllowUserInteraction animations:^{
                          [self.view layoutSubviews];
                          self.writeCommentTextField.alpha = 0.3;

                        } completion:^(BOOL finished) {
                          self.commentButton.titleLabel.text = @"Cancel";
                          self.chatButton.titleLabel.text = @"Submit";
                        }];
  } else {
    self.commentWriterDisplayed = NO;
    self.commentConstraint.constant -= 140;
    self.chatConstraint.constant -= 140;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionAllowUserInteraction animations:^{
                          [self.view layoutSubviews];
                          self.writeCommentTextField.alpha = 0.0;
                        } completion:^(BOOL finished) {
                          self.commentButton.titleLabel.text = @"Comment";
                          self.chatButton.titleLabel.text = @"Chat with User";
                           self.writeCommentTextField.hidden = true;
                            self.writeCommentTextField.alpha = 0;
                        }];

  }
  
}
- (IBAction)chatButtonPressed:(id)sender {
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  self.isTouching = NO;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  self.isTouching = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  if (scrollView.contentOffset.y > self.lastOffset.y && self.body.frame.origin.y > self.body.intrinsicContentSize.height * -1 && scrollView.contentOffset.y > 0) {
    self.bodyTopConstraint.constant -= (scrollView.contentOffset.y - self.lastOffset.y);
  } else if (scrollView.contentOffset.y < self.lastOffset.y && self.bodyTopConstraint.constant < 8 && self.isTouching == YES){
    self.bodyTopConstraint.constant -= (scrollView.contentOffset.y - self.lastOffset.y);
  }

  [self.view layoutSubviews];
  
  self.lastOffset = scrollView.contentOffset;
  
}





@end
