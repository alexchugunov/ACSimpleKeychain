//
//  ACSimpleKeychain.m
//  ACSimpleKeychain
//
//  Created by Alex Chugunov on 2/3/11.
//  Copyright 2011 Alex Chugunov. All rights reserved.
//

#import "ACSimpleKeychain.h"

NSString const* ACKeychainPassword      = @"password";
NSString const* ACKeychainUsername      = @"username";
NSString const* ACKeychainIdentifier    = @"identifier";
NSString const* ACKeychainService       = @"service";

@interface ACSimpleKeychain (Private)

- (NSDictionary *)credentialsFromKeychainItem:(NSDictionary *)item;

@end

@implementation ACSimpleKeychain

+ (id)defaultKeychain {
    static ACSimpleKeychain *keychain;
    if (!keychain) {
        keychain = [[ACSimpleKeychain alloc] init];
    }
    return keychain;
}

- (NSDictionary *)credentialsFromKeychainItem:(NSDictionary *)item {
    NSString *username = [[NSString alloc] initWithData:[item valueForKey:(id)kSecAttrAccount]
                                               encoding:NSUTF8StringEncoding];
    NSString *password = [[NSString alloc] initWithData:[item valueForKey:(id)kSecValueData]
                                               encoding:NSUTF8StringEncoding];
    NSString *identifier = [[NSString alloc] initWithData:[item valueForKey:(id)kSecAttrGeneric]
                                                 encoding:NSUTF8StringEncoding];
    NSString *service = [[NSString alloc] initWithData:[item valueForKey:(id)kSecAttrService]
                                              encoding:NSUTF8StringEncoding];
    
    NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:
                                 username, ACKeychainUsername,
                                 password, ACKeychainPassword,
                                 identifier, ACKeychainIdentifier,
                                 service, ACKeychainService, nil];
    [username release];
    [password release];
    [identifier release];
    [service release];
    
    return credentials;
}

- (BOOL)storePassword:(NSString *)password username:(NSString *)username identifier:(NSString *)identifier forService:(NSString *)service
{
    if ([self deleteCredentialsForUsername:username service:service] &&
        [self deleteCredentialsForIdentifier:identifier service:service])
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           (id)kSecClassGenericPassword, (id)kSecClass,
                                           [password dataUsingEncoding:NSUTF8StringEncoding], (id)kSecValueData,
                                           [username dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                                           [identifier dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrGeneric,
                                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                                           nil];
        
        OSStatus status = SecItemAdd((CFDictionaryRef)dictionary, NULL);
        return (status == errSecSuccess);
    }
    return NO;
}

- (NSDictionary *)credentialsForIdentifier:(NSString *)identifier service:(NSString *)service {
    NSMutableDictionary *result = nil;
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (id)kSecClassGenericPassword, (id)kSecClass,
                                  [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                                  [identifier dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrGeneric,
                                  (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                                  (id)kCFBooleanTrue, (id)kSecReturnData,
                                  nil];
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
    
    if (status == errSecSuccess && result != nil) {
        NSDictionary *credentials = [self credentialsFromKeychainItem:result];
        [result release];
        return  credentials;
    }
    return nil;
}

- (NSDictionary *)credentialsForUsername:(NSString *)username service:(NSString *)service {
    NSMutableDictionary *result = nil;
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (id)kSecClassGenericPassword, (id)kSecClass,
                                  [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                                  [username dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                                  (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                                  (id)kCFBooleanTrue, (id)kSecReturnData,
                                  nil];
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
    
    if (status == errSecSuccess && result != nil) {
        NSDictionary *credentials = [self credentialsFromKeychainItem:result];
        [result release];
        return  credentials;
    }
    return nil;
}
                                     

- (NSArray *)allCredentialsForService:(NSString *)service limit:(NSUInteger)limit {
    NSMutableArray *list = nil;
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassGenericPassword, (id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                           (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                           (id)kCFBooleanTrue, (id)kSecReturnData,
                           [NSNumber numberWithInt:limit], (id)kSecMatchLimit,
                           nil];
    
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&list);
    if (status == errSecSuccess) {
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:[list count]];
        for (NSDictionary *item in list) {
            NSDictionary *credentials = [self credentialsFromKeychainItem:item];
            [result addObject:credentials];
        }
        [list release];
        return result;
    }
    
    return nil;
}

- (BOOL)deleteCredentialsForIdentifier:(NSString *)identifier service:(NSString *)service {
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (id)kSecClassGenericPassword, (id)kSecClass,
                                  [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                                  [identifier dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrGeneric,
                                  (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                                  (id)kCFBooleanTrue, (id)kSecReturnData,
                                  nil];
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}

- (BOOL)deleteCredentialsForUsername:(NSString *)username service:(NSString *)service {
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (id)kSecClassGenericPassword, (id)kSecClass,
                                  [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                                  [username dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                                  (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                                  (id)kCFBooleanTrue, (id)kSecReturnData,
                                  nil];
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}

- (BOOL)deleteAllCredentialsForService:(NSString *)service {
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (id)kSecClassGenericPassword, (id)kSecClass,
                                  [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                                  (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                                  (id)kCFBooleanTrue, (id)kSecReturnData,
                                  nil];
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}

@end
