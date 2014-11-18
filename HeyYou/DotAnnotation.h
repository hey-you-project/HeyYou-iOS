//
//  DotAnnotation.h
//  HeyYou
//
//  Created by Cameron Klein on 11/18/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Dot.h"

@interface DotAnnotation : MKPointAnnotation

@property (nonatomic, strong) Dot *dot;

@end
