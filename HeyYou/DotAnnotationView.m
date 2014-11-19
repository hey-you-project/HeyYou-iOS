//
//  DotAnnotationView.m
//  HeyYou
//
//  Created by Cameron Klein on 11/18/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "DotAnnotationView.h"

@implementation DotAnnotationView

- (void)drawRect:(CGRect)rect {
  NSLog(@"Draw Rect Called!");
  
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 2.0);
  CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
  CGContextSetFillColorWithColor(context, self.color.CGColor);
  CGContextAddEllipseInRect(context, CGRectInset(rect, 3, 3));
//  CGContextFillEllipseInRect(context, rect);
//  CGContextStrokePath(context);
  CGContextDrawPath(context, kCGPathFillStroke);
  
}


@end
