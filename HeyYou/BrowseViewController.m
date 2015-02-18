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

@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) NSString *currentUser;

@property BOOL deviceHasShortScreen;

@end

@implementation BrowseViewController

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.tableView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"COMMENT_CELL"];
 
  self.networkController = [NetworkController sharedController];
  
  self.currentUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
  
  UITapGestureRecognizer *tapper = [UITapGestureRecognizer new];
  [tapper addTarget:self action:@selector(didTapStar:)];
  [self.star addGestureRecognizer:tapper];
  
  UITapGestureRecognizer *flagger = [UITapGestureRecognizer new];
  [flagger addTarget:self action:@selector(didTapFlag:)];
  [self.star addGestureRecognizer:flagger];
  
  UITapGestureRecognizer *keyboardDismiss = [UITapGestureRecognizer new];
  [keyboardDismiss addTarget:self action:@selector(didTapViewToDismiss:)];
  [self.view addGestureRecognizer:keyboardDismiss];
 
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.writeCommentTextField.layer.cornerRadius = 10;
  self.cancelButton.alpha = 0;
  self.submitButton.alpha = 0;
  self.borderView.clipsToBounds = true;
  self.view.clipsToBounds = false;
  self.username.text = self.dot.username;
  self.titleLabel.text = self.dot.title;
  self.titleLabel.textColor = self.color;
  self.body.text = self.dot.body;
  self.numberOfStarsLabel.text = [self.dot.stars stringValue];
  self.userDidStar = self.dot.userHasStarred;
  if (self.userDidStar) {
    self.star.text = @"\ue105";
  } else {
    self.star.text = @"\ue108";
  }
  self.colorBar.backgroundColor = self.color;
  self.timeLabel.text = [self getFuzzyDateFromDate:self.dot.timestamp];
  
  [self requestDot];
  
  self.borderView.strokeColor = self.color;
  self.borderView.frame = self.view.frame;
  self.borderView.backgroundColor = [UIColor clearColor];
  
  UIView *sideColorBar = [UIView new];
  sideColorBar.backgroundColor = self.color;
  sideColorBar.frame = CGRectMake(CGRectGetMaxX(self.view.bounds),self.colorBar.frame.origin.y, 30, self.colorBar.frame.size.height);
  [self.view addSubview:sideColorBar];
  
  if ([[UIScreen mainScreen] bounds].size.height < 500) {
    self.deviceHasShortScreen = true;
  }
  
}

#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.dot.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COMMENT_CELL" forIndexPath:indexPath];
  Comment *comment = self.dot.comments[indexPath.row];
  cell.bodyLabel.text = comment.body;
  cell.usernameLabel.text = comment.user.username;
  cell.timeLabel.text = [self getFuzzyDateFromDate:comment.timestamp];
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

#pragma mark IBActions

- (IBAction)commentButtonPressed:(id)sender {
  
  if (self.currentUser) {
    [self addCommentBox];
  } else {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Logged In"
                                                    message:@"You must log in to comment."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

    [alert show];
    
  }

}

- (IBAction)chatButtonPressed:(id)sender {
  
  if (self.currentUser) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchToChatView" object:nil userInfo:@{@"user":self.dot.username}];
  } else {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Logged In"
                                                    message:@"You must log in to chat."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
    
  }

}


- (IBAction)cancelPressed:(id)sender {
  
  [self removeCommentBox];
  
}

- (IBAction)submitPressed:(id)sender {
  
    [self.networkController postComment:self.writeCommentTextField.text forDot:self.dot completionHandler:^(NSError *error, bool success) {
      if (success) {
        [self requestDot];
        [self.tableView reloadData];
      } else {
        [self showAlertViewWithError:error];
      }
    }];
  [self removeCommentBox];
  
}

