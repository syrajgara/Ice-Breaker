//
//  QBAuthenticator.m
//  Ice Breaker
//
//  Created by shabbir on 5/18/13.
//  Copyright (c) 2013 shabbir rajgara. All rights reserved.
//

#import "QBAuthenticator.h"

#import "DataManager.h"

@interface QBAuthenticator()

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password; // TODO do not store
@property (strong, nonatomic) id<QBChatDelegate> loginResponseHandlerVC;

@end

@implementation QBAuthenticator

- (IBAction)loginWithUserName:(NSString *)userName
                  andPassword:(NSString *)password
           withLoginResponseHandler:(id<QBChatDelegate>) loginResponseHandlerVC
{
  self.userName = userName;
  self.password = password;
  self.loginResponseHandlerVC = loginResponseHandlerVC;
  
  NSLog(@" userName = %@", userName);
  
  QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];

  extendedAuthRequest.userLogin = userName;
  extendedAuthRequest.userPassword = password;
  
  [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
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
    currentUser.password = self.password; // your current user's password
    
    // save current user
    [[DataManager shared] setCurrentUser: currentUser];
    [[[DataManager shared] currentUser] setPassword:self.password];
    
    // set Chat delegate
    [QBChat instance].delegate = self.loginResponseHandlerVC;
    
    // login to Chat
    [[QBChat instance] loginWithUser:currentUser];
    //[[QBChat instance] loginWithUser:[DataManager shared].currentUser];
  }
  else
  {
    // Errors
    NSString *errorTags = [result.errors componentsJoinedByString:@"\n"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",errorTags]
                                                    message:@"Please check your email address and password"
                                                   delegate:Nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    
    NSLog(@"errors = %@",errorTags);
    [alert show];
    return;
  }
}

@end
