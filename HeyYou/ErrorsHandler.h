//
//  ErrorsHandler.h
//  HeyYou
//
//  Created by William Richman on 11/20/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

FOUNDATION_EXPORT NSString *const HeyYouErrorDomain;

enum {
  HYUserNotLoggedInError = 1000,
  HYUserBadToken,                 //1001
  HYBadUsernamePasswordError,     //1002
  HYUsernameTaken,                //1003
  HYUsernameLengthError,          //1004
  HYPasswordLengthError,          //1005
  HYUserCreateUnderageError,      //1006
  HYClientError,                  //1007
  HYServerError                   //1008
};

// error handling macros

#define HY_ERROR_KEY(code)                    [NSString stringWithFormat:@"%d", code]
#define HY_ERROR_LOCALIZED_DESCRIPTION(code)  NSLocalizedStringFromTable(HY_ERROR_KEY(code), @"ErrorsHandler", nil)

@interface ErrorHandler : NSObject

+ (NSError*)errorFromHTTPResponse: (NSHTTPURLResponse*)response data:(NSData*)data;

@end