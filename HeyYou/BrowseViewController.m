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
  self.titleLabel.textColor = self.color;
  self.body.text = self.dot.body;
  self.colorBar.backgroundColor = self.color;
  self.timeLabel.text = [self.dateFormatter stringFromDate:self.dot.timestamp];
  [self.networkController getDotByID:self.dot.identifier completionHandler:^(NSError *error, Dot *dot) {
    if (dot != nil) {
      NSLog(@"Returned dot:%@", dot.body);
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"Back in VC, dot body = %@", dot.body);
        self.dot = dot;
        [self.tableView reloadData];
      }];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      if (error == nil) {
        alert.message = @"An error occurred. Please try again later.";
      }
      [alert show];
    }
  }];
  
  self.view.layer.borderColor = [self.color CGColor];
  self.view.layer.borderWidth = 2;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  //NSLog(@"%@",[self.dot.comments description]);
  return self.dot.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COMMENT_CELL" forIndexPath:indexPath];
  Comment *comment = self.dot.comments[indexPath.row];
  cell.bodyLabel.text = comment.body;
  cell.usernameLabel.text = comment.user.username;
  cell.timeLabel.text = [self.dateFormatter stringFromDate:comment.timestamp];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.bottomLine.backgroundColor = self.color;
  
  
  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  cell.alpha = 0;
  
  [UIView animateWithDuration:0.3 animations:^{
    cell.alpha = 1;
  }];
  
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
                          //self.commentButton.titleLabel.text = @"Cancel";
                          //self.chatButton.titleLabel.text = @"Submit";
                        }];
  } else {
    [self.networkController postComment:self.writeCommentTextField.text forDot:self.dot completionHandler:^(NSError *error, bool success) {
      if (success) {
        [self.tableView reloadData];
      } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        if (error == nil) {
          alert.message = @"An error occurred. Please try again later.";
        }
        [alert show];
      }
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
                          //self.commentButton.titleLabel.text = @"Comment";
                          //self.chatButton.titleLabel.text = @"Chat with User";
                           self.writeCommentTextField.hidden = true;
                            self.writeCommentTextField.alpha = 0;
                        }];

  }
  
}
- (IBAction)chatButtonPressed:(id)sender {
  NSLog(@"Chat Button Pressed with text %@",self.writeCommentTextField.text);
  
  [self.networkController postComment:self.writeCommentTextField.text forDot:self.dot completionHandler:^(NSError *error, bool success) {
    if (success) {
      [self.tableView reloadData];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      if (error == nil) {
        alert.message = @"An error occurred. Please try again later.";
      }
      [alert show];
    }
  }];
  
}

- (IBAction)didPressStar:(id)sender {
  self.userDidStar = !self.userDidStar;
  
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  NSNumber *stars = [formatter numberFromString:self.numberOfStarsLabel.text];
  NSInteger starsIntValue = [stars integerValue];
  
  if (self.userDidStar) {
    NSLog(@"Changing to filled!");
    self.starButton.titleLabel.text = @"\ue105";
    starsIntValue++;
  } else {
    NSLog(@"Changing to empty!");
    self.starButton.titleLabel.text = @"\ue108";
    starsIntValue--;
  }
  stars = [NSNumber numberWithInteger:starsIntValue];
  self.numberOfStarsLabel.text = [stars stringValue];

  
}

@end
