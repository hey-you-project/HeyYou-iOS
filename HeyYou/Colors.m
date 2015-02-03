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

+ (UIColor *) flatTurquoise {
  return [UIColor colorWithRed: 26  / 255.0 green: 188 / 255.0 blue: 156 / 255.0 alpha: 1];
}

+ (UIColor *) flatBlue {
  return [UIColor colorWithRed: 52  / 255.0 green: 152 / 255.0 blue: 219 / 255.0 alpha: 1];
}

+ (UIColor *) flatYellow {
  return [UIColor colorWithRed: 241 / 255.0 green: 196 / 255.0 blue: 15  / 255.0 alpha: 1];
}

+ (UIColor *) flatOrange {
  return [UIColor colorWithRed: 212 / 255.0 green: 83  / 255.0 blue: 36  / 255.0 alpha: 1];
}

+ (UIColor *) flatRed {
  return [UIColor colorWithRed: 212 / 255.0 green: 37  / 255.0 blue: 37  / 255.0 alpha: 1];
}

+ (UIColor *) flatGray {
  return [UIColor colorWithRed: 52  / 255.0 green: 73  / 255.0 blue: 94  / 255.0 alpha: 1];
}

+ (UIColor *) flatGreen {
  return [UIColor colorWithRed: 46  / 255.0 green: 204 / 255.0 blue: 113 / 255.0 alpha: 1];
}

+ (UIColor *) flatPurple {
  return [UIColor colorWithRed: 155 / 255.0 green: 89  / 255.0 blue: 182 / 255.0 alpha: 1];
}

+ (UIColor *) getColorFromString: (NSString *) colorName {
  
  if ([colorName isEqualToString:@"orange"]) {
    return [self flatOrange];
  } else if ([colorName isEqualToString:@"blue"]) {
    return [self flatBlue];
  } else if ([colorName isEqualToString:@"turquoise"]) {
    return [self flatTurquoise];
  } else if ([colorName isEqualToString:@"purple"]) {
    return [self flatPurple];
  } else if ([colorName isEqualToString:@"yellow"]) {
    return [self flatYellow];
  } else if ([colorName isEqualToString:@"green"]) {
    return [self flatGreen];
  } else {
    return [self flatRed];
  }
  
}

+ (UIColor *) randomColor {
  
  int random = arc4random_uniform(6);
  
  switch (random) {
    case 0:
      return [self flatOrange];
    case 1:
      return [self flatBlue];
    case 2:
      return [self flatTurquoise];
    case 3:
      return [self flatPurple];
    case 4:
      return [self flatYellow];
    case 5:
      return [self flatGreen];
    default:
      return [self flatRed];
  }
  
}

@end
