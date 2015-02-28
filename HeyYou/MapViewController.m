//
//  ViewController.m
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "MapViewController.h"
#import "ClusterAnnotationView.h"
#import <QuartzCore/QuartzCore.h>
#import "PopupView.h"
#import "Colors.h"
#import "UIView+Shadow.h"

@interface MapViewController ()

@property (nonatomic, strong) NSMutableDictionary *dots;
@property (nonatomic, strong) Dot *clickedDot;
@property (nonatomic, strong) NSMutableDictionary *popups;
@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) FBClusteringManager *clusteringManager;

@property MKCoordinateRegion lastRegion;
@property BOOL mapFullyLoaded;
@property BOOL didGetLocation;
@property BOOL fingerIsMoving;

#pragma mark Constants

@property CGFloat kLargePopupHeight;

@end

@implementation MapViewController

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.popups = [NSMutableDictionary new];
  self.dots = [NSMutableDictionary new];
  
  self.mapFullyLoaded = false;
  self.didGetLocation = false;
  
  self.clusteringManager = [[FBClusteringManager alloc] init];
  self.clusteringManager.delegate = self;
  
  [self setupMapView];
  [self addCircleView];
  [self setupGestureRecognizers];
  [self addLocationButton];
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  [self checkLocationAuthorizationStatus];
  
  self.networkController = [NetworkController sharedController];
  
  self.mapView.delegate = self;

  self.kLargePopupHeight = self.view.frame.size.height - 130;
  
  UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
  statusBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
  [self.mapView addSubview:statusBar];
  
}

#pragma mark Setup Subview Methods

- (void)setupMapView {
  self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width + 100, self.view.frame.size.height)];
  [self.view addSubview:self.mapView];
  self.mapView.clipsToBounds = true;

}

- (void) addCircleView {
  
  self.dragCircleWrapper = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 100, 60, 60)];
  self.dragCircleWrapper.layer.cornerRadius = self.dragCircleWrapper.frame.size.height / 2;
  self.dragCircleWrapper.layer.backgroundColor = [[Colors flatGreen] CGColor];

  CGRect miniCircleRect = CGRectMake(self.dragCircleWrapper.frame.origin.x + 17.5, self.dragCircleWrapper.frame.origin.y + 17.5, 25, 25);

  self.draggableCircle = [[UIView alloc] initWithFrame:miniCircleRect];
  self.draggableCircle.layer.cornerRadius = self.draggableCircle.frame.size.height / 2;
  self.draggableCircle.backgroundColor = [UIColor whiteColor];
  self.originalCircleCenter = self.draggableCircle.center;

  self.draggableCircle.userInteractionEnabled = false;
  
  [self.dragCircleWrapper addShadowWithOpacity:0.6 radius:3 offsetX:0 offsetY:3];
  [self.draggableCircle addShadowWithOpacity:0.8 radius:1 offsetX:0 offsetY:2];
  [self.view addSubview:self.dragCircleWrapper];
  [self.view addSubview:self.draggableCircle];

  UIPanGestureRecognizer *dragger = [UIPanGestureRecognizer new];
  [dragger addTarget:self action:@selector(receivedDragGestureOnDragCircle:)];
  [self.dragCircleWrapper addGestureRecognizer:dragger];
  
  UITapGestureRecognizer *tapper = [UITapGestureRecognizer new];
  [tapper addTarget:self action:@selector(didTapOnDragCircle:)];
  [self.dragCircleWrapper addGestureRecognizer:tapper];

}

- (void) addLocationButton {
  
  CGFloat width = 40;
  CGFloat x = self.view.frame.size.width / 2 - width/2;
  CGFloat y = self.view.frame.size.height - width - 20;
  
  self.locationButton = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, width)];
  self.locationButton.layer.cornerRadius = self.locationButton.frame.size.height / 2;
  self.locationButton.layer.backgroundColor = [[Colors flatGreen] CGColor];
  
  [self.locationButton addShadowWithOpacity:0.6 radius:3 offsetX:0 offsetY:3];
  
  UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationButton"]];
  [self.locationButton addSubview:image];
  image.frame = CGRectMake(width / 4, width / 4, width / 2, width / 2);
  
  [self.view addSubview:self.locationButton];
  
  UITapGestureRecognizer *tapper = [UITapGestureRecognizer new];
  [tapper addTarget:self action:@selector(didTapLocationButton:)];
  [self.locationButton addGestureRecognizer:tapper];
  
}

