//
//  UIView_UIView_Shadow.h
//  heyyou
//
//  Created by Cameron Klein on 2/10/15.
//  Copyright (c) 2015 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Shadow)

- (void) addShadowWithOpacity: (CGFloat) opacity radius: (CGFloat) radius offsetX: (CGFloat) offsetX offsetY: (CGFloat) offsetY;

@end
