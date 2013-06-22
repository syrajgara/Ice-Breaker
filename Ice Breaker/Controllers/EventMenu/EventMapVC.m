//
//  EventMapVC.m
//  Ice Breaker
//
//  Created by shabbir rajgara on 5/6/13.
//  Copyright (c) 2013 shabbir rajgara. All rights reserved.
//

#import "EventMapVC.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

#import "ECSlidingViewController.h"
#import "MenuVC.h"

@interface EventMapVC ()
@property (weak, nonatomic) IBOutlet MKMapView *eventMap;
@end

@implementation EventMapVC

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.eventMap.showsUserLocation = YES;
  
  [self.eventMap setRegion:MKCoordinateRegionMake([self mapsCenterLocation], [self mapsRegionSpan])
                  animated:NO];
}

- (CLLocationCoordinate2D) mapsCenterLocation
{
  // SCU location
  CLLocationCoordinate2D coord;
  coord.latitude = 37.3499438f;
  coord.longitude = -121.9406449f;

  return coord;
}

- (MKCoordinateSpan) mapsRegionSpan
{
  return MKCoordinateSpanMake(0.006, 0.006);
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuVC class]]) {
    self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
  }
  
  self.slidingViewController.underRightViewController = nil;
  
  [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
