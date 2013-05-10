//
//  LoginVC.m
//  Ice Breaker
//
//  Created by shabbir rajgara on 5/5/13.
//  Copyright (c) 2013 shabbir rajgara. All rights reserved.
//

#import "LoginVC.h"
#import "SignupVC.h"
#import "DataManager.h"

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

- (void)viewDidUnload
{
  [self setPassword:nil];
  [self setUserName:nil];

  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (IBAction)login:(UIButton *)sender
{
  NSLog(@" username = %@", self.userName.text);
  
  QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
  extendedAuthRequest.userLogin =@"trupti";     //userName.text;
  extendedAuthRequest.userPassword = @"password";     //password.text;
  
  [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
}

- (IBAction)cancelSignup:(UIStoryboardSegue *)segue
{
  NSLog(@"signup cancelled");
}

#pragma mark - QBActionStatusDelegate

// QuickBlox queries delegate
- (void)completedWithResult:(Result *)result
{
  NSLog(@"completed login...");

  // Create session result
  if(result.success && [result isKindOfClass:QBAAuthSessionCreationResult.class])
  {
    // You have successfully created the session
    QBAAuthSessionCreationResult *res = (QBAAuthSessionCreationResult *)result;
    
    // Sign In to QuickBlox Chat
    QBUUser *currentUser = [QBUUser user];
    currentUser.ID = res.session.userID; // your current user's ID
    currentUser.password = @"password"; // your current user's password
    
    // save current user
    [[DataManager shared] setCurrentUser: currentUser];
    [[[DataManager shared] currentUser] setPassword:@"password"];
    
    // set Chat delegate
    [QBChat instance].delegate = self;

    // login to Chat
    [[QBChat instance] loginWithUser:currentUser];
    //[[QBChat instance] loginWithUser:[DataManager shared].currentUser];
  }
}

#pragma mark - QBChatDelegate

// Chat delegate
-(void) chatDidLogin
{
  NSLog(@"signed in ...");
  [self performSegueWithIdentifier:@"AvailableForChatSegue" sender:self];
}

@end
