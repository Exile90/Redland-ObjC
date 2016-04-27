//
//  QueryTests.m
//  Redland Objective-C Bindings
//  $Id: QueryTests.m 4 2004-09-25 15:49:17Z kianga $
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
#import "RedlandQuery.h"
#import "RedlandQueryResults.h"
#import "RedlandQueryResultsEnumerator.h"
#import "RedlandParser.h"
#import "RedlandError.h"
#import "RedlandURI.h"

static NSString *RDFXMLTestData = nil;
static NSString * const RDFXMLTestDataLocation = @"http://www.w3.org/1999/02/22-rdf-syntax-ns";

@interface QueryTests : XCTestCase {
    RedlandModel *model;
    RedlandURI *uri;
}

@end

@implementation QueryTests

+ (void)setUp
{
    if (RDFXMLTestData == nil) {
        NSBundle *bundle = [NSBundle bundleForClass:self];
        NSString *path = [bundle pathForResource:@"rdf-syntax" ofType:@"rdf"];
		NSStringEncoding usedEncoding = 0;
        RDFXMLTestData = [[NSString alloc] initWithContentsOfFile:path usedEncoding:&usedEncoding error:NULL];
		NSAssert(RDFXMLTestData != nil, @"Could not load RDFXML test data");
    }
}

- (void)setUp
{
	RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
	model = [RedlandModel new];
	uri = [RedlandURI URIWithString:RDFXMLTestDataLocation];
	[parser parseString:RDFXMLTestData intoModel:model withBaseURI:uri error:NULL];
	NSAssert([model size] > 0, @"Test model is empty");
}

- (void)tearDown
{
	model = nil;
}

- (void)testBadQuery
{
    NSError *__autoreleasing error;
	NSString *queryString = @"This is not a valid query.";
	RedlandQuery *query = [RedlandQuery queryWithLanguageName:RedlandSPARQLLanguageName queryString:queryString baseURI:nil error:NULL];
    
    XCTAssertFalse([query executeOnModel:model error:&error]);
    XCTAssertTrue([error.domain isEqualToString:RedlandWrapperErrorDomain]);
}

- (void)testQueryAll
{
    NSString *queryString;
    RedlandQuery *query;
    RedlandQueryResults *results;
    NSArray *allResults;
    
	XCTAssertTrue([model size] > 0);
	
    queryString = @"SELECT ?s ?p ?o WHERE { ?s ?p ?o }";
    query = [RedlandQuery queryWithLanguageName:RedlandSPARQLLanguageName queryString:queryString baseURI:nil error:NULL];
    XCTAssertNotNil(query);
    results = [query executeOnModel:model error:NULL];
    XCTAssertNotNil(results);
	if (results != nil) {
		XCTAssertEqual(3, [results countOfBindings]);
		XCTAssertNoThrow(allResults = [[results resultEnumerator] allObjects]);
		XCTAssertEqual((unsigned)[model size], (unsigned)[allResults count]);
	}
}

- (void)testSimpleQuery
{
    NSString *queryString;
    RedlandQuery *query;
    RedlandQueryResults *results;
    NSArray *allResults;
    
	XCTAssertTrue([model size] > 0);
	
    queryString = @"SELECT ?s ?o WHERE { ?s a ?o }";
    query = [RedlandQuery queryWithLanguageName:RedlandSPARQLLanguageName queryString:queryString baseURI:nil error:NULL];
    XCTAssertNotNil(query);
    results = [query executeOnModel:model error:NULL];
    XCTAssertNotNil(results);
	if (results != nil) {
		XCTAssertEqual(2, [results countOfBindings]);
		XCTAssertNoThrow(allResults = [[results resultEnumerator] allObjects]);
		XCTAssertTrue([allResults count] > 0);
	}
}


@end
