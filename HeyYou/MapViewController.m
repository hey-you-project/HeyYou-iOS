//
//  ViewController.m
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@property CGFloat kHorizontalCurveOffset;
@property CGFloat kVerticalCurveOffset;
@property CGFloat kPopupHeight;
@property NSArray *dots;

@end

@implementation MapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupSideMenu];
  [self setupMapView];
  [self addCircleView];
  [self addHamburgerMenuCircle];
  [self setupGestureRecognizers];
  
  self.mapView.delegate = self;

  self.kHorizontalCurveOffset = 2;
  self.kVerticalCurveOffset = 15;
  self.kPopupHeight = 540;
  
  NetworkController *networkController = [NetworkController sharedController];
  
  [networkController fetchDotsWithRegion:self.mapView.region completionHandler:^(NSString * string, NSArray * array) {
    self.dots = array;
    [self populateDotsOnMap];
    NSLog(@"%@", self.dots.description);
  }];
  
  
  /* Post test
  CLLocationCoordinate2D location = CLLocationCoordinate2DMake(47.606209, -122.332071);
  Dot *testDot = [[Dot alloc] initWithLocation:location color:@"blue" title:@"Be a man!" body:@"bacon and eggs"];
  [[NetworkController sharedController] postDot:testDot completionHandler:^(NSString *error, bool success) {
    NSLog(success ? @"Success!" : @"Fail!");
  }]; */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMapView {
  self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
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
  self.sideMenuVC.view.backgroundColor = [UIColor blackColor];
}

- (void) addCircleView {
  
  self.dragCircleWrapper = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 100, 60, 60)];
  self.dragCircleWrapper.layer.cornerRadius = self.dragCircleWrapper.frame.size.height / 2;
  self.dragCircleWrapper.layer.backgroundColor = [[UIColor whiteColor] CGColor];
  self.dragCircleWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.dragCircleWrapper.layer.shadowOpacity = 0.6;
  self.dragCircleWrapper.layer.shadowRadius = 3.0;
  self.dragCircleWrapper.layer.shadowOffset = CGSizeMake(0, 3);
  
  CGRect miniCircleRect = CGRectMake(self.dragCircleWrapper.frame.origin.x + 17.5, self.dragCircleWrapper.frame.origin.y + 15, 25, 25);

  self.draggableCircle = [[UIView alloc] initWithFrame:miniCircleRect];
  self.draggableCircle.layer.cornerRadius = self.draggableCircle.frame.size.height / 2;
  self.draggableCircle.backgroundColor = [UIColor orangeColor];
  self.originalCircleCenter = self.draggableCircle.center;
  
  self.draggableCircle.layer.shadowColor = [[UIColor whiteColor] CGColor];
  self.draggableCircle.layer.shadowOpacity = 0.8;
  self.draggableCircle.layer.shadowRadius = 1.0;
  self.draggableCircle.layer.shadowOffset = CGSizeMake(0, 2);
  
  [self.view addSubview:self.dragCircleWrapper];
  [self.view addSubview:self.draggableCircle];

  UIPanGestureRecognizer *dragger = [UIPanGestureRecognizer new];
  [dragger addTarget:self action:@selector(receivedDragGestureOnDragCircle:)];
  [self.draggableCircle addGestureRecognizer:dragger];

}

