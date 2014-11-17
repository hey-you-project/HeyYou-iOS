//
//  Comment.m
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)initwithBody: (NSString*)body user: (User*) user {
    self.body = body;
    self.user = user;
    self.timestamp = [NSDate date];
    return self;
}

- (instancetype)initwithTimestamp: (NSDate*)timestamp body: (NSString*)body user: (User*) user {
    self.timestamp = timestamp;
    self.body = body;
    self.user = user;
    return self;
}

@end
