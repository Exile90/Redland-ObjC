//
//  SerializerTests.m
//  Redland Objective-C Bindings
//  $Id: SerializerTests.m 4 2004-09-25 15:49:17Z kianga $
//
//  Copyright 2004 Rene Puls <http://purl.org/net/kianga/>
//	Copyright 2012 Pascal Pfiffner <http://www.chip.org/>
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

#import <XCTest/XCTest.h>
#import "RedlandModel.h"
#import "RedlandURI.h"
#import "RedlandParser.h"
#import "RedlandSerializer.h"

static NSString *RDFXMLTestData = nil;
static NSString * const RDFXMLTestDataLocation = @"http://www.w3.org/1999/02/22-rdf-syntax-ns";

@interface SerializerTests : XCTestCase {
    RedlandModel *model;
    RedlandURI *uri;
}

@end

@implementation SerializerTests

- (BOOL)needsRunLoop
{
	return NO;
}

+ (void)initialize
{
    if (RDFXMLTestData == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:self];
        NSString *path = [bundle pathForResource:@"rdf-syntax" ofType:@"rdf"];
		NSStringEncoding usedEncoding = 0;
        RDFXMLTestData = [[NSString alloc] initWithContentsOfFile:path usedEncoding:&usedEncoding error:nil];
    }
}

- (void)setUp
{
	RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
	model = [RedlandModel new];
	uri = [RedlandURI URIWithString:RDFXMLTestDataLocation];
	[parser parseString:RDFXMLTestData intoModel:model withBaseURI:uri];
}

- (void)tearDown
{
	model = nil;
}

- (void)testToFile
{
    RedlandSerializer *serializer = [RedlandSerializer serializerWithName:RedlandRDFXMLSerializerName];
    NSString *tempFileName = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]; 
    BOOL isDir;
    
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:tempFileName]);
    XCTAssertNoThrow([serializer serializeModel:model toFileName:tempFileName withBaseURI:uri]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:tempFileName isDirectory:(BOOL *)&isDir]);
	NSStringEncoding usedEncoding = 0;
    XCTAssertTrue([(NSString *)[NSString stringWithContentsOfFile:tempFileName usedEncoding:&usedEncoding error:nil] length] > 0);
    if (!isDir) {
		[[NSFileManager defaultManager] removeItemAtPath:tempFileName error:nil];
	}
}

- (void)testInMemoryRoundTrip
{
    RedlandSerializer *serializer = [RedlandSerializer serializerWithName:RedlandRDFXMLSerializerName];
    RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
    NSData *data = nil;
    RedlandModel *newModel = [RedlandModel new];
    
    XCTAssertNoThrow(data = [serializer serializedDataFromModel:model withBaseURI:uri]);
    XCTAssertNotNil(data);
    XCTAssertTrue([data length] > 0);
    XCTAssertNoThrow([parser parseData:data intoModel:newModel withBaseURI:uri]);
    XCTAssertTrue([newModel size] > 0);
    XCTAssertEqual([model size], [newModel size]);
}

- (void)testConvenience
{
    NSData *data;
    
    XCTAssertNoThrow(data = [model serializedRDFXMLDataWithBaseURI:uri]);
    XCTAssertTrue([data length] > 0);
}

@end
