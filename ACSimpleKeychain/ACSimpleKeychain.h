//
//  ACSimpleKeychain.h
//  ACSimpleKeychain
//
//  Created by Alex Chugunov on 2/3/11.
//  Copyright 2011 Alex Chugunov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

extern NSString *const ACKeychainPassword;
extern NSString *const ACKeychainUsername;
extern NSString *const ACKeychainIdentifier;
extern NSString *const ACKeychainService;
extern NSString *const ACKeychainExpirationDate;
extern NSString *const ACKeychainInfo;

@interface ACSimpleKeychain : NSObject {
    
}

+ (id)defaultKeychain;

// Creates new item with the provided values and deletes the old ones if those existed.
// Returns YES on success and NO on failure.
- (BOOL)storeUsername:(NSString *)username password:(NSString *)password identifier:(NSString *)identifier forService:(NSString *)service;
- (BOOL)storeUsername:(NSString *)username password:(NSString *)password identifier:(NSString *)identifier info:(NSDictionary *)info forService:(NSString *)service;

- (BOOL)storeUsername:(NSString *)username password:(NSString *)password identifier:(NSString *)identifier expirationDate:(NSDate *)expirationDate forService:(NSString *)service;


// On success returns a dictionary with the following keys:
//  ACKeychainUsername
//  ACKeychainPassword
//  ACKeychainIdentifier
//  ACKeychainService
//  ACKeychainExpirationDate
- (NSDictionary *)credentialsForIdentifier:(NSString *)identifier service:(NSString *)service;

// On success returns a dictionary with the following keys:
//  ACKeychainUsername
//  ACKeychainPassword
//  ACKeychainIdentifier
//  ACKeychainService
//  ACKeychainExpirationDate
- (NSDictionary *)credentialsForUsername:(NSString *)username service:(NSString *)service;

// On success returns an array of dictionaries with the following keys:
//  ACKeychainUsername
//  ACKeychainPassword
//  ACKeychainIdentifier
//  ACKeychainService
//  ACKeychainExpirationDate
//
// limit - the amount of entries to return. Should be > 0
- (NSArray *)allCredentialsForService:(NSString *)service limit:(NSUInteger)limit;

// Deletes credentials matching the provided identifier and service, returns YES on sucess
- (BOOL)deleteCredentialsForIdentifier:(NSString *)identifier service:(NSString *)service;

// Deletes credentials matching the provided username and service, returns YES on sucess
- (BOOL)deleteCredentialsForUsername:(NSString *)username service:(NSString *)service;

// Deletes all entries for the given service
- (BOOL)deleteAllCredentialsForService:(NSString *)service;

@end
