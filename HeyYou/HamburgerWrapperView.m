//
//  HamburgerWrapperView.m
//  HeyYou
//
//  Created by Cameron Klein on 12/2/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "HamburgerWrapperView.h"

@interface HamburgerWrapperView()

@property (nonatomic, strong) CALayer *maskLayer;

@end

@implementation HamburgerWrapperView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    self.maskLayer = [CALayer new];
    [self.layer addSublayer: self.maskLayer];
  }
  return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
  
  UIBezierPath *path = [UIBezierPath bezierPath];
  CGFloat minX = rect.origin.x;
  CGFloat maxX = rect.origin.x + rect.size.width;
  CGFloat minY = rect.origin.y;
  CGFloat maxY = rect.origin.y + rect.size.height;
  
  [path moveToPoint:CGPointMake(minX + 30, maxY)];
  [path addQuadCurveToPoint:CGPointMake(minX, maxY - 30) controlPoint:CGPointMake(minX, maxY)];
  [path addLineToPoint:CGPointMake(minX, minY + 30)]; //Lower Right Pre Curve
  [path addQuadCurveToPoint:CGPointMake(minX + 30, minY) controlPoint:CGPointMake(minX, minY)]; // Lower Right Post Curve
  [path addLineToPoint:CGPointMake(maxX - 30, minY)]; //Pre Point
  [path addQuadCurveToPoint:CGPointMake(maxX, minY + 30) controlPoint:CGPointMake(maxX, minY)]; // Lower Right Post Curve
  [path addLineToPoint:CGPointMake(maxX, maxY - 90)];
  [path addQuadCurveToPoint:CGPointMake(maxX - 30, maxY - 60) controlPoint:CGPointMake(maxX, maxY - 60)];
  [path addLineToPoint:CGPointMake(minX + 90, maxY - 60)];
  [path addQuadCurveToPoint:CGPointMake(minX + 60, maxY - 30) controlPoint:CGPointMake(minX + 60, maxY - 60)];
  [path addQuadCurveToPoint:CGPointMake(minX + 30, maxY) controlPoint:CGPointMake(minX + 60, maxY)];
  
  CAShapeLayer *shapeLayer = [CAShapeLayer new];
  shapeLayer.path = [path CGPath];
  
  self.layer.shadowPath = [path CGPath];
  
  self.layer.mask = shapeLayer;
  self.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.layer.shadowOpacity = 0.6;
  self.layer.shadowRadius = 3.0;
  self.layer.shadowOffset = CGSizeMake(0, 3);
  
}


@end
