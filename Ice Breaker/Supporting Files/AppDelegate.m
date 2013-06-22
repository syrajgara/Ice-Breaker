//
//  AppDelegate.m
//  Ice Breaker
//
//  Created by shabbir rajgara on 5/5/13.
//  Copyright (c) 2013 shabbir rajgara. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginVC.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  [self setupQuickBlox];

  return YES;
}

- (void)setupQuickBlox
{
  // Set QuickBlox credentials (You must create application in admin.quickblox.com)
  [QBSettings setApplicationID:1493];
  [QBSettings setAuthorizationKey:@"U8QT4aBXJJxhJwt"];
  [QBSettings setAuthorizationSecret:@"VBjn47vsZOjgVJV"];
  
  [QBAuth createSessionWithDelegate:self];
  // If you use Push Notifications - you have to use lines bellow when you upload your application to Apple Store or create AdHoc.
  //
#ifndef DEBUG
  [QBSettings useProductionEnvironmentForPushNotifications:YES];
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self fbApplicationDidBecomeActive:application];
    
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [self fbApplicationWillTerminate:application];
    
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Ice_Breaker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Ice_Breaker.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - FB Callback (iOS Notification)
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
  // Facebook SDK * login flow *
  // Attempt to handle URLs to complete any auth (e.g., SSO) flow.
  return [FBAppCall handleOpenURL:url
                sourceApplication:sourceApplication
                  fallbackHandler:^(FBAppCall *call)
          {
            // Facebook SDK * App Linking *
            if (call.accessTokenData)
            {
              if ([FBSession activeSession].isOpen)
              {
                // For simplicity, this sample will ignore the link if the session is already
                // open but a more advanced app could support features like user switching.
                NSLog(@"INFO: Ignoring app link because current session is open.");
              }
              else
              {
                [self handleAppLink:call.accessTokenData];
              }
            }
          }];
}

// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken
{
  // Initialize a new blank session instance...
  FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                   permissions:nil
                                               defaultAudience:FBSessionDefaultAudienceNone
                                               urlSchemeSuffix:nil
                                            tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];

  [FBSession setActiveSession:appLinkSession];

  // ... and open it from the App Link's Token.
  [appLinkSession openFromAccessTokenData:appLinkToken
                        completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
   {
     // Forward any errors to the FBLoginView delegate.
     if (error) //
     {
       NSLog(@"FB Login ERROR");
       // TODO seque to the login screen, instead of manual
       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhoneMainStoryboard.storyboard" bundle:nil];
       LoginVC *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
       [(UINavigationController*)self.window.rootViewController pushViewController:loginVC animated:NO];
       
       [loginVC loginView:nil handleError:error];
     }
   }];
}

- (void)fbApplicationWillTerminate:(UIApplication *)application
{
  // Facebook SDK * pro-tip *
  // if the app is going away, we close the session object; this is a good idea because
  // things may be hanging off the session, that need releasing (completion block, etc.) and
  // other components in the app may be awaiting close notification in order to do cleanup
  [FBSession.activeSession close];
}

- (void)fbApplicationDidBecomeActive:(UIApplication *)application
{
  // Facebook SDK * login flow *
  // We need to properly handle activation of the application with regards to SSO
  //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
  [FBAppCall handleDidBecomeActive];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
  self.isNavigating = NO;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
  self.isNavigating = YES;
}

@end
