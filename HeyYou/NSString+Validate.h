//
//  NSString+NSString_Validate.h
//  HeyYou
//
//  Created by William Richman on 11/20/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TextFieldContext) {
  TextFieldContextDefault,
  TextFieldContextPassword,
  TextFieldContextUsername
};

@interface NSString (Validate)

- (BOOL)validate;

@end