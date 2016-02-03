//
//  NamespaceTests.m
//  Redland Objective-C Bindings
//  $Id: NamespaceTests.m 4 2004-09-25 15:49:17Z kianga $
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
#import "RedlandNamespace.h"
#import "RedlandURI.h"
#import "RedlandWorld.h"

@interface NamespaceTests : XCTestCase @end

@implementation NamespaceTests

- (void)testPredefined
{
	[RedlandWorld defaultWorld];	// make sure that global instances are initialized
    XCTAssertNotNil(XMLSchemaNS);
	XCTAssertNotNil(RDFSyntaxNS);
	XCTAssertNotNil(RDFSchemaNS);
	XCTAssertNotNil(DublinCoreNS);
}

- (void)testURI
{
    RedlandNamespace *schemaNS = [[RedlandNamespace alloc] initWithPrefix:@"http://www.w3.org/2001/XMLSchema#"
																shortName:@"xmlschema"];
    RedlandURI *uri = [RedlandURI URIWithString:@"http://www.w3.org/2001/XMLSchema#int"];
    XCTAssertEqualObjects(uri, [schemaNS URI:@"int"]);
}

- (void)testRegistration
{
	[RedlandWorld defaultWorld];	// make sure that global instances are initialized
	XCTAssertNoThrow([RDFSyntaxNS registerInstance]);
	XCTAssertThrows([RDFSyntaxNS registerInstance]);
	XCTAssertEqual(RDFSyntaxNS, [RedlandNamespace namespaceWithShortName:@"rdf"]);
	[RDFSyntaxNS unregisterInstance];
	XCTAssertNil([RedlandNamespace namespaceWithShortName:@"rdf"]);
}

- (void)testAutoUnregister
{
	RedlandNamespace *schemaNS = [[RedlandNamespace alloc] initWithPrefix:@"http://www.w3.org/2001/XMLSchema#"
																shortName:@"xmlschema"];
	[schemaNS registerInstance];
	schemaNS = nil;					// will dealloc the instance
	
	XCTAssertNil([RedlandNamespace namespaceWithShortName:@"xmlschema"]);
}

@end
