//
//  NSString+NSString_Validate.m
//  HeyYou
//
//  Created by William Richman on 11/20/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "NSString+Validate.h"

@implementation NSString (Validate)

- (BOOL)validate {
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[  ]" options:0 error:nil];
  NSUInteger match = [regex numberOfMatchesInString:self options:0 range: NSMakeRange(0, self.length)];
  if (match > 0) {
    return false;
  }
  return true;
}

@end
