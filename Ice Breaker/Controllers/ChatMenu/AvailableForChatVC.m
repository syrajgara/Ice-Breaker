//
//  AvailableForChatViewController.m
//  chatMojo
//
//  Created by trupti hosmani on 2/24/13.
//  Copyright (c) 2013 trupti hosmani. All rights reserved.
//

#import "AvailableForChatVC.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DataManager.h"
#import "ChatVC.h"

#import "ECSlidingViewController.h"
#import "MenuVC.h"

@interface AvailableForChatVC ()

@end

@implementation AvailableForChatVC
@synthesize users;
@synthesize tableView;
@synthesize searchBar;
@synthesize selectedUsers;
@synthesize senderUsers;
@synthesize user;

@synthesize requesAllUsersTimer;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUsers];
    // Do any additional setup after loading the view.
}

- (void)reloadAvailableForChat
{
    [self.tableView reloadData];
    
    // Set Chat delegate
    [QBChat instance].delegate = self;
    
    // send presence every 10 seconds & check for new rooms
    if([DataManager shared].currentUser){
        
        // send presence
        if(sendPresenceTimer == nil){
            sendPresenceTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                                  target:self
                                                                selector:@selector(sendPresence)
                                                                userInfo:nil
                                                                 repeats:YES] ;
        }
        
        // retrieve rooms
        if(requestRoomsTimer == nil){
            requestRoomsTimer= [NSTimer scheduledTimerWithTimeInterval:10
                                                                 target:self
                                                               selector:@selector(updateRooms)
                                                               userInfo:nil
                                                                repeats:YES];
        }
        [requestRoomsTimer fire];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuVC class]]) {
    self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
  }
  
  self.slidingViewController.underRightViewController = nil;
  
  [self.view addGestureRecognizer:self.slidingViewController.panGesture];
  
  [self reloadAvailableForChat];
}

