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
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
  // You just need to set the opacity, radius, and color.
  self.view.layer.shadowOpacity = 0.75f;
  self.view.layer.shadowRadius = 2.0f;
  self.view.layer.shadowColor = [UIColor blackColor].CGColor;
  
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
