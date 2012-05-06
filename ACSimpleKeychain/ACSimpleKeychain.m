//
//  ACSimpleKeychain.m
//  ACSimpleKeychain
//
//  Created by Alex Chugunov on 2/3/11.
//  Copyright 2011 Alex Chugunov. All rights reserved.
//

#import "ACSimpleKeychain.h"

NSString *const ACKeychainPassword      = @"password";
NSString *const ACKeychainUsername      = @"username";
NSString *const ACKeychainIdentifier    = @"identifier";
NSString *const ACKeychainService       = @"service";

@interface ACSimpleKeychain (Private)

- (NSDictionary *)credentialsFromKeychainItem:(NSDictionary *)item;

@end

@implementation ACSimpleKeychain

+ (id)defaultKeychain
{
    static ACSimpleKeychain *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (NSDictionary *)credentialsForQuery:(NSDictionary *)query
{
    CFDictionaryRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *) &result);
    if (status == errSecSuccess && result != NULL) {
        NSDictionary *credentials = [self credentialsFromKeychainItem:(__bridge_transfer NSDictionary *) result];
        return  credentials;
    }
    return nil;
}

- (NSDictionary *)credentialsFromKeychainItem:(NSDictionary *)item
{
    NSString *username = [[NSString alloc] initWithData:[item valueForKey:(__bridge id)kSecAttrAccount]
                                               encoding:NSUTF8StringEncoding];
    NSString *password = [[NSString alloc] initWithData:[item valueForKey:(__bridge id)kSecValueData]
                                               encoding:NSUTF8StringEncoding];
    NSString *identifier = [[NSString alloc] initWithData:[item valueForKey:(__bridge id)kSecAttrGeneric]
                                                 encoding:NSUTF8StringEncoding];
    NSString *service = [[NSString alloc] initWithData:[item valueForKey:(__bridge id)kSecAttrService]
                                              encoding:NSUTF8StringEncoding];
    
    NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:
                                 username, ACKeychainUsername,
                                 password, ACKeychainPassword,
                                 identifier, ACKeychainIdentifier,
                                 service, ACKeychainService, nil];

    return credentials;
}

- (BOOL)storePassword:(NSString *)password username:(NSString *)username identifier:(NSString *)identifier forService:(NSString *)service
{
    if ([self deleteCredentialsForUsername:username service:service] &&
        [self deleteCredentialsForIdentifier:identifier service:service])
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                                           [password dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecValueData,
                                           [username dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrAccount,
                                           [identifier dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrGeneric,
                                           [service dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrService,
                                           nil];
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
        return (status == errSecSuccess);
    }
    return NO;
}

- (NSDictionary *)credentialsForIdentifier:(NSString *)identifier service:(NSString *)service
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrService,
                           [identifier dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrGeneric,
                           (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnAttributes,
                           (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnData,
                           nil];
    return [self credentialsForQuery:query];    
}

- (NSDictionary *)credentialsForUsername:(NSString *)username service:(NSString *)service
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrService,
                           [username dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrAccount,
                           (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnAttributes,
                           (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnData,
                           nil];
    return [self credentialsForQuery:query];    
}
                                     

- (NSArray *)allCredentialsForService:(NSString *)service limit:(NSUInteger)limit
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrService,
                           (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnAttributes,
                           [NSNumber numberWithInt:limit], (__bridge id)kSecMatchLimit,
                           (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnData,
                           nil];
    
    CFArrayRef list = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *) &list);
    if (status == errSecSuccess && list != NULL) {
        NSMutableArray *result = [NSMutableArray array];
        for (NSDictionary *item in (__bridge_transfer NSArray *)list) {
            NSDictionary *credentials = [self credentialsFromKeychainItem:item];
            [result addObject:credentials];
        }
        return result;        
    }
    return nil;
}

- (BOOL)deleteCredentialsForIdentifier:(NSString *)identifier service:(NSString *)service
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                                  (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                                  [service dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrService,
                                  [identifier dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrGeneric,
                                  nil];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}

- (BOOL)deleteCredentialsForUsername:(NSString *)username service:(NSString *)service
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrService,
                           [username dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrAccount,
                           nil];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}

- (BOOL)deleteAllCredentialsForService:(NSString *)service
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (__bridge id)kSecAttrService,
                           (__bridge id)kCFBooleanTrue, (__bridge id)kSecReturnAttributes,
                           nil];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}

@end
