//
//  RedlandError.m
//  Redland Objective-C Bindings
//
//  Copyright 2016 Ivano Bilenchi <http://ivanobilenchi.com/>
//
//  This file is available under the following three licenses:
//   1. GNU Lesser General Public License (LGPL), version 2.1
//   2. GNU General Public License (GPL), version 2
//   3. Apache License, version 2.0
//
//  You may not use this file except in compliance with at least one of
//  the above three licenses. See LICENSE.txt at the top of this package
//  for the complete terms and further details.
//
//  The most recent version of this software can be found here:
//  <https://github.com/p2/Redland-ObjC>
//
//  For information about the Redland RDF Application Framework, including
//  the most recent version, see <http://librdf.org/>.
//

#import "RedlandError.h"

NSString *const RedlandLibraryErrorDomain = @"org.librdf.error";
NSString *const RedlandWrapperErrorDomain = @"com.ivanobilenchi.redland-objc.error";

@implementation NSError (RedlandError)

#pragma mark Public

+ (NSError *)redlandLibraryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)description
{
    return [self redlandLibraryErrorWithCode:code localizedDescription:description userInfo:nil];
}

+ (NSError *)redlandLibraryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)description userInfo:(NSDictionary *)userInfo
{
    return [[self class] _redlandErrorWithDomain:RedlandLibraryErrorDomain
                                            code:code
                            localizedDescription:description
                                        userInfo:userInfo];
}

+ (NSError *)redlandWrapperErrorWithCode:(RedlandWrapperErrorCode)code localizedDescription:(NSString *)description
{
    return [[self class] redlandWrapperErrorWithCode:code localizedDescription:description userInfo:nil];
}

+ (NSError *)redlandWrapperErrorWithCode:(RedlandWrapperErrorCode)code localizedDescription:(NSString *)description userInfo:(NSDictionary *)userInfo
{
    return [self _redlandErrorWithDomain:RedlandWrapperErrorDomain
                                    code:code
                    localizedDescription:description
                                userInfo:userInfo];
}

#pragma mark Private

+ (NSError *)_redlandErrorWithDomain:(NSString *)domain
                                code:(NSInteger)code
                localizedDescription:(NSString *)description
                            userInfo:(NSDictionary *)userInfo
{
    NSMutableDictionary *localUserInfo = nil;
    
    if (description || userInfo) {
        localUserInfo = userInfo ? [userInfo mutableCopy] : [[NSMutableDictionary alloc] init];
        
        if (description) {
            [localUserInfo setObject:description forKey:NSLocalizedDescriptionKey];
        }
    }
    
    return [[NSError alloc] initWithDomain:domain code:code userInfo:localUserInfo];
}

@end
