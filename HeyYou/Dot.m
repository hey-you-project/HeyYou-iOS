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
    NSLog(@"Parsing Dot!");
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

- (NSData *)parseDotIntoJSON {
    NSMutableDictionary *dotJSON = [[NSMutableDictionary alloc] init];
    [dotJSON setObject:[NSNumber numberWithDouble:self.location.latitude] forKey:@"latitude"];
    [dotJSON setObject:[NSNumber numberWithDouble:self.location.longitude] forKey:@"longitude"];
    [dotJSON setObject:self.color forKey:@"color"];
    [dotJSON setObject:self.title forKey:@"title"];
    [dotJSON setObject:self.body forKey:@"body"];
    [dotJSON setObject:self.username forKey:@"username_id"];
    NSError *error;
    NSData *dataToReturn = [NSJSONSerialization dataWithJSONObject:dotJSON options:0 error: &error];
    return dataToReturn;
    /* {
     "latitude": "30",
     "longitude": "20",
     "color": "green",
     "title": "its me",
     "body": "you had me at hello",
     "username_id": "smokeyjoe"
     } */
}

@end
