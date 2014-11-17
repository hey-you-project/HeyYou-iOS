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

@interface MapViewController : UIViewController

@property (nonatomic, strong) MKMapView *mapView;
//@property PostingViewController *popupController;
@property (nonatomic, strong) UIViewController *currentPopup;
@property (nonatomic, strong) SideMenuViewController *sideMenuVC;
@property (nonatomic, strong) UILabel *hamburgerLabel;
@property (nonatomic, strong) UIView *hamburgerWrapper;
@property (nonatomic, strong) UIView *draggableCircle;
@property UIView *dragCircleWrapper;
@property CGPoint originalCircleCenter;

//// MARK: Color Palette
//let customDarkOrange  = UIColor(red: 250 / 255.0, green: 105 / 255.0, blue: 0   / 255.0, alpha: 1)
//let customLightOrange = UIColor(red: 243 / 255.0, green: 134 / 255.0, blue: 48  / 255.0, alpha: 1)
//let customBlue        = UIColor(red: 105 / 255.0, green: 210 / 255.0, blue: 231 / 255.0, alpha: 1)
//let customTeal        = UIColor(red: 167 / 255.0, green: 219 / 255.0, blue: 216 / 255.0, alpha: 1)
//let customBeige       = UIColor(red: 224 / 255.0, green: 228 / 255.0, blue: 204 / 255.0, alpha: 1)
//
//// MARK: Constants
//var kHorizontalCurveOffset : CGFloat = 2
//var kVerticalCurveOffset   : CGFloat = 15
//var kPopupHeight           : CGFloat = 540
@end

