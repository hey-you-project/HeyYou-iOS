//
//  ClusterAnnotationView.m
//  HeyYou
//
//  Created by Cameron Klein on 2/3/15.
//  Copyright (c) 2015 Hey You!. All rights reserved.
//

#import "ClusterAnnotationView.h"
#import "Colors.h"

@implementation ClusterAnnotationView

- (void)drawRect:(CGRect)rect {
//  
//  CGFloat width = rect.size.width;
//  CGContextRef context = UIGraphicsGetCurrentContext();
//  CGContextSetLineWidth(context, width / 10.0f);
//  CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);

//  CGRect rect1 = CGRectMake(rect.origin.x + 2, rect.origin.y + 2, rect.size.width / 2, rect.size.height / 2);
//  CGContextSetFillColorWithColor(context, [Colors randomColor].CGColor);
//  CGContextFillEllipseInRect(context, rect1);
//  CGContextSetLineWidth(context, rect1.size.width / 10.0f);
//  CGContextStrokeEllipseInRect(context, rect1);
  
//  CGRect rect2 = CGRectMake(rect.size.width / 2 - 2, rect.origin.y + 2, rect.size.width / 2, rect.size.height / 2);
//  CGContextSetFillColorWithColor(context, [Colors randomColor].CGColor);
//  CGContextFillEllipseInRect(context, rect2);
//  CGContextSetLineWidth(context, rect2.size.width / 10.0f);
//  CGContextStrokeEllipseInRect(context, rect2);
//  
//  CGRect rect3 = CGRectMake(rect.size.width / 4, rect.size.height / 2 - 2, rect.size.width / 2, rect.size.height / 2);
//  CGContextSetFillColorWithColor(context, [Colors randomColor].CGColor);
//  CGContextFillEllipseInRect(context, rect3);
//  CGContextSetLineWidth(context, rect3.size.width / 10.0f);
//  CGContextStrokeEllipseInRect(context, rect3);
  
  CGFloat width = rect.size.width;
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, width / 10.0f);
  CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
  CGContextSetFillColorWithColor(context, [[Colors flatGray] CGColor]);
  CGContextAddEllipseInRect(context, CGRectInset(rect, 3, 3));
  CGContextDrawPath(context, kCGPathFillStroke);
  
}

@end
