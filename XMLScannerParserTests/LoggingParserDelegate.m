//
// Created by Matthias Schmitt on 12/27/14.
// Copyright (c) 2014 Matthias Schmitt. All rights reserved.
//

#import "LoggingParserDelegate.h"


@implementation LoggingParserDelegate {
    NSMutableArray *_log;
    NSMutableArray *_info;
}

@synthesize log = _log;
@synthesize info = _info;

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    _log = [[NSMutableArray alloc] init];
    _info = [[NSMutableArray alloc] init];
    [_log addObject:@"StartDocument"];
    [_info addObject:[NSNull null]];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [_log addObject:@"EndDocument"];
    [_info addObject:[NSNull null]];
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict {
    [_log addObject:[NSString stringWithFormat:@"StartElement name=%@", elementName]];
    [_info addObject:[NSNull null]];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    [_log addObject:[NSString stringWithFormat:@"EndElement name=%@", elementName]];
    [_info addObject:[NSNull null]];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([_log.lastObject isEqualToString:@"Characters"]) {
        // NSXMLParser reports sub-strings. The first sub-string is delimited by a composable characters. The latter
        // sub-strings are reported as they fill up a buffer.
        [_info[_info.count - 1] = _info.lastObject stringByAppendingString:string];
        return;
    }
    [_log addObject:@"Characters"];
    [_info addObject:string];
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
    [_log addObject:@"IgnorableWhitespace"];
    [_info addObject:[NSNull null]];
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
    [_log addObject:@"Comment"];
    [_info addObject:[NSNull null]];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
    NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    [_log addObject:@"CDATA"];
    [_info addObject:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [_log addObject:@"Error"];
    [_info addObject:[NSNull null]];
}

@end
