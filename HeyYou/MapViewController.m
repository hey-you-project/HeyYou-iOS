//
//  ViewController.m
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "MapViewController.h"
#import "DotAnnotationView.h"
#import <QuartzCore/QuartzCore.h>
#import "PopupView.h"
#import "Colors.h"

@interface MapViewController ()

@property (nonatomic, strong) NSMutableDictionary *dots;
@property (nonatomic, strong) NSMutableArray *poppedDots;
@property (nonatomic, strong) Dot *clickedDot;
@property (nonatomic, strong) NSMutableDictionary *popups;
@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property BOOL mapFullyLoaded;

#pragma mark Color Palette

@property (nonatomic, strong) Colors *colors;

#pragma mark Constants

@property CGFloat kLargePopupHeight;

@end

@implementation MapViewController

#pragma mark Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  self.popups = [NSMutableDictionary new];
  self.mapFullyLoaded = false;
  self.dots = [NSMutableDictionary new];
  self.poppedDots = [NSMutableArray new];
  
  self.colors = [Colors new];
  
  [self setupMapView];
  [self addCircleView];
  
  [self setupGestureRecognizers];
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  [self checkLocationAuthorizationStatus];
  
  self.networkController = [NetworkController sharedController];
  
  self.mapView.delegate = self;

  self.kLargePopupHeight = 480;
  
  UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
  statusBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
  [self.mapView addSubview:statusBar];
  
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.mapView.showsUserLocation = true;
 
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Setup Subview Methods

- (void)setupMapView {
  self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width + 100, self.view.frame.size.height)];
  [self.view addSubview:self.mapView];
  self.mapView.clipsToBounds = true;
  self.mapView.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.mapView.layer.shadowOpacity = 0.6;
  self.mapView.layer.shadowRadius = 3.0;
  self.mapView.layer.shadowOffset = CGSizeMake(-5, 0);
}

- (void) setupSideMenu {
  self.sideMenuVC = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:[NSBundle mainBundle]];
  [self addChildViewController:self.sideMenuVC];
  [self.view addSubview:self.sideMenuVC.view];
  self.sideMenuVC.view.frame = CGRectMake(0, 0, 200, self.view.frame.size.height);
  //self.sideMenuVC.view.backgroundColor = self.customTeal;
}

- (void) addCircleView {
  
  self.dragCircleWrapper = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 100, 60, 60)];
  self.dragCircleWrapper.layer.cornerRadius = self.dragCircleWrapper.frame.size.height / 2;
  self.dragCircleWrapper.layer.backgroundColor = [[UIColor whiteColor] CGColor];
  self.dragCircleWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.dragCircleWrapper.layer.shadowOpacity = 0.6;
  self.dragCircleWrapper.layer.shadowRadius = 3.0;
  self.dragCircleWrapper.layer.shadowOffset = CGSizeMake(0, 3);
  
  CGRect miniCircleRect = CGRectMake(self.dragCircleWrapper.frame.origin.x + 17.5, self.dragCircleWrapper.frame.origin.y + 17.5, 25, 25);

  self.draggableCircle = [[UIView alloc] initWithFrame:miniCircleRect];
  self.draggableCircle.layer.cornerRadius = self.draggableCircle.frame.size.height / 2;
  self.draggableCircle.backgroundColor = self.colors.flatPurple;
  self.originalCircleCenter = self.draggableCircle.center;
  
  self.draggableCircle.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.draggableCircle.layer.shadowOpacity = 0.8;
  self.draggableCircle.layer.shadowRadius = 1.0;
  self.draggableCircle.layer.shadowOffset = CGSizeMake(0, 2);
  
  [self.view addSubview:self.dragCircleWrapper];
  [self.view addSubview:self.draggableCircle];

  UIPanGestureRecognizer *dragger = [UIPanGestureRecognizer new];
  [dragger addTarget:self action:@selector(receivedDragGestureOnDragCircle:)];
  [self.draggableCircle addGestureRecognizer:dragger];

}





#pragma mark Gesture Recognizer Methods

-(void)receivedTapGestureOnMapView:(UITapGestureRecognizer *)sender{
  
  [self unpopCurrentComment];
  [self returnDragCircleToHomeBase];
  //[self hideAllMiniPopups];
  
}

-(void) receivedDragGestureOnDragCircle:(UIPanGestureRecognizer *)sender{
  CGPoint point = [sender locationInView:self.view];
  
  if (sender.state == UIGestureRecognizerStateChanged) {
    self.draggableCircle.center = point;
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    PostViewController *postVC = [PostViewController new];
    postVC.location = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    postVC.delegate = self;
    postVC.colorUI = self.colors.flatPurple;
    self.currentPopup = postVC;
    [self spawnLargePopupAtPoint:point withHeight:self.kLargePopupHeight];
  }
  
}

- (void) setupGestureRecognizers {
  
  UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
  [tapRecognizer addTarget:self action:@selector(receivedTapGestureOnMapView:)];
  [self.mapView addGestureRecognizer:tapRecognizer];

}

