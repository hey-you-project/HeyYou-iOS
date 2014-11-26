//
//  Colors.m
//  HeyYou
//
//  Created by Cameron Klein on 11/25/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "Colors.h"

@implementation Colors

#pragma mark Singleton method

+ (id)singleton{
  static Colors *colors = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    colors = [[self alloc] init];
  });
  return colors;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.flatTurquoise  = [UIColor colorWithRed: 26  / 255.0 green: 188 / 255.0 blue: 156 / 255.0 alpha: 1];
    self.flatBlue       = [UIColor colorWithRed: 52  / 255.0 green: 152 / 255.0 blue: 219 / 255.0 alpha: 1];
    self.flatYellow     = [UIColor colorWithRed: 241 / 255.0 green: 196 / 255.0 blue: 15  / 255.0 alpha: 1];
    self.flatOrange     = [UIColor colorWithRed: 212 / 255.0 green: 83  / 255.0 blue: 36  / 255.0 alpha: 1];
    self.flatRed        = [UIColor colorWithRed: 212 / 255.0 green: 37  / 255.0 blue: 37  / 255.0 alpha: 1];
    self.flatGray       = [UIColor colorWithRed: 52  / 255.0 green: 73  / 255.0 blue: 94  / 255.0 alpha: 1];
    self.flatGreen      = [UIColor colorWithRed: 46  / 255.0 green: 204 / 255.0 blue: 113 / 255.0 alpha: 1];
    self.flatPurple     = [UIColor colorWithRed: 155 / 255.0 green: 89  / 255.0 blue: 182 / 255.0 alpha: 1];
  }
  return self;
}

- (UIColor *) getColorFromString: (NSString *) colorName {
  
  if ([colorName isEqualToString:@"orange"]) {
    return self.flatOrange;
  } else if ([colorName isEqualToString:@"blue"]) {
    return self.flatBlue;
  } else if ([colorName isEqualToString:@"turquoise"]) {
    return self.flatTurquoise;
  } else if ([colorName isEqualToString:@"purple"]) {
    return self.flatPurple;
  } else if ([colorName isEqualToString:@"yellow"]) {
    return self.flatYellow;
  } else if ([colorName isEqualToString:@"green"]) {
    return self.flatGreen;
  } else {
    return self.flatRed;
  }
  
}

@end
