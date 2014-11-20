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
    self.url = @"https://hey-you-api.herokuapp.com/";
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

- (void)fetchDotsWithRegion: (MKCoordinateRegion) region completionHandler: (void (^)(NSString *, NSArray *))completionHandler {
    NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/dots/", self.url];
    NSURL *fullURL = [NSURL URLWithString:fullURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
    request.HTTPMethod = @"GET";
    NSDictionary *geoframeDictionary = [self getCoordRangeFromRegion:region];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:geoframeDictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);
    [request setValue:jsonString forHTTPHeaderField:@"Zone"];
  // NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
//    NSLog(@"Token:%@", token);
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:token forHTTPHeaderField:@"jwt"];
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

- (void)getDotByID: (NSString *)dotID completionHandler: (void (^)(NSString * error, Dot * dot))completionHandler {
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/dots/%@", self.url, dotID];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"GET";
  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error != nil) {
      NSLog(@"%@", error.localizedDescription);
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode >= 200 && statusCode <= 299) {
          NSArray *array = [Dot parseJSONIntoDots:data];
          NSLog(@"getDotByID: received %@", [array description]);
          if (array.count > 0 && [array[0] isKindOfClass:[Dot class]]) {
            Dot *dot = array[0];
            NSLog(@"dot body = %@", dot.body);
            completionHandler(nil,dot);
          }
        } else {
          NSLog(@"%@", httpResponse.description);
        }
      }
    }
  }];
  [dataTask resume];
}

- (void)fetchTokenWithUsername: (NSString *)username password:(NSString*)password completionHandler: (void (^)(NSString *error, bool success))completionHandler {
  NSString *fullURLString = [NSString stringWithFormat:@"%@api/users/", self.url];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"GET";
  NSString *authStringPlain = [NSString stringWithFormat: @"%@:%@", username, password];
  NSData *authStringData = [authStringPlain dataUsingEncoding:NSUTF8StringEncoding];
  NSString *authStringBase64 = [authStringData base64EncodedStringWithOptions:0];
  NSString *authStringFull = [NSString stringWithFormat:@"Basic %@", authStringBase64];
  [request setValue:authStringFull forHTTPHeaderField:@"Authorization"];
  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error != nil) {
      NSLog(@"%@", error.localizedDescription);
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode >= 200 && statusCode <= 299) {
          NSError *authError;
          NSDictionary *tokenJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&authError];
          if ((self.token = tokenJSON[@"jwt"])) {
            if ([self.token isKindOfClass:[NSString class]] && self.token != nil) {
              NSLog(@"Success! Got token!");
              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[NSUserDefaults standardUserDefaults] setValue:self.token forKey:@"token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                completionHandler(nil, YES);
              }];
            }
          }
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
    NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/dots/", self.url];
    NSURL *fullURL = [NSURL URLWithString:fullURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
    request.HTTPMethod = @"POST";
    NSData *dotJSONData = [dot parseDotIntoJSON];
    NSUInteger length = dotJSONData.length;
    [request setValue:[NSString stringWithFormat:@"%li", (unsigned long)length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"jwt"];
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

- (void)postComment: (NSString *) comment forDot:(Dot*)dot completionHandler: (void (^)(NSString *error, bool success))completionHandler {
  NSLog(@"Post Comment Called!");
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/comments/%@", self.url, dot.identifier];
  NSLog(@"%@", fullURLString);
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"POST";
  NSDictionary *commentDictionary = @{@"text" : comment};
  NSError *error;
  NSData *JSONData = [NSJSONSerialization dataWithJSONObject:commentDictionary options:NSJSONWritingPrettyPrinted error:&error];
  //NSUInteger length = JSONData.length;
  //[request setValue:[NSString stringWithFormat:@"%li", (unsigned long)length] forHTTPHeaderField:@"Content-Length"];
  NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:token forHTTPHeaderField:@"jwt"];
  request.HTTPBody = JSONData;
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
          NSLog(@"%@", successJSON.description);
//          NSString *returnString = [successJSON[@"time"] doubleValue] / 1000;
//          dot.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
//          dot.identifier = successJSON[@"dot_id"];
//          NSLog(@"Time: %@ Id: %@", dot.timestamp.description, dot.identifier);
          completionHandler(nil, YES);
        } else {
          NSLog(@"%@", httpResponse.description);
        }
      }
    }
  }];
  [dataTask resume];
}

- (void)createUserWithUsername: (NSString*)username password:(NSString*)password birthday:(NSDate*)birthday email:(NSString*)email completionHandler:(void (^)(NSString *error, bool success))completionHandler {
  NSString *fullURLString = [NSString stringWithFormat: @"%@api/users/", self.url];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"POST";
  NSData *jsonData = [self makeNewUserJSON:username password:password birthday:birthday email:email];
  NSUInteger length = jsonData.length;
  [request setValue:[NSString stringWithFormat:@"%li", (unsigned long)length] forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPBody = jsonData;
  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error != nil) {
      NSLog(@"%@", error.localizedDescription);
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode >= 200 && statusCode <= 299) {
          NSError *authError;
          NSDictionary *tokenJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&authError];
          if ((self.token = tokenJSON[@"jwt"])) {
            if ([self.token isKindOfClass:[NSString class]] && self.token != nil) {
              NSLog(@"Success! Created user!");
              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(nil, YES);
              }];
            }
          }
        } else {
          NSLog(@"%@", httpResponse.description);
        }
      }
    }
  }];
  [dataTask resume];
}

#pragma mark Helper methods

- (NSDictionary*)getCoordRangeFromRegion: (MKCoordinateRegion) coordRegion {
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

- (NSData*)makeNewUserJSON: (NSString*)username password:(NSString*)password birthday:(NSDate*)birthday email:(NSString*)email {
  NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
  [userDictionary setObject:username forKey:@"username"];
  NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
  NSString *passwordBase64 = [passwordData base64EncodedStringWithOptions:0];
  [userDictionary setObject:passwordBase64 forKey:@"password"];
  NSNumber *formattedBirthday = [NSNumber numberWithDouble:[birthday timeIntervalSince1970] * 1000];
  [userDictionary setObject:formattedBirthday forKey:@"birthday"];
  [userDictionary setObject:email forKey:@"email"];
  NSError *error;
  NSData *userJSONData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&error];
  return userJSONData;
}

@end
