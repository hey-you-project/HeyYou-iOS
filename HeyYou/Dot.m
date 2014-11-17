//
//  Dot.m
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "Dot.h"

@interface Dot ()

@end

@implementation Dot

- (instancetype)initWithLocation: (CLLocationCoordinate2D)location color: (NSString*)color title: (NSString*)title body: (NSString*)body {
    self.location = CLLocationCoordinate2DMake(47.606209, -122.332071);
    self.timestamp = [NSDate date];
    self.color = color;
    self.title = title;
    self.stars = 0;
    
    
    return self;
}

@end
