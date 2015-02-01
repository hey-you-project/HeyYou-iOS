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
  self.token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
  self.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
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

#pragma mark Data Task Sending

- (void) sendRequest: (NSURLRequest *) request withCompletionHandler: (void (^)(NSError *error, NSData *data)) completionHandler {
  
  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"%@", error.localizedDescription);
      completionHandler(error, nil);
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode >= 200 && statusCode <= 299) {
          completionHandler(nil, data);
        } else {
          NSError *responseError = [ErrorHandler errorFromHTTPResponse:httpResponse data:data];
            completionHandler(responseError, nil);
        }
      }
    }
  }];
  
  [dataTask resume];

}

#pragma mark GET methods

- (void)fetchDotsWithRegion: (MKCoordinateRegion) region completionHandler: (void (^)(NSError *error, NSArray *dots))completionHandler {
  
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/dots/", self.url];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"GET";
  NSDictionary *geoframeDictionary = [self getCoordRangeFromRegion:region];
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:geoframeDictionary options:0 error:&error];
  NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  [request setValue:jsonString forHTTPHeaderField:@"Zone"];
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, nil);
    } else {
      NSArray *array = [Dot parseJSONIntoDots:data];
      completionHandler(nil,array);
    }
    
  }];
  
}

- (void)getDotByID: (NSString *)dotID completionHandler: (void (^)(NSError *error, Dot * dot))completionHandler {
  
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/dots/%@", self.url, dotID];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
  if (token != nil) {
    [request setValue:token forHTTPHeaderField:@"jwt"];
  }
  request.HTTPMethod = @"GET";
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, nil);
    } else {
      NSArray *array = [Dot parseJSONIntoDots:data];
      if (array.count > 0 && [array[0] isKindOfClass:[Dot class]]) {
        Dot *dot = array[0];
        completionHandler(nil,dot);
      }
    }
    
  }];
  
}


- (void)getAllMyDotsWithCompletionHandler: (void (^)(NSError *error, NSArray * dots))completionHandler {
  
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/dots/mydots", self.url];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"GET";
  NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
  [request setValue:token forHTTPHeaderField:@"jwt"];
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, nil);
    } else {
      NSArray *array = [Dot parseJSONIntoDots:data];
      completionHandler(nil,array);
      
    }
    
  }];

}

- (void)getAllChatPartnersWithCompletionHandler: (void (^)(NSError *error, NSArray * messages))completionHandler {
  
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/messages/", self.url];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"GET";
  NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
  [request setValue:token forHTTPHeaderField:@"jwt"];
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, nil);
    } else {
      NSError *error;
      NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
      completionHandler(nil,array);
    }
    
  }];
  
}

- (void)getMessagesFromUser:(NSString *)username withCompletionHandler: (void (^)(NSError *error, NSArray * messages))completionHandler {
  
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/messages/%@", self.url, username];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"GET";
  NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
  [request setValue:token forHTTPHeaderField:@"jwt"];
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, nil);
    } else {
      NSArray *array = [Message parseJSONIntoMessages:data];
      completionHandler(nil,array);
    }
    
  }];

}

- (void)fetchTokenWithUsername: (NSString *)username password:(NSString*)password completionHandler: (void (^)(NSError *error, bool success))completionHandler {
  
  NSString *fullURLString = [NSString stringWithFormat:@"%@api/users/", self.url];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"GET";
  NSString *authStringPlain = [NSString stringWithFormat: @"%@:%@", username, password];
  NSData *authStringData = [authStringPlain dataUsingEncoding:NSUTF8StringEncoding];
  NSString *authStringBase64 = [authStringData base64EncodedStringWithOptions:0];
  NSString *authStringFull = [NSString stringWithFormat:@"Basic %@", authStringBase64];
  [request setValue:authStringFull forHTTPHeaderField:@"Authorization"];
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, NO);
    } else {
      NSError *authError;
      NSDictionary *tokenJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&authError];
      if ((self.token = tokenJSON[@"jwt"])) {
        if ([self.token isKindOfClass:[NSString class]] && self.token != nil) {
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSUserDefaults standardUserDefaults] setValue:self.token forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            completionHandler(nil, YES);
          }];
        }
      }
    }
  }];
  
}

