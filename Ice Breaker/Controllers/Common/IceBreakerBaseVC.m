//
//  IceBreakerBaseVC.m
//  Ice Breaker
//
//  Created by shabbir on 5/18/13.
//  Copyright (c) 2013 shabbir rajgara. All rights reserved.
//

#import "IceBreakerBaseVC.h"

#import <QuartzCore/QuartzCore.h>

@interface IceBreakerBaseVC ()

@end

@implementation IceBreakerBaseVC

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.layer.borderColor = [UIColor redColor].CGColor;
  self.view.layer.borderWidth = 1.0f;
  self.view.layer.cornerRadius = 7.0f;
  
  // TODO following wont work since the sub-views are being clipped.
  // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
  // You just need to set the opacity, radius, and color.
  self.view.layer.shadowOpacity = 0.75f;
  self.view.layer.shadowRadius = 3.0f;
  self.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

@end
