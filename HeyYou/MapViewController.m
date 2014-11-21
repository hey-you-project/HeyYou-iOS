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

@interface MapViewController ()

@property CGFloat kHorizontalCurveOffset;
@property CGFloat kVerticalCurveOffset;
@property CGFloat kLargePopupHeight;
@property (nonatomic, strong) NSArray *dots;
@property (nonatomic, strong) NSMutableArray *poppedDotIDs;
@property (nonatomic, strong) Dot *clickedDot;
@property (nonatomic, strong) NSMutableDictionary *popups;
@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

//// MARK: Color Palette
@property (nonatomic, strong) UIColor *customDarkOrange;
@property (nonatomic, strong) UIColor *customLightOrange;
@property (nonatomic, strong) UIColor *customBlue;
@property (nonatomic, strong) UIColor *customTeal;
@property (nonatomic, strong) UIColor *customBeige;
@property (nonatomic, strong) UIColor *flatTurquoise;
@property (nonatomic, strong) UIColor *flatGreen;
@property (nonatomic, strong) UIColor *flatBlue;
@property (nonatomic, strong) UIColor *flatPurple;
@property (nonatomic, strong) UIColor *flatYellow;
@property (nonatomic, strong) UIColor *flatOrange;
@property (nonatomic, strong) UIColor *flatRed;
@property (nonatomic, strong) UIColor *flatGray;

@end

@implementation MapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.popups = [NSMutableDictionary new];
  
  self.flatGreen = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha: 1];
    self.flatPurple     = [UIColor colorWithRed: 155 / 255.0 green: 89  / 255.0 blue: 182 / 255.0 alpha: 1];
  
  [self setupSideMenu];
  [self setupMapView];
  [self addCircleView];
  [self addHamburgerMenuCircle];
  [self setupGestureRecognizers];
  
  self.networkController = [NetworkController sharedController];
  self.dateFormatter = [NSDateFormatter new];
  [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
  self.poppedDotIDs = [NSMutableArray new];
  

  
  self.mapView.delegate = self;

  self.kHorizontalCurveOffset = 2;
  self.kVerticalCurveOffset = 15;
  self.kLargePopupHeight = 480;
  
  self.flatTurquoise  = [UIColor colorWithRed: 26  / 255.0 green: 188 / 255.0 blue: 156 / 255.0 alpha: 1];
  self.flatBlue       = [UIColor colorWithRed: 52  / 255.0 green: 152 / 255.0 blue: 219 / 255.0 alpha: 1];

  self.flatYellow     = [UIColor colorWithRed: 241 / 255.0 green: 196 / 255.0 blue: 15  / 255.0 alpha: 1];
  self.flatOrange     = [UIColor colorWithRed: 212 / 255.0 green: 83  / 255.0 blue: 36  / 255.0 alpha: 1];
  self.flatRed        = [UIColor colorWithRed: 212 / 255.0 green: 37  / 255.0 blue: 37  / 255.0 alpha: 1];
  self.flatGray       = [UIColor colorWithRed: 52  / 255.0 green: 73  / 255.0 blue: 94  / 255.0 alpha: 1];
  
  UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
  UIVisualEffect *blurEffect;
  blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
  UIVisualEffectView *visualEffectView;
  visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  visualEffectView.frame = statusBar.frame;
  [self.mapView addSubview:visualEffectView];
  statusBar.backgroundColor = [self.flatGreen colorWithAlphaComponent:0.8];
  [self.mapView addSubview:statusBar];
  
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
 
}
  
//  [networkController createUserWithUsername:@"ronswanson" password:@"baconandeggs" birthday:birthday email:@"anonymous@fakeemail.com" completionHandler:^(NSString *error, bool success) {
//      if (success) {
//        NSLog(@"Token is: %@", networkController.token);
//      } else {
//        NSLog(@"Bullshit");
//      }
//  }];


