//
// Created by Matthias Schmitt on 12/27/14.
// Copyright (c) 2014 Matthias Schmitt. All rights reserved.
//

#import "MATXMLParser.h"

static NSCharacterSet *LTSet;
static NSCharacterSet *GTSet;
static NSCharacterSet *QuotSet;
static NSCharacterSet *EQSet;
static NSCharacterSet *WhitespaceAndNewlineSet;

@implementation NSMutableString (XMLEncoding)
- (NSString *)removeXMLEscapes {
    [self replaceOccurrencesOfString:@"&amp;"
                          withString:@"&"
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&quot;"
                          withString:@"\""
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&#x27;"
                          withString:@"'"
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&#x39;"
                          withString:@"'"
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&#x92;"
                          withString:@"'"
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&#x96;"
                          withString:@"'"
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&gt;"
                          withString:@">"
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [self length])];
    [self replaceOccurrencesOfString:@"&lt;"
                          withString:@"<"
                             options:NSLiteralSearch
                               range:NSMakeRange(0, [self length])];
    return self;
}

@end


@implementation NSString (XMLEncoding)
- (NSString *)stringByRemovingXMLEscapes {
    return [[self mutableCopy] removeXMLEscapes];
}
@end

NSString *const NSXMLParserErrorColumn = @"NSXMLParserErrorColumn";
NSString *const NSXMLParserErrorLineNumber = @"NSXMLParserErrorLineNumber";
NSString *const NSXMLParserErrorMessage = @"NSXMLParserErrorMessage";

/**
* # XMLScannerParser XML parser for Cocoa
*
* MATXMLScannerParser* is a drop-in replacement for *NSXMLParser*. The implementation is based on *NSScanner*. It doesn't support namespaces, perform validation nor check for wellformedness of XML documents.
*
* ## Motivation
*
* I created XMLScannerParser when I encountered bugs in the original NSXMLParser. I hope that Apple will eventually fix these bugs, and that I can then switch to their parser implementation again. It can also help you finding out why a particular XML file won't parse, since it's light-weight and easy to understand and debug.
*
* ## Design
*
* XMLScannerParser doesn't depend on any external framework. It has the same event based interface as NSXMLParser, is implemented in pure Objective C, and fits into two source files (plus headers). This is a naive implementation in that it doesn't employ any established parsing or tokenizing algorithms. For someone to tweak it to his/her specific needs, only some Foundation Kit experience should be necessary.
* Beware, I haven't read the XML, let alone the SGML specs, and XMLScannerParser will only work with the most basic XML input.
*
* ## Alternatives
*
* The original NSXMLParser is a thin object oriented wrapper around *libxml2*, and I suspect libxml2 shares some of its bugs. Nevertheless, using libxml2 directly is an option.
* Next, there is [TBXML](https://github.com/71squared/TBXML), which is supposedly very fast, [TinyXML-2](http://www.grinninglizard.com/tinyxml2/), a parser implemented in C++, TouchXML, KissXML, GDataXML. All of these parsers provide a DOM interface for working with the XML data. I haven't found out if anybody successfully compiled and integrated *Xerces* into their app.
*
* ## Installation
*
* The parser consists of four files only. Simply drop these files into you project.
*
* It is also available through CocoaPods. To install it add the following line to your Podfile:
*
* ```
* pod 'XMLScannerParser', :git => 'https://github.com/m6s/XMLScannerParser.git'
* ```
*
* ## License
*
* Copyright (C) 2015 Matthias Schmitt. XMLScannerParser is released under the MIT license.
*
*/
@implementation MATXMLParser {
    BOOL _parsing;
    NSString *_string;
    BOOL _abortParsing;
    NSMutableArray *_elementNameStack;
    NSScanner *_scanner;
    NSUInteger _scanLocationOffset;
}
@synthesize parserError = _parserError;
@synthesize delegate = _scanningParserDelegate;

+ (void)initialize {
    [super initialize];
    LTSet = [NSCharacterSet characterSetWithCharactersInString:@"<"];
    GTSet = [NSCharacterSet characterSetWithCharactersInString:@">"];
    QuotSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    WhitespaceAndNewlineSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    EQSet = [NSCharacterSet characterSetWithCharactersInString:@"="];
}

#pragma mark - Creation

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    return NULL;
}

- (instancetype)initWithData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [self initWithString:string];
}

