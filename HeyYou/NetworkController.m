//
//  NetworkController.m
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "NetworkController.h"

@interface NetworkController ()

@property (nonatomic, strong) NSString *url;

@end

@implementation NetworkController

- (instancetype)init {
    self.url = @"https://hey-you-api.herokuapp.com/v1/api/";
    return self;
}


#pragma mark Singleton method

+ (id)sharedController {
    static NetworkController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] init];
    });
    return controller;
}

#pragma mark GET methods

- (void)fetchDotsWithRegion: (MKCoordinateRegion) region completionHandler: (void (^)(NSString *, NSMutableArray *))completionHandler {
    NSString *fullURLString = [NSString stringWithFormat: @"%@dots/", self.url];
    NSURL *fullURL = [NSURL URLWithString:fullURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
    request.HTTPMethod = @"GET";
    NSMutableDictionary *geoframeDictionary = [self getCoordRangeFromRegion:region];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:geoframeDictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);
    [request setValue:jsonString forHTTPHeaderField:@"Zone"];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                NSInteger statusCode = httpResponse.statusCode;
                if (statusCode >= 200 && statusCode <= 299) {
                  NSArray *array = [Dot parseJSONIntoDots:data];
                  completionHandler(nil,array);
                } else {
                    NSLog(@"%@", httpResponse.description);
                }
            }
        }
    }];
    [dataTask resume];
}

#pragma mark POST methods

- (void)postDot: (Dot*)dot completionHandler: (void (^)(NSString *error, bool success))completionHandler {
    NSString *fullURLString = [NSString stringWithFormat: @"%@dots/", self.url];
    NSURL *fullURL = [NSURL URLWithString:fullURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
    request.HTTPMethod = @"POST";
    NSData *dotJSONData = [dot parseDotIntoJSON];
    NSUInteger length = dotJSONData.length;
    [request setValue:[NSString stringWithFormat:@"%li", length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPBody = dotJSONData;
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                NSInteger statusCode = httpResponse.statusCode;
                if (statusCode >= 200 && statusCode <= 299) {
                  NSError *postError;
                  NSDictionary *successJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error: &postError];
                  NSTimeInterval timestamp = [successJSON[@"time"] doubleValue] / 1000;
                  dot.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
                  dot.identifier = successJSON[@"dot_id"];
                  NSLog(@"Time: %@ Id: %@", dot.timestamp.description, dot.identifier);
                  completionHandler(nil, YES);
                } else {
                    NSLog(@"%@", httpResponse.description);
                }
            }
        }
    }];
    [dataTask resume];
}

- (NSMutableDictionary*)getCoordRangeFromRegion: (MKCoordinateRegion) coordRegion {
    NSMutableDictionary *rangeDictionary = [[NSMutableDictionary alloc] init];
    NSNumber *latMin = [NSNumber numberWithDouble:(coordRegion.center.latitude - coordRegion.span.latitudeDelta / 2)];
    [rangeDictionary setValue: latMin forKey:@"latMin"];
    NSNumber *latMax = [NSNumber numberWithDouble:(coordRegion.center.latitude + coordRegion.span.latitudeDelta / 2)];
    [rangeDictionary setValue: latMax forKey:@"latMax"];
    NSNumber *longMin = [NSNumber numberWithDouble:(coordRegion.center.longitude - coordRegion.span.longitudeDelta / 2)];
    [rangeDictionary setValue: longMin forKey:@"longMin"];
    NSNumber *longMax = [NSNumber numberWithDouble:(coordRegion.center.longitude + coordRegion.span.longitudeDelta / 2)];
    [rangeDictionary setValue: longMax forKey:@"longMax"];
    return rangeDictionary;
}

@end