-(void) addHamburgerMenuCircle{
  
  CGRect hamburgerRect = CGRectMake(self.view.frame.origin.x + 40, self.view.frame.size.height - 100, 60, 60);
  
  self.hamburgerWrapper = [[UIView alloc] initWithFrame:hamburgerRect];
  self.hamburgerWrapper.layer.cornerRadius = self.hamburgerWrapper.frame.size.height / 2;
  self.hamburgerWrapper.backgroundColor = [UIColor whiteColor];
  self.hamburgerWrapper.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.hamburgerWrapper.layer.shadowOpacity = 0.6;
  self.hamburgerWrapper.layer.shadowRadius = 3.0;
  self.hamburgerWrapper.layer.shadowOffset = CGSizeMake(0, 3);
  [self.view addSubview:self.hamburgerWrapper];
  
  CGRect labelRect = CGRectMake(self.hamburgerWrapper.bounds.origin.x + 19, self.hamburgerWrapper.bounds.origin.y + 17.5, 25, 25);
  
  self.hamburgerLabel = [[UILabel alloc] initWithFrame:labelRect];
  self.hamburgerLabel.text = @"\ue116";
  self.hamburgerLabel.font = [UIFont fontWithName:@"typicons" size:30];
  self.hamburgerLabel.textColor = [UIColor orangeColor];
  
  self.hamburgerLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
  self.hamburgerLabel.layer.shadowOpacity = 0.8;
  self.hamburgerLabel.layer.shadowRadius = 1.0;
  self.hamburgerLabel.layer.shadowOffset = CGSizeMake(0, 2);
  
  [self.hamburgerWrapper addSubview:self.hamburgerLabel];
  
  UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
  [tap addTarget:self action:@selector(receivedTapGestureOnHamburgerButton:)];
  [self.hamburgerWrapper addGestureRecognizer:tap];
  
}

-(void) setupGestureRecognizers {
  
  UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
  [tapRecognizer addTarget:self action:@selector(receivedTapGestureOnMapView:)];
  [self.mapView addGestureRecognizer:tapRecognizer];
  
  UIScreenEdgePanGestureRecognizer *edgePanRecognizer = [UIScreenEdgePanGestureRecognizer new];
  [edgePanRecognizer addTarget:self action:@selector(receivedPanFromLeftEdge:)];
  edgePanRecognizer.edges = UIRectEdgeLeft;
  [self.view addGestureRecognizer:edgePanRecognizer];
}

-(void)receivedTapGestureOnMapView:(UITapGestureRecognizer *)sender{
  
  [self unpopCurrentComment];
  [self returnDragCircleToHomeBase];
  
}

-(void) receivedDragGestureOnDragCircle:(UIPanGestureRecognizer *)sender{
  
  if (sender.state == UIGestureRecognizerStateChanged) {
    self.draggableCircle.center = [sender locationInView:self.view];
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    self.currentPopup = [PostViewController new];
    [self spawnPopupAtPoint:[sender locationInView:self.view]];
  }
  
}

-(void) receivedTapGestureOnHamburgerButton:(UITapGestureRecognizer *)sender{
  NSLog(@"REcongiexed Touch!");
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    [self toggleSideMenu];
  }
  
}

-(void) receivedPanFromLeftEdge:(UIScreenEdgePanGestureRecognizer *)sender {
  
//  if (sender.state == UIGestureRecognizerStateChanged) {
//    CGPoint offsetX = [sender locationInView:self.view];
//    self.mapView.frame.origin.x = offsetX.x;
//    
//  }
  
}

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
                      } completion:^(BOOL finished) {
                        
                        
                      }];
  
}

