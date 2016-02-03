//
//  NodeTests.m
//  Redland Objective-C Bindings
//  $Id: NodeTests.m 4 2004-09-25 15:49:17Z kianga $
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
#import "RedlandNode.h"
#import "RedlandNode-Convenience.h"
#import "RedlandURI.h"
#import "RedlandException.h"

@interface NodeTests : XCTestCase @end

@implementation NodeTests

- (void)testLiteral
{
	NSString *string = @"Hello world";
	NSString *language = @"en";
	RedlandURI *typeURI = [RedlandURI URIWithString:@"http://foo/"];
	
	RedlandNode *nodeWithType = [RedlandNode nodeWithLiteral:string language:language type:typeURI];
	RedlandNode *nodeWithLang = [RedlandNode nodeWithLiteral:string language:language type:nil];
	XCTAssertNotNil(nodeWithType);
	XCTAssertNotNil(nodeWithLang);
	XCTAssertTrue([nodeWithType isLiteral]);
	XCTAssertTrue([nodeWithLang isLiteral]);
	XCTAssertEqualObjects(string, [nodeWithType literalValue]);
	XCTAssertEqualObjects(string, [nodeWithLang literalValue]);
	XCTAssertEqualObjects(nil, [nodeWithType literalLanguage]);				// language can only be set if type is nil
	XCTAssertEqualObjects(language, [nodeWithLang literalLanguage]);		// language is now set
	XCTAssertEqualObjects(typeURI, [nodeWithType literalDataType]);
	XCTAssertFalse([nodeWithType isXML]);
}

- (void)testLiteralXML
{
	NSString *string = @"<hello>world</hello>";
	NSString *language = @"en";
	
	RedlandNode *nodeXML = [RedlandNode nodeWithLiteral:string language:language isXML:YES];
	RedlandNode *nodeNot = [RedlandNode nodeWithLiteral:string language:language isXML:NO];
	XCTAssertNotNil(nodeXML);
	XCTAssertNotNil(nodeNot);
	XCTAssertTrue([nodeXML isLiteral]);
	XCTAssertTrue([nodeNot isLiteral]);
	XCTAssertEqualObjects(string, [nodeXML literalValue]);
	XCTAssertEqualObjects(string, [nodeNot literalValue]);
	XCTAssertEqualObjects(nil, [nodeXML literalLanguage]);				// language can only be set if the node is NOT XML
	XCTAssertEqualObjects(language, [nodeNot literalLanguage]);			// language is now set
	XCTAssertTrue([nodeXML isXML]);
	XCTAssertFalse([nodeNot isXML]);
}

- (void)testBlank
{
	NSString *string = @"myBlankId";
	
	RedlandNode *node = [RedlandNode nodeWithBlankID:string];
	XCTAssertNotNil(node);
	XCTAssertTrue([node isBlank]);
	XCTAssertEqualObjects(string, [node blankID]);
}

- (void)testBlankRandom
{
	RedlandNode *node1 = [RedlandNode nodeWithBlankID:nil];
	XCTAssertNotNil(node1);
	RedlandNode *node2 = [RedlandNode nodeWithBlankID:nil];
	XCTAssertNotNil(node2);
	XCTAssertFalse([node1 isEqual:node2]);
}

- (void)testResource
{
	RedlandURI *uri = [RedlandURI URIWithString:@"http://foo.com/"];
	
	RedlandNode *node = [RedlandNode nodeWithURI:uri];
	XCTAssertNotNil(node);
	XCTAssertTrue([node isResource]);
	XCTAssertEqualObjects(uri, [node URIValue]);
}

- (void)testNodeEquality
{
	NSString *url1 = @"http://foo.com/";
	NSString *url2 = @"http://foo.com/#bar";
	NSString *url3 = @"http://foo.com/";
	
	RedlandNode *node1 = [RedlandNode nodeWithURIString:url1];
	RedlandNode *node2 = [RedlandNode nodeWithURIString:url2];
	RedlandNode *node3 = [RedlandNode nodeWithURIString:url3];
	XCTAssertFalse([node1 isEqual:node2]);
	XCTAssertEqualObjects(node1, node3);
}

