//
//  QBAuthenticator.h
//  Ice Breaker
//
//  Created by shabbir on 5/18/13.
//  Copyright (c) 2013 shabbir rajgara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBAuthenticator : NSObject <QBActionStatusDelegate>

- (IBAction)loginWithUserName:(NSString *)userName
                  andPassword:(NSString *)password
     withLoginResponseHandler:(id<QBChatDelegate>) loginResponseHandlerVC;

@end