- (IBAction)revealMenu:(id)sender
{
  [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark -
#pragma mark Methods

- (void)updateUsers{
    // Retrieve all users
    PagedRequest* request = [PagedRequest request];
    request.perPage = 100; // 100 users
	[QBUsers usersWithPagedRequest:request delegate:self];
}

// send presence
- (void)sendPresence{
    // presence in QuickBlox Chat
    [[QBChat instance] sendPresence];
    // presence in QuickBlox
    [QBUsers userWithExternalID:1 delegate:nil];
}

// update rooms
- (void)updateRooms {
	[[QBChat instance] requestAllRooms];
}


// Start Chat
- (void)startChat{
    
    // nobody selected
    if(![self.selectedUsers count]){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"You must choose at least one user for chat"
													   delegate:nil
											  cancelButtonTitle:@"Okay"
											  otherButtonTitles:nil, nil];
		[alert show];
        
        // Selected 1 user - Start chat 1-1
    }else if([self.selectedUsers count] == 1){
        
        // Show Chat view controller
        UIStoryboard *storyboard = self.storyboard;
        ChatVC *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatVC"];
        QBUUser *opponent = [self.selectedUsers objectAtIndex:0];
        [self.selectedUsers removeAllObjects];
        [self.senderUsers removeAllObjects];
        [chatVC setTitle:opponent.login ? opponent.login : opponent.fullName];

        chatVC.opponent = opponent;
        [self presentViewController:chatVC animated:YES completion:NULL];
        
        
        // Selected some users - Start chat in room
    }else {
        
        // Show alert for enter room's topic
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Topic"
                                                        message:@"\n"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Start", nil];
        [alert setTag:2];
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 31.0)];
        [theTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [theTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [theTextField setBorderStyle:UITextBorderStyleRoundedRect];
        [theTextField setBackgroundColor:[UIColor whiteColor]];
        [theTextField setTextAlignment:UITextAlignmentCenter];
        theTextField.tag = 101;
        [alert addSubview:theTextField];
        
        [alert show];
    }
}


#pragma mark -
#pragma mark TableViewDataSource & TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger rowSelected = [[self tableView].indexPathForSelectedRow row];
    
    QBUUser *selectedUser = [self.users objectAtIndex:rowSelected];

    UIStoryboard *storyboard = self.storyboard;

    ChatVC *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatVC"];
    [self.selectedUsers removeAllObjects];
    [self.senderUsers removeAllObjects];
    [chatVC setTitle:selectedUser.login ? selectedUser.login : selectedUser.fullName];
  //[chatVC setOpponent:selectedUser];
    chatVC.opponent = selectedUser;
  
    [self presentViewController:chatVC animated:YES completion:NULL];
    

    // Select room
    if([[[DataManager shared] rooms] count] > 0 && indexPath.section == 0){
        
        QBChatRoom *selectedRoom = [[[DataManager shared] rooms] objectAtIndex:rowSelected];
        
        // Join room
        [selectedRoom joinRoom];
        
        // Mark/unmark users
    }else {
        QBUUser *selectedUser = [self.users objectAtIndex:rowSelected];
        
        if([self.senderUsers containsObject:selectedUser]){
            [self.senderUsers removeObject:selectedUser];
            [self.tableView reloadData];
            UIStoryboard *storyboard = self.storyboard;
            ChatVC *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatVC"];
            [self.selectedUsers removeAllObjects];
            [self.senderUsers removeAllObjects];
            NSLog(@"__________________________________________opponent= %@", selectedUser.login);
            [chatVC setTitle:selectedUser.login ? selectedUser.login : selectedUser.fullName];
          //[chatVC setOpponent:selectedUser];
          chatVC.opponent = selectedUser;
          
            [self presentViewController:chatVC animated:YES completion:NULL];

            
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([[[DataManager shared] rooms] count]){
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([[[DataManager shared] rooms] count] && section == 0){
        return [[[DataManager shared] rooms] count];
    }else{
        NSLog(@"%d", [self.users count]);
        return [self.users count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if([[[DataManager shared] rooms] count] && section == 0){
        return @"Rooms";
    }else{
        return @"Users";
    }
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* SimpleTableIdentifier = @"Cell";
    
    // Create cell
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] init];
    }
    
    // Room's cell
    if([[[DataManager shared] rooms] count] && indexPath.section == 0){
        
        // set room's name & icon
        QBChatRoom *room = [[[DataManager shared] rooms] objectAtIndex:indexPath.row];
        [cell.textLabel setText:room.name];
        [cell.imageView setImage:[UIImage imageNamed:@"room-icon.png"]];
        
        // User's cell
    }else{
        
        // set user's name & icon
        QBUUser *userCell = [self.users objectAtIndex:indexPath.row];
        [cell.textLabel setText:userCell.login ? userCell.login : userCell.fullName];
        NSString *tags = [userCell.tags componentsJoinedByString:@","];
        [cell.detailTextLabel setText:tags];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:9.0];
        [cell.imageView setImage:[UIImage imageNamed:@"user.png"]];
        
        NSInteger currentDate = [[NSDate date] timeIntervalSince1970];
        NSInteger userDate    = [[userCell lastRequestAt] timeIntervalSince1970];
        
        if((currentDate - userDate) > 300){ // if user didn't do anything last 5 minutes - he is offline
            [cell.imageView setImage:[UIImage imageNamed:@"offline.png" ]];
        }else {
            [cell.imageView setImage:[UIImage imageNamed:@"online.png" ]];
        }
        
        if([self.selectedUsers containsObject:user]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}



#pragma mark -
#pragma mark UISearchBarDelegate

-(void) searchBarSearchButtonClicked:(UISearchBar *)SearchBar{
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //[self.users removeAllObjects];
    
    // clear
    if([searchText length] == 0){
        [self.users addObjectsFromArray:[[DataManager shared] users]];
        [self.searchBar resignFirstResponder];
        
        // search users
    }else{
        for(QBUUser *user in [[DataManager shared] users]){
            
            NSRange note;
            if(user.login){
                note = [user.login rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }else {
                note = [user.fullName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            }
            
            if(note.location != NSNotFound){
                [self.users addObject:user];
            }
        }
    }
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Room's topic alert
    if(alertView.tag == 2 && buttonIndex == 1){
        
        NSString *roomName = ((UITextField *)[alertView viewWithTag:101]).text;
        
        // check name
        if(roomName.length > 0){
            
            int count = 0;
            
            // Join if already exist
            for(QBChatRoom *roomInList in [[DataManager shared] rooms]){
                if([[roomInList name] isEqualToString:roomName]){
                    
                    QBChatRoom *selectedRoom = [[[DataManager shared] rooms] objectAtIndex:count];
                    
                    // Join room
                    [selectedRoom joinRoom];
                    
                    [self.senderUsers removeAllObjects];
                    [self.selectedUsers removeAllObjects];
                    
                    // Show Chat view controller
                    /*ChatViewController *chatViewController = [[[ChatViewController alloc] init] autorelease];
                    [chatViewController setTitle:[selectedRoom name]];
                    [chatViewController setCurrentRoom:selectedRoom];
                    [self.navigationController pushViewController:chatViewController animated:YES];*/
                    
                    return;
                }
                count++;
            }
            
            // Create room
            [[QBChat instance] createOrJoinRoomWithName:roomName membersOnly:YES persistent:NO];
        }
    }
}


#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
        if(result.success && [result isKindOfClass:[QBUUserPagedResult class]]){
            QBUUserPagedResult *usersResult = (QBUUserPagedResult *)result;
            NSLog(@"Users=%@", [usersResult.users valueForKey:@"login"]);
            [DataManager shared].users = usersResult.users;
            users = usersResult.users;
            [self.tableView reloadData];
        }else{
            NSLog(@"errors=%@", result.errors);
        }
	
}


#pragma mark -
#pragma mark QBChat delegate

// Did receive 1-1 message
- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    
    for(QBUUser *user in [[DataManager shared] users]){
        if(message.senderID == user.ID && ![self.senderUsers containsObject:user]){
            [self.senderUsers addObject:user];
            [self.tableView reloadData];
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            if([[DataManager shared] chatHistoryWithOpponentID:message.senderID]){
                [messages addObjectsFromArray:[[DataManager shared] chatHistoryWithOpponentID:message.senderID]];
            }
            
            [messages addObject:message];
            [[DataManager shared] saveMessage:[NSKeyedArchiver archivedDataWithRootObject:messages]
                      toHistoryWithOpponentID:message.senderID];
        }
    }
    
}

// Called in case receiving list of avaible to join rooms.
- (void)chatDidReceiveListOfRooms:(NSArray *)rooms{
    
    // clear old rooms
    for(QBChatRoom *room in [NSArray arrayWithArray:[DataManager shared].rooms]){
        if(![rooms containsObject:room]){
            [[DataManager shared].rooms removeObject:room];
        }
    }
    
    // Save new rooms
    for(QBChatRoom *room in rooms){
        if(![[DataManager shared].rooms containsObject:room]){
            [[DataManager shared].rooms addObject:room];
        }
    }
	
    // reload table
    [self.tableView reloadData];
}

// Fired when you did enter to room
- (void)chatRoomDidEnter:(QBChatRoom *)room{
    NSLog(@"Main Controller chatRoomDidEnter");
    
    if([[DataManager shared].rooms indexOfObjectIdenticalTo:room] == NSNotFound){
        // save our room
        [[[DataManager shared] rooms] addObject:room];
    }
    
    // add users if are creating room
    if([self.selectedUsers count] > 0){
        // add selected users to room
        NSMutableArray *userIDs = [[NSMutableArray alloc] init];
        for(QBUUser *user in self.selectedUsers){
            [userIDs addObject:[NSNumber numberWithInt:user.ID]];
        }
        [room addUsers:userIDs];
        
        [self.senderUsers removeAllObjects];
        [self.selectedUsers removeAllObjects];
    }
    
    // show chat view controller
  /*  ChatViewController *chatViewController = [[[ChatViewController alloc] init] autorelease];
    [chatViewController setTitle:room.name];
    [chatViewController setCurrentRoom:room];
    [self.selectedUsers removeAllObjects];
    [self.navigationController pushViewController:chatViewController animated:YES];*/
}

// Fired when you did not enter to room
- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@, error:", roomName]
                                                    message:[error domain]
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

// Fired when you did leave room
- (void)chatRoomDidLeave:(NSString *)roomName{
    NSLog(@"Main Controller chatRoomDidLeave");
}
@end