#pragma mark POST methods

- (void)postDot: (Dot*)dot completionHandler: (void (^)(NSError *error, bool success))completionHandler {
  
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/dots/", self.url];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"POST";
  NSData *dotJSONData = [dot parseDotIntoJSON];
  NSUInteger length = dotJSONData.length;
  [request setValue:[NSString stringWithFormat:@"%li", (unsigned long)length] forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
  [request setValue:token forHTTPHeaderField:@"jwt"];
  request.HTTPBody = dotJSONData;
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, NO);
    } else {
      NSError *postError;
      NSDictionary *successJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error: &postError];
      NSTimeInterval timestamp = [successJSON[@"time"] doubleValue] / 1000;
      dot.timestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
      dot.identifier = successJSON[@"dot_id"];
      completionHandler(nil, YES);
    }
    
  }];

}

- (void)postComment: (NSString *) comment forDot:(Dot*)dot completionHandler: (void (^)(NSError *error, bool success))completionHandler {
  
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/comments/%@", self.url, dot.identifier];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"POST";
  NSDictionary *commentDictionary = @{@"text" : comment};
  NSError *error;
  NSData *JSONData = [NSJSONSerialization dataWithJSONObject:commentDictionary options:NSJSONWritingPrettyPrinted error:&error];
  NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:token forHTTPHeaderField:@"jwt"];
  request.HTTPBody = JSONData;
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, NO);
    } else {
      completionHandler(nil, YES);
    }
    
  }];
  
}

- (void)createUserWithUsername: (NSString*)username password:(NSString*)password birthday:(NSDate*)birthday email:(NSString*)email completionHandler:(void (^)(NSError *error, bool success))completionHandler {
  NSString *fullURLString = [NSString stringWithFormat: @"%@api/users/", self.url];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"POST";
  NSData *jsonData = [self makeNewUserJSON:username password:password birthday:birthday email:email];
  NSUInteger length = jsonData.length;
  [request setValue:[NSString stringWithFormat:@"%li", (unsigned long)length] forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  request.HTTPBody = jsonData;
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, NO);
    } else {
      NSError *authError;
      NSDictionary *tokenJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&authError];
      if ((self.token = tokenJSON[@"jwt"])) {
        if ([self.token isKindOfClass:[NSString class]] && self.token != nil) {
          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSUserDefaults standardUserDefaults] setValue:self.token forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            completionHandler(nil, YES);
          }];
        }
      }
    }
    
  }];

}

- (void)postToggleStarOnDot: (Dot*)dot completionHandler:(void (^)(NSError *error, bool success))completionHandler {
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/stars/%@", self.url, dot.identifier];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"POST";
  NSString *token = [[NetworkController sharedController] token];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:token forHTTPHeaderField:@"jwt"];
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    if (error) {
      completionHandler(error, NO);
    } else {
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        completionHandler(nil, YES);
      }];
    }
    
  }];

}

-(void)postMessage: (NSString *)text toUser: (NSString *)username withCompletionHandler: (void (^)(NSError *error, bool success))completionHandler {
  NSString *fullURLString = [NSString stringWithFormat: @"%@v1/api/messages/%@", self.url, username];
  NSURL *fullURL = [NSURL URLWithString:fullURLString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL];
  request.HTTPMethod = @"POST";
  NSString *token = [[NetworkController sharedController] token];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:token forHTTPHeaderField:@"jwt"];
  NSError *error;
  request.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"text":text} options:0 error:&error];
  
  [self sendRequest:request withCompletionHandler:^(NSError *error, NSData *data) {
    
    completionHandler(error, (error == nil));

  }];
  
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
  NSNumber *formattedBirthday = [NSNumber numberWithDouble:[birthday timeIntervalSince1970] * 1000];
  
  [userDictionary setObject:username forKey:@"username"];
  [userDictionary setObject:password forKey:@"password"];
  [userDictionary setObject:formattedBirthday forKey:@"birthday"];
  [userDictionary setObject:email forKey:@"email"];
  
  NSError *error;
  NSData *userJSONData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&error];
  
  return userJSONData;
}


@end
