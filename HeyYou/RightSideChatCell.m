//
//  RightSideChatCell.m
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "RightSideChatCell.h"

@implementation RightSideChatCell

- (void)awakeFromNib {
  self.labelWrapper.layer.cornerRadius = 10;
  self.labelWrapper.clipsToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
