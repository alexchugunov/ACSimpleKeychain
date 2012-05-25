//
//  ACAppDelegate.m
//  KeychainExample
//
//  Created by Alex Chugunov on 5/5/12.
//  Copyright (c) 2012 Eatlime Inc. All rights reserved.
//

#import "ACAppDelegate.h"
#import "ACSimpleKeychain.h"

@implementation ACAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self testKeychain];
    return YES;
}

- (void)testKeychain
{
    NSLog(@"Testing keychain...");
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    
    NSArray *all = [keychain allCredentialsForService:@"twitter" limit:99];
    if ([all count]) {
        NSLog(@"All credentials for service 'twitter' %@", [keychain allCredentialsForService:@"twitter" limit:99]);
        NSLog(@"All credentials for service 'MobileMe' %@", [keychain allCredentialsForService:@"MobileMe" limit:99]);
        // Request credentials for account with username 'user1'
        NSDictionary *credentials = [keychain credentialsForUsername:@"user1" service:@"twitter"];
        NSLog(@"CREDENTIALS: service: %@, identifier: %@, username: %@, password: %@",
              [credentials valueForKey:ACKeychainService],
              [credentials valueForKey:ACKeychainIdentifier],
              [credentials valueForKey:ACKeychainUsername],
              [credentials valueForKey:ACKeychainPassword]);
        
        // Request credentials for account with identifier 'account2'
        credentials = [keychain credentialsForIdentifier:@"account2" service:@"twitter"];
        NSLog(@"CREDENTIALS: service: %@, identifier: %@, username: %@, password: %@",
              [credentials valueForKey:ACKeychainService],
              [credentials valueForKey:ACKeychainIdentifier],
              [credentials valueForKey:ACKeychainUsername],
              [credentials valueForKey:ACKeychainPassword]);
        
        if ([keychain deleteCredentialsForIdentifier:@"account1" service:@"twitter"]) {
            NSLog(@"DELETED credentials for 'account1'");
        }
        
        NSLog(@"All credentials for service 'twitter' %@", [keychain allCredentialsForService:@"twitter" limit:99]);
        
        // Request credentials for account with username 'user3'
        if ([keychain deleteCredentialsForUsername:@"user3" service:@"twitter"]) {
            NSLog(@"DELETED credentials for 'user3'");
        }
        NSLog(@"All credentials for service 'twitter' %@", [keychain allCredentialsForService:@"twitter" limit:99]);
        
        // Delete all account for service MobileMe
        if ([keychain deleteAllCredentialsForService:@"MobileMe"]) {
            NSLog(@"DELTED all credentials for service 'MobileMe'");
        }
        NSLog(@"All credentials for service 'MobileMe' %@", [keychain allCredentialsForService:@"MobileMe" limit:99]);
    }
    else {
        NSLog(@"No CREDENTIALS found for service 'twitter'");
        // Save credentials for user1
        if ([keychain storeUsername:@"user1" password:nil identifier:@"account1" forService:@"twitter"]) {
            NSLog(@"**SAVED credentials for username 'user1' credentials identifier 'account1'");
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:360000000];
        NSLog(@"%@", date);
        
        if ([keychain storeUsername:@"user4" password:@"password" identifier:@"account3" expirationDate:date forService:@"MobileMe"]) {
            NSLog(@"**SAVED credentials for username 'user4' credentials identifier 'account3'");
        }
        
        if ([keychain storeUsername:@"user5" password:@"password" identifier:@"account4"
                               info:[NSDictionary dictionaryWithObject:@"SomeRandomInfo"
                                                                forKey:@"key1"]
                         forService:@"MobileMe"])
        {
            NSLog(@"**SAVED credentials for username 'user5' credentials identifier 'account4'");
        }
        
        // Save credentials for user2
        if ([keychain storeUsername:@"user2" password:@"password" identifier:@"account2" forService:@"twitter"]) {
            NSLog(@"**SAVED credentials for username 'user2' credentials identifier 'account2'");
        }
        
        // Replace user2 with user3
        if ([keychain storeUsername:@"user3" password:@"password" identifier:@"account2" forService:@"twitter"]) {
            NSLog(@"**CHANGED credentials for credentials identifier 'account2'");
        }    
        
        NSLog(@"All credentials for service 'twitter' %@", [keychain allCredentialsForService:@"twitter" limit:99]);
        NSLog(@"All credentials for service 'MobileMe' %@", [keychain allCredentialsForService:@"MobileMe" limit:99]);
    }
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
