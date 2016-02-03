//
//  ModelTests.m
//  Redland Objective-C Bindings
//  $Id: ModelTests.m 4 2004-09-25 15:49:17Z kianga $
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
#import "RedlandModel-Convenience.h"
#import "RedlandNode-Convenience.h"
#import "RedlandStatement.h"
#import "RedlandStreamEnumerator.h"

@interface ModelTests : XCTestCase @end

@implementation ModelTests

- (void)testSimple
{
    RedlandNode *subject = [RedlandNode nodeWithBlankID:@"foo"];
    RedlandNode *predicate = [RedlandNode nodeWithURIString:@"foo:bar"];
    RedlandNode *object = [RedlandNode nodeWithLiteral:@"test"];
    RedlandNode *object2 = [RedlandNode nodeWithLiteral:@"another test"];
    
    RedlandModel *model = [RedlandModel new];
    XCTAssertNotNil(model);
    
    RedlandStatement *testStatement = [RedlandStatement statementWithSubject:subject
																   predicate:predicate
																	  object:object];
	RedlandStatement *secondStatement = [RedlandStatement statementWithSubject:subject
																	 predicate:predicate
																		object:object2];
	RedlandStatement *likeStatement = [RedlandStatement statementWithSubject:subject
																   predicate:predicate
																	  object:nil];

    XCTAssertNoThrow([model addStatement:testStatement]);
    XCTAssertEqual(1, [model size]);
    XCTAssertTrue([model containsStatement:testStatement]);
    XCTAssertEqualObjects(subject, [model sourceWithArc:predicate target:object]);
    XCTAssertEqualObjects(predicate, [model arcWithSource:subject target:object]);
    XCTAssertEqualObjects(object, [model targetWithSource:subject arc:predicate]);
    XCTAssertTrue([model node:object hasIncomingArc:predicate]);
    XCTAssertTrue([model node:subject hasOutgoingArc:predicate]);
    XCTAssertNoThrow([model removeStatement:testStatement]);
    XCTAssertFalse([model containsStatement:testStatement]);
	
	XCTAssertNoThrow([model addStatement:testStatement]);
	XCTAssertNoThrow([model addStatement:secondStatement]);
    XCTAssertEqual(2, [model size]);
	XCTAssertNoThrow([model removeStatementsLike:likeStatement]);
    XCTAssertEqual(0, [model size]);
}

- (void)testSubmodel
{
	RedlandNode *content = [RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#Content"];
	
	RedlandStatement *main = [RedlandStatement statementWithSubject:[RedlandNode nodeWithBlankID:@"foo"]
														  predicate:[RedlandNode typeNode]
															 object:content];
	RedlandStatement *sub1 = [RedlandStatement statementWithSubject:content
														  predicate:[RedlandNode nodeWithURIString:@"http://smartplatforms.org/terms#encoding"]
															 object:[RedlandNode nodeWithLiteral:@"UTF-8"]];
	RedlandStatement *sub2 = [RedlandStatement statementWithSubject:content
														  predicate:[RedlandNode nodeWithURIString:@"http://purl.org/dc/terms/date"]
															 object:[RedlandNode nodeWithLiteral:@"2013-06-12"]];
	
	// create the model
	RedlandModel *model = [RedlandModel new];
	XCTAssertNoThrow([model addStatement:main]);
	XCTAssertNoThrow([model addStatement:sub1]);
	XCTAssertNoThrow([model addStatement:sub2]);
    XCTAssertEqual(3, [model size]);
	
	RedlandModel *submodel = [model submodelForSubject:content];
	XCTAssertEqual(2, [submodel size]);
	for (RedlandStatement *statement in [submodel statementEnumerator]) {
		XCTAssertTrue([model containsStatement:statement]);
	}
	
	// removing and re-adding
	XCTAssertTrue([model removeSubmodel:submodel]);
	XCTAssertEqual(1, [model size]);
	
	XCTAssertTrue([model addSubmodel:submodel]);
	XCTAssertEqual(3, [model size]);
}

- (void)testContextAddStatementBug
{
    RedlandNode *subject = [RedlandNode nodeWithBlankID:@"foo"];
    RedlandNode *predicate = [RedlandNode nodeWithURIString:@"foo:bar"];
    RedlandNode *object = [RedlandNode nodeWithLiteral:@"test"];
	RedlandStatement *statement;

	RedlandModel *model = [RedlandModel new];
    statement = [RedlandStatement statementWithSubject:subject
											 predicate:predicate
												object:object];
	XCTAssertNoThrow([model addStatement:statement withContext:nil]);
}


@end
