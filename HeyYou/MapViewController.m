//
//  ViewController.m
//  HeyYou
//
//  Created by William Richman on 11/17/14.
//  Copyright (c) 2014 Hey You!. All rights reserved.
//

#import "MapViewController.h"
#import "DotAnnotationView.h"

@interface MapViewController ()

@property CGFloat kHorizontalCurveOffset;
@property CGFloat kVerticalCurveOffset;
@property CGFloat kPopupHeight;
@property NSArray *dots;

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
  [self setupSideMenu];
  [self setupMapView];
  [self addCircleView];
  [self addHamburgerMenuCircle];
  [self setupGestureRecognizers];
  
  self.mapView.delegate = self;

  self.kHorizontalCurveOffset = 2;
  self.kVerticalCurveOffset = 15;
  self.kPopupHeight = 480;
  
  self.customTeal = [UIColor colorWithRed:167/255.0 green:219/255.0 blue:216/255.0 alpha:1];
  self.customDarkOrange = [UIColor colorWithRed:250/255.0 green:105/255.0 blue:0/255.0 alpha: 1];
  self.customLightOrange = [UIColor colorWithRed: 243 / 255.0 green: 134 / 255.0 blue: 48  / 255.0 alpha: 1];
  self.customBlue = [UIColor colorWithRed: 105 / 255.0 green: 210 / 255.0 blue: 231 / 255.0 alpha: 1];
  self.customBeige = [UIColor colorWithRed: 224 / 255.0 green: 228 / 255.0 blue: 204 / 255.0 alpha: 1];
  
  self.flatTurquoise = [UIColor colorWithRed:26/255.0 green:188/255.0 blue:156/255.0 alpha:1];
  self.flatGreen = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha: 1];
  self.flatBlue = [UIColor colorWithRed: 52 / 255.0 green: 152 / 255.0 blue: 219  / 255.0 alpha: 1];
  self.flatPurple = [UIColor colorWithRed: 155 / 255.0 green: 89 / 255.0 blue: 182 / 255.0 alpha: 1];
  self.flatYellow = [UIColor colorWithRed: 241 / 255.0 green: 196 / 255.0 blue: 15 / 255.0 alpha: 1];
  self.flatOrange = [UIColor colorWithRed: 203 / 255.0 green: 126 / 255.0 blue: 34 / 255.0 alpha: 1];
  self.flatRed = [UIColor colorWithRed: 231 / 255.0 green: 76 / 255.0 blue: 60 / 255.0 alpha: 1];
  self.flatGray = [UIColor colorWithRed: 52 / 255.0 green: 73 / 255.0 blue: 94 / 255.0 alpha: 1];
  
  
  UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
  statusBar.backgroundColor = self.flatGreen;
  [self.view addSubview:statusBar];
  
}

-(void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NetworkController *networkController = [NetworkController sharedController];
  [networkController fetchDotsWithRegion:self.mapView.region completionHandler:^(NSString * string, NSArray * array) {
    self.dots = array;
    [self populateDotsOnMap];
    NSLog(@"%@", self.dots.description);
  }];
  
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
  self.sideMenuVC.view.backgroundColor = self.customTeal;
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
  self.draggableCircle.backgroundColor = [UIColor orangeColor];
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
  self.hamburgerLabel.textColor = [UIColor orangeColor];
  
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
  
}

-(void) receivedDragGestureOnDragCircle:(UIPanGestureRecognizer *)sender{
  CGPoint point = [sender locationInView:self.view];
  
  if (sender.state == UIGestureRecognizerStateChanged) {
    self.draggableCircle.center = point;
  } else if (sender.state == UIGestureRecognizerStateEnded) {
    PostViewController *postVC = [PostViewController new];
    postVC.location = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    postVC.delegate = self;
    self.currentPopup = postVC;
    [self spawnPopupAtPoint:point];
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
      [self addNewAnnotationForDot:dot];
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
  
  dotVC.dot = annotation.dot;
  
  self.currentPopup = dotVC;
  CGPoint point = [mapView convertCoordinate:view.annotation.coordinate toPointToView:self.view];
  [self spawnPopupAtPoint:point];
  
  
}

-(void) changeDotColor:(NSString *)color {
  
  if ([color isEqualToString:@"orange"]) {
    self.draggableCircle.backgroundColor = self.flatOrange;
  } else if ([color isEqualToString:@"green"]) {
    self.draggableCircle.backgroundColor = self.flatGreen;
  } else if ([color isEqualToString:@"blue"]) {
    self.draggableCircle.backgroundColor = self.flatBlue;
  } else if ([color isEqualToString:@"yellow"]) {
    self.draggableCircle.backgroundColor = self.flatYellow;
  } else if ([color isEqualToString:@"pink"]) {
    self.draggableCircle.backgroundColor = self.flatRed;
  } else if ([color isEqualToString:@"purple"]) {
    self.draggableCircle.backgroundColor = self.flatPurple;
  } else if ([color isEqualToString:@"teal"]) {
    self.draggableCircle.backgroundColor = self.flatTurquoise;
  }
  
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  
  DotAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Dot"];
  if (view == nil) {
    NSLog(@"Creating new!");
    view = [[DotAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Dot"];
  }
  DotAnnotation *anno = view.annotation;
  view.color = [self getColorFromString:anno.dot.color];
  
  CGPoint center = [mapView convertCoordinate:anno.coordinate toPointToView:self.view];
  view.frame = CGRectMake(center.x-15, center.y-15, 30, 30);
  view.backgroundColor = [UIColor clearColor];

  view.layer.shadowColor = [[UIColor blackColor] CGColor];
  view.layer.shadowOpacity = 0.6;
  view.layer.shadowRadius = 3.0;
  view.layer.shadowOffset = CGSizeMake(0, 2);
  return view;
  
}

-(UIColor *) getColorFromString:(NSString *) colorName {
  
  if ([colorName isEqualToString:@"orange"]) {
    return self.flatOrange;
  } else if ([colorName isEqualToString:@"blue"]) {
    return self.flatBlue;
  } else if ([colorName isEqualToString:@"teal"]) {
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
