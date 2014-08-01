//
//  RispBaseReader.h
//  Risp
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RispPushBackReader, RispReader, RispList;

FOUNDATION_EXPORT NSMutableArray *RispMacros;
FOUNDATION_EXPORT NSMutableArray *RispDispatchMacros;

@interface RispBaseReader : NSObject
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSString *file;
+ (BOOL)isWhiteSpace:(NSInteger)ch;
+ (BOOL)isDigit:(NSInteger)ch;
+ (BOOL)isDigit:(NSInteger)ch decimal:(NSInteger)decimal;
+ (BOOL)isTerminatingMacro:(NSInteger)ch;
+ (BOOL)isMacros:(NSInteger)ch;
+ (id)macro:(NSInteger)ch;
+ (NSInteger)readUnicodeChar:(RispPushBackReader *)reader ch:(NSInteger)ch decimal:(NSInteger)base length:(NSUInteger)length exact:(BOOL)exact;

- (id)initWithContent:(NSString *)content fileNamed:(NSString *)file;
- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithData:(NSData *)data fileNamed:(NSString *)file;
- (id)invoke:(RispReader *)reader object:(id)object;
- (RispList *)reader:(RispReader *)reader delimited:(unichar)delimit recursive:(BOOL)isRecursive;
@end
