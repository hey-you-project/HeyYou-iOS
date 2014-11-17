//
//  Comment.h
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Comment : NSObject

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSDate *timestamp;

@end
