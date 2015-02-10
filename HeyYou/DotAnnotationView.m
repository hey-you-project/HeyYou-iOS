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

- (void) addPoppingAnimation {
  
  self.transform = CGAffineTransformMakeScale(0.1, 0.1);
  int random = arc4random_uniform(400);
  double random2 = random / 1000.0f;
  
  NSTimeInterval delay = (NSTimeInterval)random2;
  
  self.alpha = 0;
  
  [UIView animateWithDuration:0.5
                        delay:delay
       usingSpringWithDamping:0.3
        initialSpringVelocity:0.9
                      options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        self.transform = CGAffineTransformIdentity;
                        self.alpha = 1;
                      }
                   completion:nil
   ];
}

- (void) addLabelWithNumber:(NSUInteger)number {
  
  UILabel *label;
  
  if (self.subviews.count > 0){
    label = self.subviews[0];
  } else {
    label = [[UILabel alloc] initWithFrame:self.bounds];
  }
  label.textAlignment = NSTextAlignmentCenter;
  label.text = [NSString stringWithFormat:@"%@", @(number)];
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
  
  [self addSubview:label];

  
}


@end
