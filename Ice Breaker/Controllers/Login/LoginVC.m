//
//  LoginVC.m
//  Ice Breaker
//
//  Created by shabbir rajgara on 5/5/13.
//  Copyright (c) 2013 shabbir rajgara. All rights reserved.
//

#import "LoginVC.h"

#import "SignupVC.h"
#import "QBAuthenticator.h"

@interface LoginVC()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation LoginVC

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.navigationController.navigationBarHidden=YES;
}

- (IBAction)login:(UIButton *)sender
{
  QBAuthenticator *qbAuthenticator = [[QBAuthenticator alloc] init];

  [qbAuthenticator loginWithUserName:self.userName.text
                         andPassword:self.password.text
            withLoginResponseHandler:self];

/*
 TESTING 
 
 [qbAuthenticator loginWithUserName:@"trupti" //self.userName.text //
 andPassword:@"password" //self.password.text //
 withLoginResponseHandler:self];
 */
}

/*
 return seque uses this function to come back to login screen if signup was cancelled
 */
- (IBAction)cancelSignup:(UIStoryboardSegue *)segue
{
  NSLog(@"signup cancelled");
}

#pragma mark - QBChatDelegate

/*
 after succesful login and then signin to chat server, this delegate function is called
 */
-(void) chatDidLogin
{
  NSLog(@"signed in ...");
  [self performSegueWithIdentifier:@"AvailableForChatSegue" sender:self];
}

@end
