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

    CGFloat width = rect.size.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, width / 10.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextAddEllipseInRect(context, CGRectInset(rect, 3, 3));
    CGContextDrawPath(context, kCGPathFillStroke);
  
}


@end
