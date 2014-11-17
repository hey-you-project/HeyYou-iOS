//
//  Dot.m
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "Dot.h"

@implementation Dot

- (instancetype)initWithLocation: (CLLocationCoordinate2D)location color: (NSString*)color title: (NSString*)title body: (NSString*)body {
    self.location = CLLocationCoordinate2DMake(47.606209, -122.332071);
    self.timestamp = [NSDate date];
    self.color = color;
    self.title = title;
    self.stars = 0;
  
    return self;
}

+(NSArray *)parseJSONIntoDots:(NSData *) data {
  
  NSError *error;
  NSArray * dotsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
  
  NSMutableArray *tempArray = [NSMutableArray new];
  
  for (NSDictionary *dotDict in dotsArray) {
    Dot *dot = [Dot new];
    dot.title = dotDict[@"title"];
    dot.body = dotDict[@"body"];
    dot.identifier = dotDict[@"_id"];
    dot.color = dotDict[@"color"];
    dot.stars = dotDict[@"stars"];
    dot.username = dotDict[@"username_id"];
    CLLocationDegrees latitude = (long)dotDict[@"latitude"];
    CLLocationDegrees longitude = (long)dotDict[@"latitude"];
    dot.location = CLLocationCoordinate2DMake(latitude, longitude);
    [tempArray addObject:dot];
  }
  
  return tempArray;
}

@end