-(void) spawnPopupAtPoint:(CGPoint)point {

  [self addChildViewController:self.currentPopup];
  [self.view addSubview:self.currentPopup.view];
  self.currentPopup.view.alpha = 0;
  
  CGRect popupFrame = CGRectMake(self.view.frame.origin.x + 20, point.y - (self.kPopupHeight - 30), self.view.frame.size.width - 40, self.kPopupHeight);
  
  self.currentPopup.view.frame = popupFrame;
  
  CGRect vcBounds = self.currentPopup.view.bounds;
  
  CGRect newRect = CGRectMake(vcBounds.origin.x, vcBounds.origin.y, vcBounds.size.width, vcBounds.size.height - 50);
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
  struct CGPath *combinedPath = CGPathCreateMutableCopy(path.CGPath);
  CGMutablePathRef triangle = CGPathCreateMutable();
  
  CGPoint newTouchPoint = [self.currentPopup.view convertPoint:point fromView:self.view];
  
  CGPathMoveToPoint   (triangle, nil, newTouchPoint.x,      newTouchPoint.y);
  CGPathAddArcToPoint (triangle, nil, newTouchPoint.x - 2,  newTouchPoint.y - 15, newTouchPoint.x - 10, newTouchPoint.y - 20, 20);
  CGPathAddLineToPoint(triangle, nil, newTouchPoint.x - 10, newTouchPoint.y - 20);
  CGPathAddLineToPoint(triangle, nil, newTouchPoint.x + 10, newTouchPoint.y - 20);
  CGPathAddArcToPoint (triangle, nil, newTouchPoint.x + 3,  newTouchPoint.y - 15, newTouchPoint.x, newTouchPoint.y, 20);
  CGPathAddLineToPoint(triangle, nil, newTouchPoint.x,      newTouchPoint.y);
  CGPathCloseSubpath  (triangle);
  
  CGPathAddPath(combinedPath, nil, triangle);
  CAShapeLayer *shapeLayer = [CAShapeLayer new];
  shapeLayer.path = combinedPath;
  
  self.currentPopup.view.layer.mask = shapeLayer;
  self.currentPopup.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
  
  [UIView animateWithDuration:0.2
                        delay:0.0
       usingSpringWithDamping:0.6
        initialSpringVelocity:0.2
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     self.currentPopup.view.alpha = 1;
                     self.currentPopup.view.transform = CGAffineTransformMakeScale(1, 1);
                   } completion:^(BOOL finished) {
                     
                   }];
  
}
-(void)toggleSideMenu {
  CGRect newMapViewFrame = self.mapView.frame;
  CGRect newDragWrapperFrame = self.dragCircleWrapper.frame;
  CGRect newDraggableFrame = self.draggableCircle.frame;
  CGRect newHamburgerFrame = self.hamburgerWrapper.frame;
  
  if (self.mapView.frame.origin.x == 0){
    [self returnDragCircleToHomeBase];
    newMapViewFrame.origin.x += 200;
    newDragWrapperFrame.origin.x += 200;
    newDraggableFrame.origin.x += 200;
    newHamburgerFrame.origin.x += 20;
  } else {
    newMapViewFrame.origin.x -= 200;
    newDragWrapperFrame.origin.x -= 200;
    newDraggableFrame.origin.x -= 200;
    newHamburgerFrame.origin.x -= 20;
  }
  [self unpopCurrentComment];
  NSLog(@"Toggle Called!");
  
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     NSLog(@"Checking for animations!");
                   
                     NSLog(@"Animations Called");
                     self.mapView.frame = newMapViewFrame;
                     self.dragCircleWrapper.frame = newDragWrapperFrame;
                     self.draggableCircle.frame = newDraggableFrame;
                     self.hamburgerWrapper.frame = newHamburgerFrame;
                   } completion:^(BOOL finished) {
                    
                   }];
}

-(void)populateDotsOnMap {
  
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    for (Dot * dot in self.dots) {
      NSLog(@"Adding overlay!");
      NSLog(@"Adding Overlay with Lat:%f and Long:%f", dot.location.latitude, dot.location.longitude);
      //[self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:dot.location radius:100000.0]];
      MKPointAnnotation *anno = [MKPointAnnotation new];
      anno.coordinate = dot.location;
      anno.
      [self.mapView addAnnotation:anno];
    }
  }];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  
  MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
  renderer.fillColor = [UIColor orangeColor];
  return renderer;
  
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  
  BrowseViewController *dotVC = [BrowseViewController new];
  dotVC
  
  
  self.currentPopup = [BrowseViewController new];
  
  
}


//  
//  if self.mapView.frame.origin.x == 0{
//    self.hamburgerLabel.text = "\u{e116}"
//    self.hamburgerLabel.transform = CGAffineTransformMakeScale(1, 1)
//    self.hamburgerLabel.center.x -= 6
//  } else {
//    self.hamburgerLabel.text = "\u{e122}"
//    self.hamburgerLabel.transform = CGAffineTransformMakeScale(1.4, 1.4)
//    self.hamburgerLabel.center.x += 6
//  }
//  
//}


@end
