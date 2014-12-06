//
//  PopupView.h
//  HeyYou
//
//  Created by Cameron Klein on 11/24/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView

@property CGPoint touchPoint;
@property (nonatomic, strong) UIColor* strokeColor;
@property BOOL popFromSide;

@end
