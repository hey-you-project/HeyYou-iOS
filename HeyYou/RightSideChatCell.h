//
//  RightSideChatCell.h
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCell.h"

@interface RightSideChatCell : UITableViewCell <ChatCell>
@property (weak, nonatomic) IBOutlet UILabel *body;
@property (weak, nonatomic) IBOutlet UIView *labelWrapper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyViewConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
