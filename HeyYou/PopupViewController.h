//
//  PopupViewController.h
//  HeyYou
//
//  Created by Cameron Klein on 11/24/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopupView.h"

@protocol PopupViewController <NSObject>

@property (weak, nonatomic) PopupView *borderView;

@end
