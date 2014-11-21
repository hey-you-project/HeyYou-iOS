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
  self.location = location;
    self.color = color;
    self.title = title;
    self.stars = 0;
  self.body = body;
    return self;
}

+(NSArray *)parseJSONIntoDots:(NSData *) data {
  
  NSError *error;
  NSArray * dotsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
  NSLog(@"DotsArray: %@", dotsArray.description);
  NSMutableArray *tempArray = [NSMutableArray new];
  if ([dotsArray isKindOfClass:[NSDictionary class]]) {
    //NSLog(@"Found Dict!");
    dotsArray = @[dotsArray];
  }
  
  for (NSDictionary *dotDict in dotsArray) {

    Dot *dot = [Dot new];
    dot.title = dotDict[@"title"];
    dot.body = dotDict[@"post"];
    dot.identifier = dotDict[@"_id"];
    dot.color = dotDict[@"color"];
    dot.stars = [NSNumber numberWithInteger: [dotDict[@"stars"] integerValue]];
    NSLog(@"stars are: %@", dot.stars);
    NSString *hasStarred = dotDict[@"starred"];
    if ([hasStarred  isEqual: @"1"]) {
      dot.userHasStarred = YES;
    } else {
      dot.userHasStarred = NO;
    }
    dot.username = dotDict[@"username"];
    double latitude = [dotDict[@"latitude"] doubleValue];
    double longitude = [dotDict[@"longitude"] doubleValue];
    NSArray *commentArray = dotDict[@"comments"];
    NSTimeInterval timestamp = [dotDict[@"time"] doubleValue] / 1000;
    dot.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    dot.comments = [NSMutableArray new];
    for (NSDictionary *commentDict in commentArray) {
      Comment *comment = [Comment new];
      NSTimeInterval timestamp = [commentDict[@"time"] doubleValue] / 1000;
      comment.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
      comment.user = [[User alloc] initwithUsername:commentDict[@"username"]];
      comment.body = commentDict[@"text"];
      [dot.comments addObject:comment];
    }
    dot.location = CLLocationCoordinate2DMake(latitude, longitude);
    dot.annotationAdded = NO;
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
    [dotJSON setObject:self.body forKey:@"post"];
    [dotJSON setObject:self.username forKey:@"username_id"];
  //NSLog(@"%@", [dotJSON description]);
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
