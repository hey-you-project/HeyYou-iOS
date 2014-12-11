//
//  ChatCell.h
//  HeyYou
//
//  Created by Cameron Klein on 12/10/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ChatCell <NSObject>

@required
@property (weak, nonatomic) UILabel *body;
@property (weak, nonatomic) UIView *labelWrapper;
@property (weak, nonatomic) NSLayoutConstraint *bodyViewConstraint;
@property (weak, nonatomic) UILabel *timeLabel;

@end
