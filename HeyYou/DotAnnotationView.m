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
  //if(self.type == 1 ) {
  CGFloat width = rect.size.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width / 10.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextAddEllipseInRect(context, CGRectInset(rect, 3, 3));
    CGContextDrawPath(context, kCGPathFillStroke);
//  } else {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGFloat size = rect.size.width / 2.5;
//    CGFloat offset = rect.size.width / 4;
//    CGRect rect1 = CGRectInset(rect, size, size);
//    rect1 = CGRectOffset(rect1, 0, offset);
//    CGRect rect2 = CGRectInset(rect, size, size);
//    rect2 = CGRectOffset(rect1, -offset, offset);
//    CGRect rect3 = CGRectInset(rect, size, size);
//    rect3 = CGRectOffset(rect1, offset, offset);
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextSetFillColorWithColor(context, self.color.CGColor);
//    
//    CGContextAddEllipseInRect(context, rect1);
//    CGContextAddEllipseInRect(context, rect2);
//    CGContextAddEllipseInRect(context, rect3);
//    
//    CGContextDrawPath(context, kCGPathFillStroke);
//    
//  }
  
}


@end
