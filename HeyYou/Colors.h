//
//  Colors.h
//  HeyYou
//
//  Created by Cameron Klein on 11/25/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Colors : NSObject

+ (id)singleton;
- (UIColor *) getColorFromString: (NSString *) colorName;

@property (nonatomic, strong) UIColor *flatTurquoise;
@property (nonatomic, strong) UIColor *flatGreen;
@property (nonatomic, strong) UIColor *flatBlue;
@property (nonatomic, strong) UIColor *flatPurple;
@property (nonatomic, strong) UIColor *flatYellow;
@property (nonatomic, strong) UIColor *flatOrange;
@property (nonatomic, strong) UIColor *flatRed;
@property (nonatomic, strong) UIColor *flatGray;

@end
