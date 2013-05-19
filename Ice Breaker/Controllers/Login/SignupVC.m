//
//  SignupVC.m
//  Ice Breaker
//
//  Created by shabbir rajgara on 5/5/13.
//  Copyright (c) 2013 shabbir rajgara. All rights reserved.
//

#import "SignupVC.h"

#import "QBAuthenticator.h"

@interface SignupVC ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation SignupVC

- (IBAction)signup:(UIButton *)sender
{
  NSLog(@" username = %@", self.userName.text);
  
  // Create QuickBlox User entity
  QBUUser *user = [QBUUser user];
	user.password = self.password.text;
  user.email = self.userName.text;
  
  // create User
	[QBUsers signUp:user delegate:self];
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
-(void)completedWithResult:(Result*)result
{
  // QuickBlox User creation result
  if([result isKindOfClass:[QBUUserResult class]])
  {
    
    NSLog(@" username = %@", self.userName.text);
    
		if ( !result.success )
    {
      // Errors
      NSString *errorTags = [result.errors componentsJoinedByString:@"\n"];
      
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                      message:[NSString stringWithFormat:@"%@",errorTags]
                                                     delegate:self
                                            cancelButtonTitle:@"Okay"
                                            otherButtonTitles:nil, nil];
      
      NSLog(@"errors = %@",errorTags);
      [alert show];
      return;
		}

    QBAuthenticator *qbAuthenticator = [[QBAuthenticator alloc] init];
    
    [qbAuthenticator loginWithUserName:self.userName.text
                           andPassword:self.password.text
              withLoginResponseHandler:self];
  }
}

#pragma mark
#pragma mark UIAlertView delegate

- (void)      alertView:(UIAlertView *)alertView
   clickedButtonAtIndex:(NSInteger)buttonIndex
{
  [self.navigationController popViewControllerAnimated:YES];
}

/*
 after succesful login and then signin to chat server, this delegate function is called
 */
-(void) chatDidLogin
{
  NSLog(@"signed in ...");
  [self performSegueWithIdentifier:@"AvailableForChatSegue" sender:self];
}

@end
