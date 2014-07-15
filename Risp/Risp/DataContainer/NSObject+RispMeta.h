//
//  NSObject+RispMeta.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispMetaKeyDefinition.h>

@interface NSObject (RispMeta)
- (NSDictionary *)meta;
- (BOOL)hasMeta;
- (id)withMeta:(id)value forKey:(id)key;

- (id)copyMetaFromObject:(id)object;
@end

@interface NSObject (RispDebugLocation)
- (NSString *)file;
- (void)setFile:(NSString *)file;

- (NSInteger)columnNumber;
- (void)setColumnNumber:(NSInteger)columnNumber;

- (NSInteger)lineNumber;
- (void)setLineNumber:(NSInteger)lineNumber;

- (NSInteger)start;
- (void)setStart:(NSInteger)start;

- (NSInteger)end;
- (void)setEnd:(NSInteger)end;
@end