- (instancetype)initWithStream:(NSInputStream *)stream {
    return NULL;
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        _string = string;
        _elementNameStack = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Public Interface

- (BOOL)parse {
    if (_parsing) {
        [NSException raise:NSGenericException format:@"MATXMLParser is not reentrant"];
    }
    _parsing = YES;
    _abortParsing = NO;
    _scanner = [NSScanner scannerWithString:_string];
    _scanner.charactersToBeSkipped = nil;
    [self didStartDocument];
    // skip the <?xml version="1.0" encoding="utf-8"?>
    [_scanner scanUpToString:@"?>" intoString:nil];
    [_scanner scanUpToCharactersFromSet:LTSet intoString:nil];
    while (YES) {
        // the scanner currently starts just after the last tag end or xml declaration end
        // find tag start
        NSString *content = nil;
        [_scanner scanUpToCharactersFromSet:LTSet intoString:&content];
        if (content) {
            [self parseEscapedCharacters:content];
        }
        if (_scanner.atEnd) {
            break;
        }
        [_scanner scanCharactersFromSet:LTSet intoString:nil];

        if (_scanner.string.length - _scanner.scanLocation >= 11 &&
                [[_scanner.string substringWithRange:NSMakeRange(_scanner.scanLocation, 8)]
                        isEqualToString:@"![CDATA["]) {
            // find CDATA end
            [_scanner scanString:@"![CDATA[" intoString:nil];
            NSString *cdata = nil;
            [_scanner scanUpToString:@"]]" intoString:&cdata];
            if (cdata) {
                [self parseCDATA:cdata];
                if (_abortParsing) {
                    break;
                }
            }
            [_scanner scanString:@"]]>" intoString:nil];
        } else if (_scanner.string.length - _scanner.scanLocation >= 6 &&
                [[_scanner.string substringWithRange:NSMakeRange(_scanner.scanLocation, 3)] isEqualToString:@"!--"]) {
            // find comment end
            [_scanner scanString:@"!--" intoString:nil];
            NSString *comment = nil;
            [_scanner scanUpToString:@"--" intoString:&comment];
            if (comment) {
                [self parseEscapedComment:comment];
                if (_abortParsing) {
                    break;
                }
            }
            [_scanner scanString:@"-->" intoString:nil];
        } else if (_scanner.string.length - _scanner.scanLocation >= 9 &&
                [[_scanner.string substringWithRange:NSMakeRange(_scanner.scanLocation, 8)]
                        isEqualToString:@"!DOCTYPE"]) {
            // find DOCTYPE end
            [_scanner scanString:@"!DOCTYPE" intoString:nil];
            [_scanner scanUpToCharactersFromSet:GTSet intoString:nil]; //ignored
            [_scanner scanCharactersFromSet:GTSet intoString:nil];
        } else if (_scanner.string.length - _scanner.scanLocation >= 8 &&
                [[_scanner.string substringWithRange:NSMakeRange(_scanner.scanLocation, 7)]
                        isEqualToString:@"!ENTITY"]) {
            // find ENTITY end
            [_scanner scanString:@"!ENTITY" intoString:nil];
            [_scanner scanUpToCharactersFromSet:GTSet intoString:nil]; //ignored
            [_scanner scanCharactersFromSet:GTSet intoString:nil];
        } else {
            // find tag end
            NSString *tag = nil;
            [_scanner scanUpToCharactersFromSet:GTSet intoString:&tag];
            if (tag) {
                [self parseTag:tag];
                if (_abortParsing) {
                    break;
                }
            }
            [_scanner scanCharactersFromSet:GTSet intoString:nil];
        }
        if (_scanner.atEnd) {
            break;
        }
    }
    BOOL success = !_abortParsing && !self.parserError;
    if (success) {
        [self didEndDocument];
    } else {
        _parserError = [NSError errorWithDomain:NSXMLParserErrorDomain code:0 userInfo:nil];
    }
    _parsing = NO;
    return success;
}

- (void)abortParsing {
    _abortParsing = YES;
}

- (id <NSXMLParserDelegate>)delegate {
    return _scanningParserDelegate;
}

- (void)setDelegate:(id <NSXMLParserDelegate>)delegate {
    _scanningParserDelegate = delegate;
}

- (NSInteger)lineNumber {
    return _scanner.scanLocation + _scanLocationOffset;
}

#pragma - Helpers

- (void)parseEscapedComment:(NSString *)escapedComment {
    [self foundComment:[escapedComment stringByRemovingXMLEscapes]];
}

- (void)parseCDATA:(NSString *)cdata {
    NSData *data = [cdata dataUsingEncoding:NSUTF8StringEncoding];
    [self foundCDATA:data];
}

- (void)parseEscapedCharacters:(NSString *)escapedCharacters {
    if (_elementNameStack.count == 0) {
        // Characters cannot occur outside the document root element
        if ([escapedCharacters stringByTrimmingCharactersInSet:WhitespaceAndNewlineSet].length != 0) {
            // Whitespace is ok, though
            NSDictionary *dict = @{NSXMLParserErrorColumn : @-1, NSXMLParserErrorLineNumber : @-1,
                    NSXMLParserErrorMessage : NSLocalizedString(@"Extra content at the end of the document", nil)};
            NSError *error = [[NSError alloc]
                    initWithDomain:NSXMLParserErrorDomain code:NSXMLParserPrematureDocumentEndError userInfo:dict];
            [self parseErrorOccurred:error];
        }
        return;
    }
    NSString *characters = [escapedCharacters stringByRemovingXMLEscapes];
    [self foundCharacters:characters];

}

- (void)parseTag:(NSString *)tag {
    BOOL isClosingTag = [tag hasPrefix:@"/"];
    if (isClosingTag) {
        tag = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:WhitespaceAndNewlineSet];
    }
    BOOL isSelfClosingTag = [tag hasSuffix:@"/"];
    if (isSelfClosingTag) {
        tag = [[tag substringToIndex:tag.length - 1] stringByTrimmingCharactersInSet:WhitespaceAndNewlineSet];
    }
    _scanLocationOffset = _scanner.scanLocation - tag.length;
    NSScanner *origScanner = _scanner;
    _scanner = [NSScanner scannerWithString:tag];
    _scanner.charactersToBeSkipped = nil;
    // skip leading whitespace
    [_scanner scanCharactersFromSet:WhitespaceAndNewlineSet intoString:nil];
    // extract the tag name
    NSString *elementName = nil;
    [_scanner scanUpToCharactersFromSet:WhitespaceAndNewlineSet intoString:&elementName];
    if (isClosingTag) {
        // we are done, closing tags have no attributes
        [self didEndElement:elementName namespaceURI:nil qualifiedName:nil];
        [self popAndCheckElementName:elementName];
        _scanner = origScanner;
        return;
    }
    NSMutableDictionary *attributeDict = [[NSMutableDictionary alloc] init];
    while (YES) {
        // extract attribute
        // extract attribute name
        NSString *attributeName = nil;
        [_scanner scanUpToCharactersFromSet:EQSet intoString:&attributeName];
        if (!attributeName) {
            break;
        }
        attributeName = [attributeName stringByTrimmingCharactersInSet:WhitespaceAndNewlineSet];
        // extract attribute value
        [_scanner scanUpToCharactersFromSet:QuotSet intoString:nil];
        [_scanner scanCharactersFromSet:QuotSet intoString:nil];
        NSString *attributeValue = nil;
        [_scanner scanUpToCharactersFromSet:QuotSet intoString:&attributeValue];
        [_scanner scanCharactersFromSet:QuotSet intoString:nil];
        [attributeDict setObject:[attributeValue stringByRemovingXMLEscapes] forKey:attributeName];
    }
    [self didStartElement:elementName namespaceURI:nil qualifiedName:nil attributes:attributeDict];
    if (_abortParsing) {
        _scanner = origScanner;
        return;
    }
    if (isSelfClosingTag) {
        [self didEndElement:elementName namespaceURI:nil qualifiedName:nil];
    } else {
        [self pushElementName:elementName];
    }
    _scanner = origScanner;
}