#pragma mark UI Gesture Recognizer Methods

- (void) receivedTapGestureOnMapView:(UITapGestureRecognizer *)sender{
  
  [self unpopCurrentComment];
  [self returnDragCircleToHomeBase];
  //[self hideAllMiniPopups];
  
}

- (void) receivedDragGestureOnDragCircle:(UIPanGestureRecognizer *)sender{
  CGPoint point = [sender locationInView:self.view];
  
  if (sender.state == UIGestureRecognizerStateChanged) {
    self.draggableCircle.center = point;
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    PostViewController *postVC = [PostViewController new];
    postVC.location = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    postVC.delegate = self;
    postVC.colorUI = [Colors flatPurple];
    self.currentPopup = postVC;
    CGFloat height = 430;
    if (self.kLargePopupHeight < height) {
      height = self.kLargePopupHeight;
    }
    [self spawnLargePopupAtPoint:point withHeight:height];
  }
  
}

- (void) setupGestureRecognizers {
  
  UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
  [tapRecognizer addTarget:self action:@selector(receivedTapGestureOnMapView:)];
  [self.mapView addGestureRecognizer:tapRecognizer];

}

#pragma mark <MKMapViewDelegate>

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  
  if ([view isKindOfClass:[ClusterAnnotationView class]]){
    
    CLLocationCoordinate2D coordinates = [mapView convertPoint:view.center toCoordinateFromView:self.mapView];
    MKCoordinateSpan span = mapView.region.span;
    span.latitudeDelta *= 0.5;
    span.longitudeDelta *= 0.5;
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinates, span);
    
    [UIView animateWithDuration:0.2 animations:^{
      [mapView setRegion:region animated:YES];
    }];
    
  } else if ([view isKindOfClass:[DotAnnotationView class]]){
    
    [mapView deselectAnnotation:view.annotation animated:false];
    BrowseViewController *dotVC = [BrowseViewController new];
    
    DotAnnotation *annotation = view.annotation;
    dotVC.color = [Colors getColorFromString:annotation.dot.color];
    dotVC.dot = annotation.dot;
    self.clickedDot = annotation.dot;
    
    self.currentPopup = dotVC;
    CGPoint point = [mapView convertCoordinate:view.annotation.coordinate toPointToView:self.view];
    dotVC.touchPoint = point;
    [self spawnLargePopupAtPoint:point withHeight:self.kLargePopupHeight];
    
  } else {
    
    [self.mapView setRegion:MKCoordinateRegionMake(self.locationManager.location.coordinate, MKCoordinateSpanMake(2.0, 3.0)) animated:true];
  }
  
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  } else if ([annotation isKindOfClass:[FBAnnotationCluster class]]) {
    
    ClusterAnnotationView *view = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Cluster"];
    
    if (view == nil) {
      view = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Cluster"];
    }
    
    FBAnnotationCluster * anno = annotation;
    
    CGPoint center = [mapView convertCoordinate:annotation.coordinate toPointToView:self.view];
    CGFloat width = 35.0f;
    view.frame = CGRectMake(center.x-(width/2.0f), center.y-(width/2.0f), width, width);
    view.backgroundColor = [UIColor clearColor];
    
    [view addShadowWithOpacity:0.6 radius:3 offsetX:0 offsetY:2];
    [view addLabelWithNumber:anno.annotations.count];
    //[view addPoppingAnimation];
    
    return view;

  } else {
    
    DotAnnotationView *view = (DotAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Dot"];
    if (view == nil) {
      view = [[DotAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Dot"];
    }
    
    DotAnnotation *anno = annotation;
    anno.dot = [self.dots objectForKey:anno.title];
    view.color = [Colors getColorFromString:anno.dot.color];
    NSTimeInterval timeSincePost = [anno.dot.timestamp timeIntervalSinceNow];
    
    double ratio = -timeSincePost / (60.0f * 60.0f * 48.0f);
    CGPoint center = [mapView convertCoordinate:anno.coordinate toPointToView:self.view];
    CGFloat width = 35.0f - (ratio * 20.0f);
    view.frame = CGRectMake(center.x-(width/2.0f), center.y-(width/2.0f), width, width);
    view.backgroundColor = [UIColor clearColor];
    
    [view addShadowWithOpacity:0.6 radius:3 offsetX:0 offsetY:2];
    [view addPoppingAnimation];
    
    return view;
  }
 
}
  

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
  
  if (!self.mapFullyLoaded) {
    [self requestDots];
  }
  self.mapFullyLoaded = true;
  
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

  if (self.mapFullyLoaded) {
    [self requestDots];
  }
  
}

#pragma mark Helper Methods

- (void) spawnMiniPopups {
  
  //  for (DotAnnotation *annotation in mapView.annotations) {
  //
  //    BrowseViewController * popup = [BrowseViewController new];
  //    popup.dot = annotation.dot;
  //    CGPoint point = [self.mapView convertCoordinate:annotation.coordinate toPointToView:self.view];
  //
  //    if (![self.popups valueForKey:annotation.title]){
  //      [self spawnPopup:popup atPoint:point withHeight:100];
  //      [self.popups setObject:popup forKey:annotation.title];
  //    }
  //  }
  
}

-(void) unpopCurrentComment {
  
  [UIView animateWithDuration:0.2
                        delay:0.0
       usingSpringWithDamping:0.0
        initialSpringVelocity:0.0
                      options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        self.currentPopup.view.alpha = 0;
                        } completion:^(BOOL finished) {
                          [self.currentPopup.view removeFromSuperview];
                          [self.currentPopup removeFromParentViewController];
                        }];
 }