#pragma mark Helper Methods

-(void) unpopCurrentComment {
  
  [UIView animateWithDuration:0.2
                        delay:0.2
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
                        self.draggableCircle.backgroundColor = self.colors.flatPurple;
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

//-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//  
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
//  
//}
//
//-(void) hideAllMiniPopups {
//  
//  for (UIViewController *popup in self.popups) {
//    popup.view.hidden = true;
//  }
//}



-(void)populateDotsOnMap {
  
    for (NSString* dotID in self.dots) {
      Dot *dot = [self.dots objectForKey:dotID];
      if (![self.poppedDots containsObject:dot]) {
        [self.poppedDots addObject:dot];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
          [self addNewAnnotationForDot:dot];
        }];
      }
    }
}

-(void)addNewAnnotationForDot:(Dot*) dot {
  NSLog(@"Adding new annotation!");
  DotAnnotation *anno = [DotAnnotation new];
  anno.coordinate = dot.location;
  anno.title = dot.identifier;
  anno.dot = dot;
  [self.mapView addAnnotation:anno];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  if ([view isKindOfClass:[DotAnnotationView class]]){
    [mapView deselectAnnotation:view.annotation animated:false];
    BrowseViewController *dotVC = [BrowseViewController new];
    
    DotAnnotation *annotation = view.annotation;
    dotVC.color = [self.colors getColorFromString:annotation.dot.color];
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

-(void) changeDotColor:(NSString *)color {
  
  UIColor *colorUI = [self.colors getColorFromString:color];
  self.draggableCircle.backgroundColor = colorUI;
  PostViewController *vc = (PostViewController *)self.currentPopup;
  vc.view.layer.borderColor = [colorUI CGColor];
  vc.titleLabel.textColor = colorUI;
  vc.titleTextField.backgroundColor = [colorUI colorWithAlphaComponent:0.3];
  vc.bodyTextField.backgroundColor = [colorUI colorWithAlphaComponent:0.3];
  
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  } else {
    
    DotAnnotationView *view = (DotAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Dot"];
    if (view == nil) {
      view = [[DotAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Dot"];
    }
    DotAnnotation *anno = annotation;
    anno.dot = [self.dots objectForKey:anno.title];
    view.color = [self.colors getColorFromString:anno.dot.color];
    NSLog(@"%@", view.color);
    NSTimeInterval timeSincePost = [anno.dot.timestamp timeIntervalSinceNow];
    
    double ratio = -timeSincePost / (60.0f * 60.0f * 48.0f);
    CGPoint center = [mapView convertCoordinate:anno.coordinate toPointToView:self.view];
    CGFloat width = 35.0f - (ratio * 25.0f);
    view.frame = CGRectMake(center.x-(width/2.0f), center.y-(width/2.0f), width, width);
    view.backgroundColor = [UIColor clearColor];
    
  //  view.layer.shadowColor = [[UIColor blackColor] CGColor];
  //  view.layer.shadowOpacity = 0.6;
  //  view.layer.shadowRadius = 3.0;
  //  view.layer.shadowOffset = CGSizeMake(0, 2);
    
    view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    int random = arc4random_uniform(400);
    double random2 = random / 1000.0f;
    
    NSTimeInterval delay = (NSTimeInterval)random2;
    view.alpha = 0;
    
    [UIView animateWithDuration:0.5 delay:delay usingSpringWithDamping:0.3 initialSpringVelocity:0.9 options:UIViewAnimationOptionAllowUserInteraction animations:^{
      view.transform = CGAffineTransformIdentity;
      view.alpha = 1;
    } completion:^(BOOL finished) {
      
    }];
    [view setNeedsDisplay];
  return view;
  }
  
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
  if (!self.mapFullyLoaded) {
    [self requestDots];
    self.mapFullyLoaded= true;
  }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  if (self.mapFullyLoaded) {
    [self requestDots];
  }
}

-(void) requestDots {
  
  [self.networkController fetchDotsWithRegion:self.mapView.region completionHandler:^(NSError *error, NSArray *dots) {
    if (dots != nil) {
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addDotsToDictionaryFromArray:dots];
      }];
      
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      if (error == nil) {
        alert.message = @"An error occurred. Please try again later.";
      }
      [alert show];
    }
  }];
  
}

-(void) addDotsToDictionaryFromArray:(NSArray*) dotsArray {
  for (Dot *dot in dotsArray) {
    if (![self.dots objectForKey:dot.identifier]) {
      NSLog(@"Found new dot!");
      [self.dots setObject:dot forKey:dot.identifier];
    } else {
      NSLog(@"Found old dot!");
    }
  }
  [self populateDotsOnMap];
}

-(void) checkLocationAuthorizationStatus {
  NSLog(@"Check called.");
  
  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusAuthorizedAlways:
      [self.locationManager startUpdatingLocation];
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      [self.locationManager startUpdatingLocation];
      break;
    case kCLAuthorizationStatusNotDetermined:
      NSLog(@"Found not determined");
      [self.locationManager requestAlwaysAuthorization];
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




@end
