//
//  NetworkController.h
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Dot.h"

@interface NetworkController : NSObject

+ (id)sharedController;

- (void)fetchDotsWithRegion: (MKCoordinateRegion) region completionHandler: (void (^)(NSString *, NSArray *))completionHandler;

- (void)postDot: (Dot*)dot completionHandler: (void (^)(NSString *error, bool success))completionHandler;

@end
