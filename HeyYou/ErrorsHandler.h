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
  HYBadRequestError,
  HYJSONParsingError,
  HY500LevelError
};
