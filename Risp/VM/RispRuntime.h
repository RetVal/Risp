//
//  RispRuntime.h
//  Syrah
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispSymbol.h>
#import <Risp/RispLexicalScope.h>
#import <Risp/RispList.h>
#import <Risp/RispContext.h>

@interface RispRuntime : NSObject
@property (strong, nonatomic, readonly) RispLexicalScope *rootScope;
@property (assign, nonatomic, readonly, getter = isDeref) id defref;

+ (id)map:(id)object fn:(id (^)(id object))fn;
+ (void)apply:(id)object fn:(id (^)(id object))fn;
+ (id)reduce:(id)object fn:(id (^)(id coll, id object))fn;
+ (id)filter:(id)object pred:(id (^)(id object))pred;
+ (id)remove:(id)object pred:(id (^)(id object))pred;

+ (instancetype)baseEnvironment;
+ (NSRange)rangeForDefaultArugmentsNumber;
+ (NSRange)rangeForDefaultArugmentsNumberWithUnlimit;
- (BOOL)registerSymbol:(RispSymbol *)symbol forObject:(id)object;
@end

FOUNDATION_EXPORT NSString * const RispRuntimeException;
FOUNDATION_EXPORT NSString * const RispInvalidNumberFormatException;
FOUNDATION_EXPORT NSString * const RispIllegalArgumentException;
