//
// Created by Matthias Schmitt on 12/27/14.
// Copyright (c) 2014 Matthias Schmitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoggingParserDelegate : NSObject <NSXMLParserDelegate>
@property(nonatomic, strong) NSArray *log;
@property(nonatomic, strong) NSArray *info;
@end
