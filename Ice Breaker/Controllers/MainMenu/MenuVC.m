//
//  MenuViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "MenuVC.h"

#import "ECSlidingViewController.h"

@interface MenuVC()

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation MenuVC
@synthesize menuItems;

- (void)awakeFromNib
{
  self.menuItems = [NSArray arrayWithObjects:@"AvailableForChatVC", @"EventMapVC", nil];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.slidingViewController setAnchorRightPeekAmount:49.0f];
  self.slidingViewController.underLeftWidthLayout = ECFullWidth; //ECVariableRevealWidth;
}

- (void)viewWillAppear:(BOOL)animated
{
  [self.slidingViewController.topViewController.view.layer setMasksToBounds:NO];
  self.slidingViewController.topViewController.view.layer.cornerRadius = 0.0f;

  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self.slidingViewController.topViewController.view.layer setMasksToBounds:YES];
  self.slidingViewController.topViewController.view.layer.cornerRadius = 7.0f;
  
  [super viewWillDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [NSString stringWithFormat:@"Some Section Title %d", section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
  return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier = @"MenuItemCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
  }
  
  cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = [NSString stringWithFormat:@"%@", [self.menuItems objectAtIndex:indexPath.row]];

  UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
  
  self.slidingViewController.topViewController = newTopViewController;

  [self.slidingViewController resetTopView];
}

@end
