//
//  Message.h
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString *otherUser;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSDate *timestamp;

+ (NSArray *) parseJSONIntoMessages: (NSData *) data;

@end
