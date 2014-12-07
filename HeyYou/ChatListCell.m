//
//  ChatListCell.m
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "ChatListCell.h"

@implementation ChatListCell

- (void)awakeFromNib {
  
  self.dot.backgroundColor = [UIColor redColor];
  self.dot.layer.cornerRadius = self.dot.frame.size.height / 2;
  self.dot.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.dot.layer.borderWidth = 2;
  self.dot.clipsToBounds = true;
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
