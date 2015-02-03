//
//  Colors.h
//  HeyYou
//
//  Created by Cameron Klein on 11/25/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Colors : NSObject

+ (UIColor *) flatTurquoise;
+ (UIColor *) flatBlue;
+ (UIColor *) flatYellow;
+ (UIColor *) flatOrange;
+ (UIColor *) flatRed;
+ (UIColor *) flatGray;
+ (UIColor *) flatGreen;
+ (UIColor *) flatPurple;

+ (UIColor *) getColorFromString: (NSString *) colorName;
+ (UIColor *) randomColor;

@end
