//
//  BrowseViewController.m
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "BrowseViewController.h"
#import "NetworkController.h"

@interface BrowseViewController ()

@property BOOL commentWriterDisplayed;
@property BOOL isTouching;
@property CGPoint lastOffset;
@property (nonatomic, strong) NetworkController *networkController;

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
  self.networkController = [NetworkController sharedController];
 
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.username.text = self.dot.username;
  self.titleLabel.text = self.dot.title;
  self.body.text = self.dot.body;
  [self.networkController getDotByID:self.dot.identifier completionHandler:^(NSString *error, Dot *dot) {
    NSLog(@"Returned dot:%@", dot.body);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      NSLog(@"Back in VC, dot body = %@", dot.body);
      
      self.dot = dot;
      [self.tableView reloadData];
    }];
  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSLog(@"%@",[self.dot.comments description]);
  return self.dot.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COMMENT_CELL" forIndexPath:indexPath];
  Comment *comment = self.dot.comments[indexPath.row];
  cell.bodyLabel.text = comment.body;
  cell.usernameLabel.text = comment.user.username;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}
- (IBAction)commentButtonPressed:(id)sender {
  
  if (self.commentWriterDisplayed == NO) {
    self.commentWriterDisplayed = YES;
  
    self.commentConstraint.constant += 140;
    self.chatConstraint.constant += 140;
    self.writeCommentTextField.hidden = false;
    self.writeCommentTextField.alpha = 0;
    self.commentButton.titleLabel.text = @"Cancel";
    self.chatButton.titleLabel.text = @"Submit";
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionAllowUserInteraction animations:^{
                          [self.view layoutSubviews];
                          self.writeCommentTextField.alpha = 0.3;

                        } completion:^(BOOL finished) {
                          
                        }];
  } else {
    [self.networkController postComment:self.writeCommentTextField.text forDot:self.dot completionHandler:^(NSString *error, bool success) {
      [self.tableView reloadData];
    }];
    
    
    self.commentWriterDisplayed = NO;
    self.commentConstraint.constant -= 140;
    self.chatConstraint.constant -= 140;
    self.commentButton.titleLabel.text = @"Comment";
    self.chatButton.titleLabel.text = @"Chat with User";
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.4
                        options:UIViewAnimationOptionAllowUserInteraction animations:^{
                          [self.view layoutSubviews];
                          self.writeCommentTextField.alpha = 0.0;
                        } completion:^(BOOL finished) {
                          
                           self.writeCommentTextField.hidden = true;
                            self.writeCommentTextField.alpha = 0;
                        }];

  }
  
}
- (IBAction)chatButtonPressed:(id)sender {
  NSLog(@"Chat Button Pressed with text %@",self.writeCommentTextField.text);
  
  [self.networkController postComment:self.writeCommentTextField.text forDot:self.dot completionHandler:^(NSString *error, bool success) {
    [self.tableView reloadData];
  }];
  
}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//  self.isTouching = NO;
//}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//  self.isTouching = YES;
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//  
//  if (scrollView.contentOffset.y > self.lastOffset.y && self.body.frame.origin.y > self.body.intrinsicContentSize.height * -1 && scrollView.contentOffset.y > 0) {
//    self.bodyTopConstraint.constant -= (scrollView.contentOffset.y - self.lastOffset.y);
//  } else if (scrollView.contentOffset.y < self.lastOffset.y && self.bodyTopConstraint.constant < 8 && self.isTouching == YES){
//    self.bodyTopConstraint.constant -= (scrollView.contentOffset.y - self.lastOffset.y);
//  }
//
//  [self.view layoutSubviews];
//  
//  self.lastOffset = scrollView.contentOffset;
//  
//}





@end
