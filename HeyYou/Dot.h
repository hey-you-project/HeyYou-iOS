//
//  Dot.h
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Comment.h"
#import "User.h"

@interface Dot : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSNumber *stars;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSString *username;
@property BOOL annotationAdded;

- (instancetype)initWithLocation: (CLLocationCoordinate2D)location color: (NSString*)color title: (NSString*)title body: (NSString*)body;

+(NSArray *)parseJSONIntoDots:(NSData *) data;

-(NSData *)parseDotIntoJSON;

@end
