//
//  ViewController.h
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SideMenuViewController.h"
#import "PostViewController.h"
#import "Dot.h"
#import "NetworkController.h"
#import "BrowseViewController.h"
#import "DotAnnotation.h"
#import "PopupViewController.h"
#import "FBAnnotationClustering.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, FBClusteringManagerDelegate>

-(void) changeDotColor:(UIColor *)color;
-(void) addNewAnnotationForDot:(Dot*) dot;
-(void) unpopCurrentComment;
-(void) returnDragCircleToHomeBase;
-(void) requestDots;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIViewController<PopupViewController> *currentPopup;
@property (nonatomic, strong) SideMenuViewController *sideMenuVC;

@property (nonatomic, strong) UIView *draggableCircle;
@property (nonatomic, strong) UIView *dragCircleWrapper;
@property (nonatomic, strong) UIView *locationButton;
@property CGPoint originalCircleCenter;

@end

