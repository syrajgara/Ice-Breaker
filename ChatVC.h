//
//  ChatViewController.h
//  chatMojo
//
//  Created by trupti hosmani on 2/25/13.
//  Copyright (c) 2013 trupti hosmani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController<UITextFieldDelegate, QBChatDelegate>{
}

@property (nonatomic, retain) QBUUser        *opponent;
@property (nonatomic, retain) QBChatRoom     *currentRoom;
@property (nonatomic, retain) NSMutableArray *messages;

@property (retain, nonatomic) IBOutlet UIToolbar   *toolBar;
@property (retain, nonatomic) IBOutlet UITextField *messageField;

@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)sendMessageButton:(id)sender;

- (void)textFieldDidBeginEditing:(UITextField *)textField;

- (void)textFieldDidEndEditing:(UITextField *)textField;

@end
