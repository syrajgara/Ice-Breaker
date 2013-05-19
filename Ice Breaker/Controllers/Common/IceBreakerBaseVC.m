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
  self.view.layer.borderWidth = 3.0f;
}

@end
