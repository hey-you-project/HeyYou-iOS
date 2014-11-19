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

@interface MapViewController : UIViewController <MKMapViewDelegate>

-(void) changeDotColor:(NSString *)color;
-(void)addNewAnnotationForDot:(Dot*) dot;
-(void) unpopCurrentComment;
-(void) returnDragCircleToHomeBase;

@property (nonatomic, strong) MKMapView *mapView;
//@property PostingViewController *popupController;
@property (nonatomic, strong) UIViewController *currentPopup;
@property (nonatomic, strong) SideMenuViewController *sideMenuVC;
@property (nonatomic, strong) UILabel *hamburgerLabel;
@property (nonatomic, strong) UIView *hamburgerWrapper;
@property (nonatomic, strong) UIView *draggableCircle;
@property UIView *dragCircleWrapper;
@property CGPoint originalCircleCenter;


//
//// MARK: Constants
//var kHorizontalCurveOffset : CGFloat = 2
//var kVerticalCurveOffset   : CGFloat = 15
//var kPopupHeight           : CGFloat = 540
@end

