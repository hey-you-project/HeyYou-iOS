//
//  PopupView.m
//  HeyYou
//
//  Created by Cameron Klein on 11/24/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "PopupView.h"

@implementation PopupView

-(void) drawRect:(CGRect)rect {
  
  NSLog(@"Draw Rect Called: %f,%f", self.touchPoint.x, self.touchPoint.y);
  
  UIBezierPath *path = [UIBezierPath bezierPath];
  CGFloat minX = rect.origin.x + 2;
  CGFloat maxX = rect.origin.x + rect.size.width - 2;
  CGFloat minY = rect.origin.y + 2;
  CGFloat maxY = rect.origin.y + rect.size.height;
  
  if (self.popFromSide) {
    
    [path moveToPoint:CGPointMake(minX + 10, minY)];
    [path addLineToPoint:CGPointMake(maxX - 40, minY)];
    [path addQuadCurveToPoint:CGPointMake(maxX - 30, minY + 10) controlPoint:CGPointMake(maxX-30, minY)];
    [path addLineToPoint:CGPointMake(maxX - 30, self.touchPoint.y - 20)];
    [path addQuadCurveToPoint:self.touchPoint controlPoint:CGPointMake(self.touchPoint.x - 20, self.touchPoint.y)];
    [path addQuadCurveToPoint:CGPointMake(maxX - 30, self.touchPoint.y + 20) controlPoint:CGPointMake(self.touchPoint.x - 20, self.touchPoint.y)];
    [path addLineToPoint:CGPointMake(maxX - 30, maxY - 10)];
    [path addQuadCurveToPoint:CGPointMake(maxX - 40, maxY) controlPoint:CGPointMake(maxX - 30, maxY)];
    [path addLineToPoint:CGPointMake(minX + 10, maxY)];
    [path addQuadCurveToPoint:CGPointMake(minX, maxY - 10) controlPoint:CGPointMake(minX, maxY)];
    [path addLineToPoint:CGPointMake(minX, minY + 10)];
    [path addQuadCurveToPoint:CGPointMake(minX + 10, minY) controlPoint:rect.origin];
    
  } else {
    
    [path moveToPoint:CGPointMake(minX + 10, minY)];
    [path addLineToPoint:CGPointMake(maxX - 10, minY)];
    [path addQuadCurveToPoint:CGPointMake(maxX, minY + 10) controlPoint:CGPointMake(maxX, minY)];
    [path addLineToPoint:CGPointMake(maxX, maxY - 30)];
    [path addQuadCurveToPoint:CGPointMake(maxX - 10, maxY - 20) controlPoint:CGPointMake(maxX, maxY - 20)];
    [path addLineToPoint:CGPointMake(self.touchPoint.x + 20, maxY - 20)];
    [path addQuadCurveToPoint:self.touchPoint controlPoint:CGPointMake(self.touchPoint.x, self.touchPoint.y - 20)];
    [path addQuadCurveToPoint:CGPointMake(self.touchPoint.x - 20, maxY - 20) controlPoint:CGPointMake(self.touchPoint.x, self.touchPoint.y - 20)];
    [path addLineToPoint:CGPointMake(minX + 10, maxY - 20)];
    [path addQuadCurveToPoint:CGPointMake(minX, maxY - 30) controlPoint:CGPointMake(minX, maxY-20)];
    [path addLineToPoint:CGPointMake(minX, minY + 10)];
    [path addQuadCurveToPoint:CGPointMake(minX + 10, minY) controlPoint:rect.origin];
  
  }
  
  [self.strokeColor setStroke];
  path.lineWidth = 4;
  [path stroke];
  UIView *superView = self.superview;
  
  CAShapeLayer *shapeLayer = [CAShapeLayer new];
  shapeLayer.path = [path CGPath];
  
  superView.layer.mask = shapeLayer;
  
}

@end

