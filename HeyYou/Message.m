//
//  Message.m
//  HeyYou
//
//  Created by Cameron Klein on 12/5/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "Message.h"

@implementation Message

-(instancetype) initWithFrom:(NSString *)from To:(NSString *)to AndText:(NSString *)text{
  self = [super init];
  if(self) {
    self.fromUser = from;
    self.toUser = to;
    self.body = text;
  }
  return self;
}

// Returns array of dictionaries. Eack dictionary has two keys:
// username: NSString
// items: NSArray of Message objects

+ (NSArray *) parseJSONIntoMessages: (NSData *) data{
  
  Message *one = [[Message alloc] initWithFrom:@"fart" To:@"foobar123" AndText:@"Hi!"];
  Message *two = [[Message alloc] initWithFrom:@"fart" To:@"foobar123" AndText:@"How you doing?"];
  Message *three = [[Message alloc] initWithFrom:@"foobar123" To:@"fart" AndText:@"Great!"];
  
  NSDictionary *dict = @{@"username": @"fart",@"items":@[one,two,three]};
  
  
  return @[dict];
}

@end
