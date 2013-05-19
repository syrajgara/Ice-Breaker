//
//  ChatViewController.m
//  chatMojo
//
//  Created by trupti hosmani on 2/25/13.
//  Copyright (c) 2013 trupti hosmani. All rights reserved.
//

#import "ChatVC.h"

#import "DataManager.h"

@interface ChatVC ()

@end

@implementation ChatVC

@synthesize opponent;
@synthesize currentRoom;
@synthesize messages;

@synthesize toolBar;
@synthesize messageField;
@synthesize sendButton;
@synthesize tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    // Chat in room
    if(!self.opponent){
        
        messages = [[NSMutableArray alloc] init];
        
        // Chat 1-1
    }else{
        
        // load history
        messages = [[DataManager shared] chatHistoryWithOpponentID:self.opponent.ID];
        
        if(messages == nil){
            messages = [[NSMutableArray alloc] init];
        }
    }
    
    // set chat delegate
    [[QBChat instance] setDelegate:self];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setSendButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // leave room
    if(self.currentRoom){
        if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
            // back button was pressed.
            [[QBChat instance] leaveRoom:self.currentRoom];
            [[DataManager shared].rooms removeObject:self.currentRoom];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)keyboardShow{
    CGRect rectFild = self.messageField.frame;
    rectFild.origin.y -= 215;
    
    CGRect rectButton = self.sendButton.frame;
    rectButton.origin.y -= 215;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [self.messageField setFrame:rectFild];
                         [self.sendButton setFrame:rectButton];
                     }
     ];
}

-(void)keyboardHide{
    CGRect rectFild = self.messageField.frame;
    rectFild.origin.y += 215;
    CGRect rectButton = self.sendButton.frame;
    rectButton.origin.y += 215;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [self.messageField setFrame:rectFild];
                         [self.sendButton setFrame:rectButton];
                     }
     ];
}

#pragma mark -
#pragma mark Methods


- (IBAction)sendMessageButton:(id)sender {
    if(self.messageField.text.length == 0){
        return;
    }
    
    // Send message to opponent
    if(self.opponent){
        // send message
        QBChatMessage *message = [[QBChatMessage alloc] init];
        message.recipientID = opponent.ID;
        message.text = self.messageField.text;
        [[QBChat instance] sendMessage:message];
        
        // save message to cache
        [self.messages addObject:message];
        [[DataManager shared] saveMessage:[NSKeyedArchiver archivedDataWithRootObject:messages]
                  toHistoryWithOpponentID:self.opponent.ID];
        NSLog(@"message %@",self.messages);
        
        // Check if user offline -> send push notifications to him
        // if user didn't do anything last 5 minutes - he is offline
        NSInteger currentDate = [[NSDate date] timeIntervalSince1970];
        if(currentDate - [self.opponent.lastRequestAt timeIntervalSince1970] > 300){
            
			// Send push
			[QBMessages TSendPushWithText:self.messageField.text
                                  toUsers:[NSString stringWithFormat:@"%d", self.opponent.ID]
                                 delegate:nil];
        }
     
        
        // reload table
        [self.tableView reloadData];
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        // Send message to room
    }else if(self.currentRoom){
        
        [[QBChat instance] sendMessage:self.messageField.text toRoom:self.currentRoom];
        
        // reload table
        [self.tableView reloadData];
    }
    
    // hide keyboard & clean text field
    [self.messageField resignFirstResponder];
    [self.messageField setText:nil];
}

#pragma mark -
#pragma mark TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self keyboardShow];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self keyboardHide];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)backgroundTouched:(id)sender
{
    [self.messageField resignFirstResponder];
}


#pragma mark - Table View
static CGFloat padding = 20.0;


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatMessage *chatMessage = (QBChatMessage *)[messages objectAtIndex:indexPath.row];
	NSString *text = chatMessage.text;
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:13]
                   constrainedToSize:textSize
                       lineBreakMode:UILineBreakModeWordWrap];
	
	size.height += padding;
	return size.height+padding+5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
	
    // Create cell
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = NO;
    
    // Message
    QBChatMessage *messageBody = [messages objectAtIndex:[indexPath row]];
    
    // set message's text
	NSString *message = [messageBody text];
    cell.textLabel.text = message;
    NSLog(@"messages in table =%@", messageBody);
    
    // message's datetime
                 
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *time = [formatter stringFromDate:messageBody.datetime];
    
	
	CGSize textSize = { 260.0, 10000.0 };
	CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13]
					  constrainedToSize:textSize
						  lineBreakMode:UILineBreakModeWordWrap];
	size.width += (padding/2);
	
    
    // Left/Right bubble
    UIImage *bgImage = nil;
    NSLog(@"current user = %@",[[[DataManager shared] currentUser] login]);

    if ([[[DataManager shared] currentUser] ID] == messageBody.senderID || self.currentRoom) {
        NSLog(@"current user = %@",[[[DataManager shared] currentUser] login]);

        
        bgImage = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [cell.textLabel setFrame:CGRectMake(padding, padding*2, size.width+padding, size.height+padding)];
        
        [cell.backgroundView setFrame:CGRectMake( cell.textLabel.frame.origin.x - padding/2,
                                                      cell.textLabel.frame.origin.y - padding/2,
                                                      size.width+padding,
                                                      size.height+padding)];
        
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        cell.backgroundView = bgImage;
        
        if(self.currentRoom){
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", messageBody.senderID, time];
        }else{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [[[DataManager shared] currentUser] login], time];
        }
        
    } else {
        
        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
        
        [cell.textLabel setFrame:CGRectMake(320 - size.width - padding,
                                          padding*2,
                                          size.width+padding,
                                          size.height+padding)];
        
        [cell.backgroundView setFrame:CGRectMake(cell.textLabel.frame.origin.x - padding/2,
                                                      cell.textLabel.frame.origin.y - padding/2,
                                                      size.width+padding,
                                                      size.height+padding)];
        
        cell.detailTextLabel.textAlignment = UITextAlignmentRight;
        cell.backgroundView = bgImage;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by: %@ at:%@", [[[DataManager shared] currentUser] login], time];
        
        NSLog(@"current user = %@",[[[DataManager shared] currentUser] login]);
    }
    
	return cell;
    
    
}


#pragma mark -
#pragma mark QBChatDelegate

// Did receive 1-1 message
- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    
	[self.messages addObject:message];
    NSLog(@"chat history= %@", self.messages);
    // save message to cache if this 1-1 chat
    if (self.opponent) {
        [[DataManager shared] saveMessage:[NSKeyedArchiver archivedDataWithRootObject:messages]
                  toHistoryWithOpponentID:self.opponent.ID];
        NSLog(@"chat history= %@",[[DataManager shared] chatHistoryWithOpponentID:[self.opponent ID]]);
    }
    
    // reload table
	[self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// Did receive message in room
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName{
    // save message
	[self.messages addObject:message];
    
    // reload table
	[self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// Fired when you did leave room
- (void)chatRoomDidLeave:(NSString *)roomName{
    NSLog(@"Chat Controller chatRoomDidLeave");
}

// Called in case changing occupant
- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName{
    NSLog(@"chatRoomDidChangeOnlineUsers %@, %@",roomName, onlineUsers);
}


@end
