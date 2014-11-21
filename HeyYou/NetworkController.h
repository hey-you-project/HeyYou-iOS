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

@interface NetworkController : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSString *token;

+ (id)sharedController;

- (void)fetchDotsWithRegion: (MKCoordinateRegion) region completionHandler: (void (^)(NSError **error, NSArray *dots))completionHandler;

- (void)fetchTokenWithUsername: (NSString *)username password:(NSString*)password completionHandler: (void (^)(NSError **error, bool success))completionHandler;

- (void)postDot: (Dot*)dot completionHandler: (void (^)(NSError **error, bool success))completionHandler;

- (void)createUserWithUsername: (NSString*)username password:(NSString*)password birthday:(NSDate*)birthday email:(NSString*)email completionHandler:(void (^)(NSError **error, bool success))completionHandler;

- (void)postComment: (NSString *) comment forDot:(Dot*)dot completionHandler: (void (^)(NSError **error, bool success))completionHandler;

- (void)getDotByID: (NSString *)dotID completionHandler: (void (^)(NSError ** error, Dot * dot))completionHandler;

@end
