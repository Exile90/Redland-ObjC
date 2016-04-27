//
//  RedlandError.h
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

#import <Foundation/Foundation.h>

extern NSString *const RedlandLibraryErrorDomain;       ///< The error domain of Redland C library errors
extern NSString *const RedlandWrapperErrorDomain;       ///< The error domain of Redland ObjC wrapper errors

typedef NS_ENUM(NSInteger, RedlandWrapperErrorCode) {
    RedlandWrapperErrorCodeGeneric = 1,
    RedlandWrapperErrorCodeCumulative
};

/**
 *  NSError convenience category.
 */
@interface NSError (RedlandError)

+ (NSError *)redlandLibraryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)description;
+ (NSError *)redlandLibraryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)description userInfo:(NSDictionary *)userInfo;

+ (NSError *)redlandWrapperErrorWithCode:(RedlandWrapperErrorCode)code localizedDescription:(NSString *)description;
+ (NSError *)redlandWrapperErrorWithCode:(RedlandWrapperErrorCode)code localizedDescription:(NSString *)description userInfo:(NSDictionary *)userInfo;

@end
