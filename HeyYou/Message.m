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
  
  NSError *error;
  NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
  NSLog(@"Attempting to parse: %@",array.description);
  NSMutableArray *tempArray = [NSMutableArray new];
  for (NSDictionary *messageDictionary in array) {
    
    Message *message = [Message new];
    message.fromUser = messageDictionary[@"from_username"];
    message.toUser = messageDictionary[@"to_username"];
    message.body = messageDictionary[@"text"];
    NSTimeInterval timestamp = [messageDictionary[@"timestamp"] doubleValue] / 1000;
    message.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    [tempArray addObject:message];
  }
  return tempArray;

}

@end
