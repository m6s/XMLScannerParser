//
//  Created by Matthias Schmitt on 1/11/15.
//  Copyright (c) 2015 Matthias Schmitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LoggingParserDelegate.h"
#import "MATXMLParser.h"

@interface XMLScannerParserTests : XCTestCase

@end

@implementation XMLScannerParserTests
+ (void)setUp {
    [super setUp];
    // Put setup code here. This method is called one time only, before the invocation of any test method in the class.
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testShouldParseDocument {
    [self _testShouldParseResource:@"document" withExtension:@"xml"];
}

- (void)testShouldParseDocumentWithEndOfFileCharacters {
    [self _testShouldParseResource:@"document-eof-chars" withExtension:@"xml"];
}

- (void)testShouldParseCharactersAfterElement {
    [self _testShouldParseResource:@"chars-after-element" withExtension:@"xml"];
}

- (void)testShouldParseCData {
    [self _testShouldParseResource:@"cdata" withExtension:@"xml"];
}

- (void)testShouldParseForeignChars {
    [self _testShouldParseResource:@"foreign-chars" withExtension:@"xml"];
}

- (void)testShouldParseChannels {
    [self _testShouldParseResource:@"channels" withExtension:@"xml"];
}

- (void)testShouldParseThreeSat {
    [self _testShouldParseResource:@"3sat.de_2014-07-10" withExtension:@"xml"];
}

- (void)testShouldParseDatalist {
    [self _testShouldParseResource:@"datalist" withExtension:@"xml"];
}

- (void)testShouldParseWikiTV {
    [self _testShouldParseResource:@"tv" withExtension:@"xml"];
}

- (void)testParserError {
    MATXMLParser
            *xmlParser = [[MATXMLParser alloc] initWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertNil(xmlParser.parserError);
}

- (void)_testShouldParseResource:(NSString *)name withExtension:(NSString *)extension {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [testBundle URLForResource:name withExtension:extension];
    NSData *data = [NSData dataWithContentsOfURL:url];
    LoggingParserDelegate *loggingDelegate = [[LoggingParserDelegate alloc] init];
    NSXMLParser *nsParser = [[NSXMLParser alloc] initWithData:data];
    nsParser.delegate = loggingDelegate;
    [nsParser parse];
    NSArray *nsLog = loggingDelegate.log;
    MATXMLParser *maxmlParser = [[MATXMLParser alloc] initWithData:data];
    maxmlParser.delegate = loggingDelegate;
    [maxmlParser parse];
    NSArray *maxmlLog = loggingDelegate.log;
    XCTAssertEqual(nsLog.count, maxmlLog.count, @"Pass");
    if (nsLog.count != maxmlLog.count) {
        return;
    }
    for (int i = 0; i < nsLog.count; ++i) {
        XCTAssertEqualObjects(maxmlLog[i], nsLog[i], @"%d", i);
    }
}
@end