- (void)didTapStar:(UITapGestureRecognizer *)sender {
  self.userDidStar = !self.userDidStar;
  
  [[NetworkController sharedController] postToggleStarOnDot:self.dot completionHandler:^(NSError *error, bool success) {
    if (success) {
      NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
      [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
      NSNumber *stars = [formatter numberFromString:self.numberOfStarsLabel.text];
      NSInteger starsIntValue = [stars integerValue];
      if (self.userDidStar) {
        self.star.text = @"\ue105";
        starsIntValue++;
      } else {
        self.star.text = @"\ue108";
        starsIntValue--;
      }
      stars = [NSNumber numberWithInteger:starsIntValue];
      self.numberOfStarsLabel.text = [stars stringValue];
    } else {
      [self showAlertViewWithError:error];
    }
  }];

}

#pragma mark Helper Methods

- (void) addCommentBox {
  
  self.commentConstraint.constant += self.deviceHasShortScreen ? 80 : 140;
  self.chatConstraint.constant += self.deviceHasShortScreen ? 80 : 140;
  self.commentFieldHeightConstraint.constant = self.deviceHasShortScreen ? 64 : 128;
  self.writeCommentTextField.hidden = false;
  self.writeCommentTextField.alpha = 0;
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        [self.view layoutSubviews];
                        self.writeCommentTextField.alpha = 1;
                        self.commentButton.alpha = 0;
                        self.chatButton.alpha = 0;
                        self.cancelButton.alpha = 1;
                        self.submitButton.alpha = 1;
                        
                      } completion:^(BOOL finished) {
                        self.commentButton.enabled = false;
                        self.chatButton.enabled = false;
                      }];
  
}

-(void) removeCommentBox {
  [self.writeCommentTextField resignFirstResponder];
  self.commentConstraint.constant -= self.deviceHasShortScreen ? 80 : 140;;
  self.chatConstraint.constant -= self.deviceHasShortScreen ? 80 : 140;;
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        [self.view layoutSubviews];
                        self.writeCommentTextField.alpha = 0.0;
                        self.commentButton.alpha = 1;
                        self.chatButton.alpha = 1;
                        self.cancelButton.alpha = 0;
                        self.submitButton.alpha = 0;
                      } completion:^(BOOL finished) {
                        self.commentButton.enabled = true;
                        self.chatButton.enabled = true;
                        self.writeCommentTextField.text = @"";
                        self.writeCommentTextField.hidden = true;
                        self.writeCommentTextField.alpha = 0;
                      }];

  
}

-(NSString *) getFuzzyDateFromDate: (NSDate *) date{
  
  NSTimeInterval secondsSinceNow = [date timeIntervalSinceNow] * -1;
  if (secondsSinceNow < 10) {
    return @"Just now";
  }
  if (secondsSinceNow < 60) {
    return [NSString stringWithFormat:@"%d seconds ago", (int)(secondsSinceNow / 1)];
  }
  if (secondsSinceNow < (60 * 60)) {
    int minutes = secondsSinceNow / 60;
    if (minutes < 2) {
      return @"1 minute ago";
    } else {
    return [NSString stringWithFormat:@"%d minutes ago", minutes];
    }
  }
  if (secondsSinceNow < (60 * 60 * 48)) {
    int hours = secondsSinceNow / 60 / 60;
    if (hours < 2) {
      return @"1 hour ago";
    } else {
      return [NSString stringWithFormat:@"%d hours ago", hours];
    }
  }
  return @"Unknown!";
}

-(void)requestDot {
  
  [self.networkController getDotByID:self.dot.identifier completionHandler:^(NSError *error, Dot *dot) {
    if (dot != nil) {
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.dot = dot;
        [self.tableView reloadData];
        self.numberOfStarsLabel.text = [self.dot.stars stringValue];
        self.userDidStar = self.dot.userHasStarred;
        if (self.userDidStar) {
          self.star.text = @"\ue105";
        } else {
          self.star.text = @"\ue108";
        }
      }];
    } else {
      [self showAlertViewWithError:error];
    }
  }];
  
}

- (void) didTapViewToDismiss:(UITapGestureRecognizer *) sender {
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self.writeCommentTextField resignFirstResponder];
  }
  
}

-(void) showAlertViewWithError:(NSError *) error {
  
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

- (void) didTapFlag:(UITapGestureRecognizer *) sender {
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    //[self.networkController ];
  }
  
}
  


@end
