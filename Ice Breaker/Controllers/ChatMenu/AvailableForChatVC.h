//
//  AvailableForChatViewController.h
//  chatMojo
//
//  Created by trupti hosmani on 2/24/13.
//  Copyright (c) 2013 trupti hosmani. All rights reserved.
//

#import "IceBreakerBaseVC.h"

@interface AvailableForChatVC : IceBreakerBaseVC <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, QBActionStatusDelegate, QBChatDelegate>{
    
    NSTimer *sendPresenceTimer;
    NSTimer *requestRoomsTimer;
    NSTimer *requesAllUsersTimer;
}

@property (nonatomic, retain) NSTimer *requesAllUsersTimer;

@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSDictionary *user;
@property (nonatomic, retain) NSMutableArray *selectedUsers;
@property (nonatomic, retain) NSMutableArray *senderUsers;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

- (void)startChat;
- (IBAction)revealMenu:(id)sender;

@end