-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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
  self.draggableCircle.backgroundColor = self.flatPurple;
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
  self.hamburgerLabel.textColor = self.flatPurple;
  
  self.hamburgerLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
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
    postVC.colorUI = self.flatPurple;
    self.currentPopup = postVC;
    [self spawnLargePopupAtPoint:point withHeight:self.kLargePopupHeight];
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
                        self.draggableCircle.backgroundColor = self.flatPurple;
                      } completion:^(BOOL finished) {
                        
                      }];
  
}

-(void) spawnLargePopupAtPoint:(CGPoint)point withHeight: (CGFloat) height {
  
  [self spawnPopup:self.currentPopup atPoint:point withHeight:height];
  
}

-(void) spawnPopup: (UIViewController *) viewController atPoint:(CGPoint)point withHeight: (CGFloat) height{

  [self addChildViewController:viewController];
  [self.view addSubview:viewController.view];
  viewController.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
  viewController.view.alpha = 0;
  
  CGRect popupFrame = CGRectMake(self.view.frame.origin.x + 20, point.y - (height - 30), self.view.frame.size.width - 40, height);
  
  viewController.view.frame = popupFrame;
  viewController.view.layer.cornerRadius = 10;
  
  CGRect vcBounds = viewController.view.bounds;
  
  CGRect newRect = CGRectMake(vcBounds.origin.x, vcBounds.origin.y, vcBounds.size.width, vcBounds.size.height - 50);
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
  struct CGPath *combinedPath = CGPathCreateMutableCopy(path.CGPath);
  CGMutablePathRef triangle = CGPathCreateMutable();
  
  CGPoint newTouchPoint = [viewController.view convertPoint:point fromView:self.view];
  
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
  
  CAShapeLayer *subLayer = [CAShapeLayer new];
  [viewController.view.layer addSublayer:subLayer];
  subLayer.path = combinedPath;
  subLayer.frame = viewController.view.layer.bounds;
  subLayer.strokeColor = [self getColorFromString:self.clickedDot.color].CGColor;
  subLayer.lineWidth = 5;
  subLayer.fillColor = nil;
  
  viewController.view.layer.mask = shapeLayer;
  viewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
  
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


-(void)toggleSideMenu {
  
  CGRect newMapViewFrame = self.mapView.frame;
  CGRect newDragWrapperFrame = self.dragCircleWrapper.frame;
  CGRect newDraggableFrame = self.draggableCircle.frame;
  CGRect newHamburgerFrame = self.hamburgerWrapper.frame;
  CGRect newHamLabelFrame = self.hamburgerLabel.frame;
  NSString *newString;
  CGAffineTransform transform;
  
  if (self.mapView.frame.origin.x == 0){
    [self returnDragCircleToHomeBase];
    self.sideMenuVC.blueEffectView.hidden = NO;
    newMapViewFrame.origin.x += 200;
    newDragWrapperFrame.origin.x += 200;
    newDraggableFrame.origin.x += 200;
    newHamburgerFrame.origin.x += 30;
    newHamLabelFrame.origin.x += 6;
    newString = @"\ue122";
    transform = CGAffineTransformMakeScale(1.4, 1.4);
  } else {
    newMapViewFrame.origin.x -= 200;
    newDragWrapperFrame.origin.x -= 200;
    newDraggableFrame.origin.x -= 200;
    newHamburgerFrame.origin.x -= 30;
    newHamLabelFrame.origin.x -= 6;
    newString = @"\ue116";
    transform = CGAffineTransformIdentity;
  }
  [self unpopCurrentComment];
  
  [UIView animateWithDuration:0.4
                        delay:0.0
       usingSpringWithDamping:0.7
        initialSpringVelocity:0.4
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     self.mapView.frame = newMapViewFrame;
                     self.dragCircleWrapper.frame = newDragWrapperFrame;
                     self.draggableCircle.frame = newDraggableFrame;
                     self.hamburgerWrapper.frame = newHamburgerFrame;
                     self.hamburgerLabel.frame = newHamLabelFrame;
                     self.hamburgerLabel.text = newString;
                     self.hamburgerLabel.transform = transform;
                   } completion:^(BOOL finished) {
                     if (self.mapView.frame.origin.x == 0){
                       self.sideMenuVC.blueEffectView.hidden = YES;
                     }
                   }];
}

