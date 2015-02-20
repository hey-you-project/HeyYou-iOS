//
//  UIView+Shadow.m
//  heyyou
//
//  Created by Cameron Klein on 2/10/15.
//  Copyright (c) 2015 Hey You!. All rights reserved.
//

#import "UIView+Shadow.h"

@implementation UIView (Shadow)

- (void)addShadowWithOpacity:(CGFloat)opacity radius:(CGFloat)radius offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY {
  
  self.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.layer.shadowOpacity = opacity;
  self.layer.shadowRadius = radius;
  self.layer.shadowOffset = CGSizeMake(offsetX, offsetY);
  
}


@end