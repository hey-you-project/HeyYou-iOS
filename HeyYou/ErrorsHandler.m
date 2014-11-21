//
//  ErrorsHandler.m
//  HeyYou
//
//  Created by William Richman on 11/20/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ErrorsHandler.h"

NSString *const HeyYouErrorDomain = @"org.CodeFellows.HeyYou";

@implementation ErrorHandler

+ (NSError*)errorFromHTTPResponse: (NSHTTPURLResponse*)response data:(NSData*) data {
  NSError *error;
  NSString *errorText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  if ([errorText isKindOfClass:[NSString class]] && errorText != nil) {
    int code = [errorText intValue];
    if (code >= 1000) {
      NSMutableDictionary* details = [NSMutableDictionary dictionary];
      [details setValue: HY_ERROR_LOCALIZED_DESCRIPTION(code) forKey:NSLocalizedDescriptionKey];
      error = [NSError errorWithDomain:HeyYouErrorDomain code:code userInfo:details];
    } else {
      NSMutableDictionary* details = [NSMutableDictionary dictionary];
      [details setValue: HY_ERROR_LOCALIZED_DESCRIPTION(HYServerError) forKey:NSLocalizedDescriptionKey];
      error = [NSError errorWithDomain:HeyYouErrorDomain code:HYServerError userInfo:details];
    }
  } else {
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue: HY_ERROR_LOCALIZED_DESCRIPTION(HYServerError) forKey:NSLocalizedDescriptionKey];
    error = [NSError errorWithDomain:HeyYouErrorDomain code:HYServerError userInfo:details];
  }
  return error;
}

@end