- (void)testLiteralInt
{
	RedlandNode *node = [RedlandNode nodeWithLiteralInt:12345];
	XCTAssertEqual(12345, [node intValue]);
	
	node = [RedlandNode nodeWithLiteral:@"12345" language:nil isXML:NO];
	XCTAssertThrowsSpecific([node intValue], RedlandException);
}

- (void)testLiteralString
{
	NSString *string = @"Hello world";
	
	RedlandNode *node = [RedlandNode nodeWithLiteralString:string language:@"en"];
	XCTAssertNotNil(node);
	XCTAssertEqualObjects(string, [node stringValue]);
	
	node = [RedlandNode nodeWithLiteral:string language:@"en" isXML:NO];
	XCTAssertThrowsSpecific([node stringValue], RedlandException);
}

- (void)testLiteralBool
{
	RedlandNode *node = [RedlandNode nodeWithLiteralBool:TRUE];
	XCTAssertTrue([node boolValue]);
	
	node = [RedlandNode nodeWithLiteral:@"true" language:@"en" isXML:NO];
	XCTAssertThrowsSpecific([node boolValue], RedlandException);
}

- (void)testLiteralFloatDouble
{
	RedlandNode *floatNode = [RedlandNode nodeWithLiteralFloat:(float)M_PI];
	RedlandNode *doubleNode = [RedlandNode nodeWithLiteralDouble:(double)M_PI];
	
	XCTAssertEqualWithAccuracy((float)M_PI, [floatNode floatValue], 0.000001);
	XCTAssertEqualWithAccuracy((double)M_PI, [floatNode doubleValue], 0.000001);
	XCTAssertThrowsSpecific([doubleNode floatValue], RedlandException);
	XCTAssertEqualWithAccuracy((double)M_PI, [doubleNode doubleValue], 0.0000000000001);
}

- (void)testLiteralDateTime
{
	NSDate *date = [NSDate date];
	
	RedlandNode *node = [RedlandNode nodeWithLiteralDateTime:date];
	XCTAssertNotNil(node);
	XCTAssertEqualWithAccuracy((float)0.0f, (float)[date timeIntervalSinceDate:[node dateTimeValue]], 1.0f);
	
	node = [RedlandNode nodeWithLiteralString:@"2004-09-16T20:36:18Z" language:nil];
	XCTAssertThrowsSpecific([node dateTimeValue], RedlandException);
}

- (void)testArchiving
{
	RedlandNode *sourceNode = [RedlandNode nodeWithLiteralString:@"Hello world" language:@"en"];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sourceNode];
	XCTAssertNotNil(data);
	RedlandNode *decodedNode = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	XCTAssertNotNil(decodedNode);
	XCTAssertEqualObjects(sourceNode, decodedNode);
}

- (void)testNodeValueConversion
{
	// The following test won't work because there seems to be no way to
	// distinguish a boolean NSNumber from an int NSNumber...
	//    UKObjectsEqual([RedlandNode nodeWithLiteralBool:YES],
	//                   [RedlandNode nodeWithObject:[NSNumber numberWithBool:YES]]);
	XCTAssertEqualObjects([RedlandNode nodeWithLiteralInt:12345], [RedlandNode nodeWithObject:[NSNumber numberWithInt:12345]]);
	XCTAssertEqualObjects([RedlandNode nodeWithLiteralFloat:1.2345f], [RedlandNode nodeWithObject:[NSNumber numberWithFloat:1.2345f]]);
	XCTAssertEqualObjects([RedlandNode nodeWithLiteralDouble:12.3456790], [RedlandNode nodeWithObject:[NSNumber numberWithDouble:12.3456790]]);
	XCTAssertEqualObjects([RedlandNode nodeWithLiteralString:@"foo" language:nil], [RedlandNode nodeWithObject:@"foo"]);
	XCTAssertEqualObjects([RedlandNode nodeWithURL:[NSURL URLWithString:@"http://foo"]], [RedlandNode nodeWithObject:[NSURL URLWithString:@"http://foo"]]);
	XCTAssertEqualObjects([RedlandNode nodeWithLiteralDateTime:[NSDate dateWithTimeIntervalSinceReferenceDate:0]], [RedlandNode nodeWithObject:[NSDate dateWithTimeIntervalSinceReferenceDate:0]]);
}

@end