-(void) returnDragCircleToHomeBase {
  
  [UIView animateWithDuration:0.2
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        self.draggableCircle.center = self.originalCircleCenter;
                        self.draggableCircle.backgroundColor = [UIColor whiteColor];
                      } completion:^(BOOL finished) {
                        
                      }];
  
}

-(void) spawnLargePopupAtPoint:(CGPoint)point withHeight: (CGFloat) height {
  
  [self spawnPopup:self.currentPopup atPoint:point withHeight:height];
  
}

-(void) spawnPopup: (UIViewController<PopupViewController> *) viewController atPoint:(CGPoint)point withHeight: (CGFloat) height{

  CGRect popupFrame = CGRectMake(self.view.frame.origin.x + 20, point.y - height, self.view.frame.size.width - 40, height);
  viewController.view.frame = popupFrame;
  
  [self addChildViewController:viewController];
  [self.view addSubview:viewController.view];
  [viewController didMoveToParentViewController:self];
  
  viewController.borderView.touchPoint = [self.view convertPoint:point toView:viewController.view];
  viewController.borderView.popFromSide = false;
  
  viewController.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];

  viewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
  viewController.view.alpha = 0;
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.6
        initialSpringVelocity:0.2
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     viewController.view.alpha = 1;
                     viewController.view.transform = CGAffineTransformMakeScale(1, 1);
                   } completion:^(BOOL finished) {
                     [self scrollToClearCurrentPopup];
                   }];
  
}

-(void) scrollToClearCurrentPopup {
  
  CGFloat offset = 40 - self.currentPopup.view.frame.origin.y;
  CGRect newRect = self.currentPopup.view.frame;
  newRect.origin.y += offset;
  CGPoint center = [self.mapView convertCoordinate:self.mapView.centerCoordinate toPointToView:self.view];
  center.y -= offset;
  MKCoordinateRegion region = [self.mapView region];
  CLLocationCoordinate2D newCoord = [self.mapView convertPoint:center toCoordinateFromView:self.view];
  region.center = newCoord;
  
  if (offset > 0) {
    [UIView animateWithDuration:0.4 animations:^{
      self.currentPopup.view.frame = newRect;
      [self.mapView setRegion:region animated:true];
      if (self.draggableCircle.center.x != self.originalCircleCenter.x || self.draggableCircle.center.y != self.originalCircleCenter.y ) {
        CGRect rect = self.draggableCircle.frame;
        rect.origin.y +=offset;
        self.draggableCircle.frame = rect;
      }
    }];
  }
  
  
}

//
//-(void) hideAllMiniPopups {
//  
//  for (UIViewController *popup in self.popups) {
//    popup.view.hidden = true;
//  }
//}

- (void) changeDotColor:(UIColor *)color {
  
  self.draggableCircle.backgroundColor = color;
  
}

