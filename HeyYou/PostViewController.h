//
//  PostViewController.h
//  HeyYou
//
//  Created by Cameron Klein on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Dot.h"
#import "PopupView.h"
#import "PopupViewController.h"

@class MapViewController;

@interface PostViewController : UIViewController <PopupViewController>

#pragma mark IBOutlets

@property (weak, nonatomic) IBOutlet UITextView *bodyTextField;
@property (weak, nonatomic) IBOutlet UITextView *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *miniTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageBodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dotColorLabel;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet UIView *notLoggedInMessage;


@property (weak, nonatomic) IBOutlet UIView *colorWrapper;

@property (weak, nonatomic) IBOutlet UILabel *purpleLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueLabel;
@property (weak, nonatomic) IBOutlet UILabel *orangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *tealLabel;
@property (weak, nonatomic) IBOutlet UILabel *yellowLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyFieldHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *purpleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tealConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yellowConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blueConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *greenConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orangeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinkConstraint;
@property (weak, nonatomic) IBOutlet PopupView *borderView;

#pragma mark properties

@property (nonatomic, strong) MapViewController *delegate;
@property (nonatomic, strong) UIColor *colorUI;
@property CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *color;



@end
