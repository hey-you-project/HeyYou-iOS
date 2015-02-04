//
//  CellContentView.m
//  HeyYou
//
//  Created by Cameron Klein on 2/3/15.
//  Copyright (c) 2015 Hey You!. All rights reserved.
//

#import "CellContentView.h"
#import "RightSideChatCell.h"
#import "LeftSideChatCell.h"

@implementation CellContentView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

  UIBezierPath *path = [UIBezierPath bezierPath];
  CGFloat minX = rect.origin.x;
  CGFloat maxX = rect.origin.x + rect.size.width;
  CGFloat minY = rect.origin.y;
  CGFloat maxY = rect.origin.y + rect.size.height;
  
  if ([self.superview.superview isKindOfClass:[RightSideChatCell class]]) {

    [path moveToPoint:CGPointMake(minX + 10, minY)];
    [path addLineToPoint:CGPointMake(maxX - 20, minY)];
    [path addQuadCurveToPoint:CGPointMake(maxX - 10, minY + 10) controlPoint:CGPointMake(maxX - 10, minY)];
    [path addLineToPoint:CGPointMake(maxX - 10, maxY - 10)];
    [path addQuadCurveToPoint:CGPointMake(maxX, maxY) controlPoint:CGPointMake(maxX - 10, maxY)];
    [path addLineToPoint:CGPointMake(maxX - 10, maxY)];
    [path addLineToPoint:CGPointMake(minX + 10, maxY)];
    [path addQuadCurveToPoint:CGPointMake(minX, maxY - 10) controlPoint:CGPointMake(minX, maxY)];
    [path addLineToPoint:CGPointMake(minX, minY + 10)];
    [path addQuadCurveToPoint:CGPointMake(minX + 10, minY) controlPoint:rect.origin];
    
  } else {
    
    [path moveToPoint:CGPointMake(minX + 20, minY)];
    [path addLineToPoint:CGPointMake(maxX - 10, minY)];
    [path addQuadCurveToPoint:CGPointMake(maxX, minY + 10) controlPoint:CGPointMake(maxX, minY)];
    [path addLineToPoint:CGPointMake(maxX, maxY - 10)];
    [path addQuadCurveToPoint:CGPointMake(maxX - 10, maxY) controlPoint:CGPointMake(maxX, maxY)];
    [path addLineToPoint:CGPointMake(maxX - 10, maxY)];
    [path addLineToPoint:CGPointMake(minX, maxY)];
    [path addQuadCurveToPoint:CGPointMake(minX + 10, maxY - 10) controlPoint:CGPointMake(minX + 10, maxY)];
    [path addLineToPoint:CGPointMake(minX + 10, minY + 10)];
    [path addQuadCurveToPoint:CGPointMake(minX + 20, minY) controlPoint:CGPointMake(minX + 10, minY)];
    
  }
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextAddPath(context, path.CGPath);
  CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
  CGContextFillPath(context);
  
}


@end