- (void) requestDots {

  [self.networkController fetchDotsWithRegion:self.mapView.region completionHandler:^(NSError *error, NSArray *dots) {
    
    if (dots) {
      [self addDotsToDictionaryFromArray:dots];
    } else {
      [self showAlertWithError:error];
    }
    
  }];
  
}

- (void) addDotsToDictionaryFromArray:(NSArray*) dots {
  
  for (Dot *dot in dots) {
    if (![self.dots objectForKey:dot.identifier]) {
      [self.dots setObject:dot forKey:dot.identifier];
      [self addNewAnnotationForDot:dot];
    }
  }
  
  double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
  NSArray *annotations = [self.clusteringManager clusteredAnnotationsWithinMapRect:self.mapView.visibleMapRect withZoomScale:scale];
  
  [self.clusteringManager displayAnnotations:annotations onMapView:self.mapView];
  
}

- (void) addNewAnnotationForDot:(Dot*) dot {
  
  DotAnnotation *anno = [DotAnnotation new];
  anno.coordinate = dot.location;
  anno.title = dot.identifier;
  anno.dot = dot;
  [self.clusteringManager addAnnotations:@[anno]];
  
}

- (void) checkLocationAuthorizationStatus {
  
  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusAuthorizedAlways:
      [self.locationManager startUpdatingLocation];
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      [self.locationManager startUpdatingLocation];
      break;
    case kCLAuthorizationStatusNotDetermined:
      [self.locationManager requestWhenInUseAuthorization];
      break;
    default:
      break;
  }
  
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  
  if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self.locationManager startUpdatingLocation];
  }
  
}

-(void)didTapLocationButton:(UITapGestureRecognizer *)sender {
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self unpopCurrentComment];
    [self moveToCurrentLocationAnimated:true];
  }
  
}

-(void)moveToCurrentLocationAnimated: (BOOL)animated {
  
  double width = 1500000;
  CLLocationCoordinate2D coordinates = self.locationManager.location.coordinate;
  MKMapPoint point = MKMapPointForCoordinate(coordinates);
  MKMapRect rect = MKMapRectMake(point.x - width / 2.7, point.y - width/2, width, width);
  [self.mapView setVisibleMapRect:rect animated:animated];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  
  if (!self.didGetLocation) {
    [self moveToCurrentLocationAnimated:false];
    self.didGetLocation = true;
  }
  
}

- (void) showAlertWithError: (NSError *) error {
  
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    if (error == nil) {
      alert.message = @"An error occurred. Please try again later.";
    }
    [alert show];
  }];

}

- (void) didTapOnDragCircle: (UITapGestureRecognizer *) sender {
  
  if (!self.fingerIsMoving) {
    self.fingerIsMoving = true;
    UIImageView *finger = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finger"]];
    finger.frame = CGRectMake(self.draggableCircle.center.x - 50, self.draggableCircle.center.y - 10, 52, 68);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(1);
    finger.transform = rotation;
    finger.alpha = 0;
    
    [self.view addSubview:finger];
    
    [UIView animateKeyframesWithDuration:1.2 delay:0.0 options:0 animations:^{
      [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
        finger.alpha = 1;
      }];
      [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.6 animations:^{
        finger.transform = CGAffineTransformMakeTranslation(-52, -142);
        finger.transform = CGAffineTransformRotate(finger.transform, .3);
        self.draggableCircle.transform = CGAffineTransformMakeTranslation(-75, -150);
      }];
      [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
        finger.alpha = 0;
        self.draggableCircle.alpha = 0;
      }];
      
    } completion:^(BOOL finished) {
      self.draggableCircle.transform = CGAffineTransformIdentity;
      [UIView animateWithDuration:0.3 animations:^{
        self.draggableCircle.alpha = 1;
      } completion:^(BOOL finished) {
        self.fingerIsMoving = false;
      }];
      
    }];
    
  }
  
}

- (CGFloat)cellSizeFactorForCoordinator:(FBClusteringManager *)coordinator {
  
  CLLocationDegrees delta = self.mapView.region.span.longitudeDelta;
  
  if (delta > 3) {
    return 2.5;
  } else if (delta > 1) {
    return 0.5;
  } else {
    return 0.1;
  }
  
  
}

@end
