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
  
  [path moveToPoint:CGPointMake(minX + 10, minY)]; //Upper Left Post Curve
  [path addLineToPoint:CGPointMake(maxX - 10, minY)]; //Upper Right Pre Curve
  [path addQuadCurveToPoint:CGPointMake(maxX, minY + 10) controlPoint:CGPointMake(maxX, minY)]; //Upper Right Post Curve
  [path addLineToPoint:CGPointMake(maxX, maxY - 30)]; //Lower Right Pre Curve
  [path addQuadCurveToPoint:CGPointMake(maxX - 10, maxY - 20) controlPoint:CGPointMake(maxX, maxY - 20)]; // Lower Right Post Curve
  [path addLineToPoint:CGPointMake(self.touchPoint.x + 20, maxY - 20)]; //Pre Point
  [path addQuadCurveToPoint:self.touchPoint controlPoint:CGPointMake(self.touchPoint.x, self.touchPoint.y - 20)];
  [path addQuadCurveToPoint:CGPointMake(self.touchPoint.x - 20, maxY - 20) controlPoint:CGPointMake(self.touchPoint.x, self.touchPoint.y - 20)];
  [path addLineToPoint:CGPointMake(minX + 10, maxY - 20)];
  [path addQuadCurveToPoint:CGPointMake(minX, maxY - 30) controlPoint:CGPointMake(minX, maxY-20)];
  [path addLineToPoint:CGPointMake(minX, minY + 10)];
  [path addQuadCurveToPoint:CGPointMake(minX + 10, minY) controlPoint:rect.origin];
  
  [self.strokeColor setStroke];
  path.lineWidth = 4;
  [path stroke];
  UIView *superView = self.superview;
  
  CAShapeLayer *shapeLayer = [CAShapeLayer new];
  shapeLayer.path = [path CGPath];
  
  superView.layer.mask = shapeLayer;
  
}

@end

