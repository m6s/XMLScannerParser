//
// Created by Matthias Schmitt on 3/28/15.
// Copyright (c) 2015 Matthias Schmitt. All rights reserved.
//

#import "MATXMLDropInParser.h"


@implementation MATXMLDropInParser
- (instancetype)initWithContentsOfURL:(NSURL *)url {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithData:(NSData *)data {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithStream:(NSInputStream *)stream {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id <NSXMLParserDelegate>)delegate {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setDelegate:(id <NSXMLParserDelegate>)delegate {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)shouldProcessNamespaces {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)setShouldProcessNamespaces:(BOOL)shouldProcessNamespaces {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)shouldReportNamespacePrefixes {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)setShouldReportNamespacePrefixes:(BOOL)shouldReportNamespacePrefixes {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSXMLParserExternalEntityResolvingPolicy)externalEntityResolvingPolicy {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (void)setExternalEntityResolvingPolicy:(NSXMLParserExternalEntityResolvingPolicy)externalEntityResolvingPolicy {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSSet *)allowedExternalEntityURLs {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setAllowedExternalEntityURLs:(NSSet *)allowedExternalEntityURLs {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)parse {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)abortParsing {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSError *)parserError {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)shouldResolveExternalEntities {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)setShouldResolveExternalEntities:(BOOL)shouldResolveExternalEntities {
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - NSXMLParser + NSXMLParserLocatorAdditions

- (NSString *)publicID {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)systemID {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSInteger)lineNumber {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (NSInteger)columnNumber {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

@end