- (void)pushElementName:(NSString *)name {
    [_elementNameStack addObject:name];
}

- (void)popAndCheckElementName:(NSString *)name {
    // Might add checking in a future version: NSString *lastName = _elementNameStack.lastObject;
    [_elementNameStack removeLastObject];
}

#pragma - NSXMLParserDelegate Interaction

- (void)didStartDocument {
    if ([self.delegate respondsToSelector:@selector(parserDidStartDocument:)]) {
        [self.delegate parserDidStartDocument:self];
    }
}

- (void)didEndDocument {
    if ([self.delegate respondsToSelector:@selector(parserDidEndDocument:)]) {
        [self.delegate parserDidEndDocument:self];
    }
}

- (void)didStartElement:(NSString *)elementName
           namespaceURI:(NSString *)namespaceURI
          qualifiedName:(NSString *)qName
             attributes:(NSDictionary *)attributeDict {
    if ([self.delegate respondsToSelector:@selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)]) {
        [self.delegate parser:self
              didStartElement:elementName
                 namespaceURI:namespaceURI
                qualifiedName:qName
                   attributes:attributeDict];
    }
}

- (void)didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([self.delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)]) {
        [self.delegate parser:self didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
    }
}

- (void)foundComment:(NSString *)comment {
    if ([self.delegate respondsToSelector:@selector(parser:foundComment:)]) {
        [self.delegate parser:self foundComment:comment];
    }
}

- (void)foundCharacters:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(parser:foundCharacters:)]) {
        [self.delegate parser:self foundCharacters:string];
    }
}

- (void)foundCDATA:(NSData *)data {
    if ([self.delegate respondsToSelector:@selector(parser:foundCDATA:)]) {
        [self.delegate parser:self foundCDATA:data];
    }
}

- (void)parseErrorOccurred:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(parser:parseErrorOccurred:)]) {
        [self.delegate parser:self parseErrorOccurred:error];
    }
}

@end