-(void)populateDotsOnMap {
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    for (Dot * dot in self.dots) {
      if (![self.poppedDotIDs containsObject:dot.identifier]) {
        [self.poppedDotIDs addObject:dot.identifier];
        [self addNewAnnotationForDot:dot];
      }
    }
    
  }];
}

-(void)addNewAnnotationForDot:(Dot*) dot {
  DotAnnotation *anno = [DotAnnotation new];
  anno.coordinate = dot.location;
  anno.title = dot.identifier;
  anno.dot = dot;
  [self.mapView addAnnotation:anno];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  
  MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
  renderer.fillColor = [UIColor orangeColor];
  return renderer;
  
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  [mapView deselectAnnotation:view.annotation animated:false];
  BrowseViewController *dotVC = [BrowseViewController new];

  DotAnnotation *annotation = view.annotation;
  dotVC.color = [self getColorFromString:annotation.dot.color];
  dotVC.dot = annotation.dot;
  self.clickedDot = annotation.dot;
  dotVC.dateFormatter = self.dateFormatter;
  
  self.currentPopup = dotVC;
  CGPoint point = [mapView convertCoordinate:view.annotation.coordinate toPointToView:self.view];
  [self spawnLargePopupAtPoint:point withHeight:self.kLargePopupHeight];
  
  
}

-(void) changeDotColor:(NSString *)color {
  UIColor *colorUI = [self getColorFromString:color];
  self.draggableCircle.backgroundColor = colorUI;
  PostViewController *vc = (PostViewController *)self.currentPopup;
  vc.view.layer.borderColor = [colorUI CGColor];
  vc.titleLabel.textColor = colorUI;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  
  DotAnnotationView *view = (DotAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Dot"];
  if (view == nil) {
    NSLog(@"Creating new!");
    view = [[DotAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Dot"];
  }
  DotAnnotation *anno = view.annotation;
  view.color = [self getColorFromString:anno.dot.color];
  NSLog(@"%@", anno.dot.color);
  
  CGPoint center = [mapView convertCoordinate:anno.coordinate toPointToView:self.view];
  view.frame = CGRectMake(center.x-12.5, center.y-12.5, 25, 25);
  view.backgroundColor = [UIColor clearColor];

  view.layer.shadowColor = [[UIColor blackColor] CGColor];
  view.layer.shadowOpacity = 0.6;
  view.layer.shadowRadius = 3.0;
  view.layer.shadowOffset = CGSizeMake(0, 2);
  
  view.transform = CGAffineTransformMakeScale(0.1, 0.1);
  int random = arc4random_uniform(400);
  double random2 = random / 1000.0f;
  
  NSTimeInterval delay = (NSTimeInterval)random2;
  NSLog(@"%f", delay);
  view.alpha = 0;
  
  [UIView animateWithDuration:0.5 delay:delay usingSpringWithDamping:0.3 initialSpringVelocity:0.9 options:UIViewAnimationOptionAllowUserInteraction animations:^{
    view.transform = CGAffineTransformIdentity;
    view.alpha = 1;
  } completion:^(BOOL finished) {
    
  }];
  return view;
  
}

-(UIColor *) getColorFromString:(NSString *) colorName {
  NSLog(@"%@", colorName);
  if ([colorName isEqualToString:@"orange"]) {
    return self.flatOrange;
  } else if ([colorName isEqualToString:@"blue"]) {
    return self.flatBlue;
  } else if ([colorName isEqualToString:@"turquoise"]) {
    return self.flatTurquoise;
  } else if ([colorName isEqualToString:@"purple"]) {
    return self.flatPurple;
  } else if ([colorName isEqualToString:@"yellow"]) {
    return self.flatYellow;
  } else if ([colorName isEqualToString:@"green"]) {
    return self.flatGreen;
  } else {
    return self.flatRed;
  }
  
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
  [self.networkController fetchDotsWithRegion:self.mapView.region completionHandler:^(NSError *error, NSArray *dots) {
    if (dots != nil) {
      self.dots = dots;
      [self populateDotsOnMap];
      NSLog(@"%@", self.dots.description);
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
  



@end
