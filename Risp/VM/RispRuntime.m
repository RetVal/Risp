//
//  RispRuntime.m
//  Syrah
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispRuntime.h>
#import <Risp/RispList.h>
#import <Risp.h>

@interface RispRuntime() {
    
}
@end
@implementation RispRuntime
+ (void)load {
    [[RispRuntime baseEnvironment] rootScope];
}

- (id)init {
    if (self = [super init]) {
        _rootScope = [[RispLexicalScope alloc] init];
        [RispRuntime _initRootScope:_rootScope];
    }
    return self;
}

+ (id)map:(id)object fn:(id (^)(id object))fn {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id x = fn(obj);
        if (x == nil) {
            NSLog(@"wocao");
        }
        [array addObject:x];
//        [array addObject:fn(obj) ? : [NSNull null]];
    }];
    return [[[object class] alloc] initWithArray:array];
}

+ (id)reduce:(id)object fn:(id (^)(id coll, id object))fn {
    __block id mutable = nil;
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        mutable = obj;
        *stop = YES;
    }];
    
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx) {
            mutable = fn(mutable, obj);
        }
    }];
    return mutable;
}

+ (void)apply:(id)object fn:(id (^)(id object))fn {
    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        fn(obj);
    }];
}

+ (id)filter:(id)object pred:(id (^)(id object))pred {
    id array = [object isKindOfClass:[NSArray class]] ? object : [object array];
    RispList *list = [[RispList alloc] initWithArray:[object objectsAtIndexes:[array indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *x = pred(obj);
        BOOL b = [x boolValue];
        return b;
    }]]];
    return list;
}

+ (id)remove:(id)object pred:(id (^)(id object))pred {
    return [self filter:object pred:^id(id object) {
        return @(![pred(object) booleanValue]);
    }];
}

+ (instancetype)baseEnvironment {
    static dispatch_once_t onceToken;
    static RispRuntime *runtime;
    dispatch_once(&onceToken, ^{
        runtime = [[RispRuntime alloc] init];
    });
    return runtime;
}

+ (NSRange)rangeForDefaultArugmentsNumber {
    return NSMakeRange(0, 1);
}

+ (NSRange)rangeForDefaultArugmentsNumberWithUnlimit {
    return NSMakeRange(0, -1);
}

- (BOOL)registerSymbol:(RispSymbol *)symbol forObject:(id)object {
    if (!symbol)
        return NO;
    _rootScope[symbol] = object;
    return YES;
}

+ (void)_initRootScope:(RispLexicalScope *)rootScope {
    if ([rootScope depth])
        return;
    
    rootScope[[RispSymbol APPLY]] = [RispFnExpression blockWihObjcBlock:^id(RispVector *arguments) {
        id f = [arguments first];
        RispFnExpression *fn = nil;
        if (f && [f isKindOfClass:[RispClosureExpression class]]) {
            fn = [f fnExpression];
        } else {
            fn = f;
        }
        
        if (fn && [fn isKindOfClass:[RispFnExpression class]]) {
            RispMethodExpression *method = [fn methodForArguments:[arguments second]];
            return [method applyTo:[RispVector listWithObjectsFromArrayNoCopy:[[arguments second] array]]];
        }
        return nil;
    } variadic:NO numberOfArguments:2];
    rootScope[[RispSymbol MAP]] = [RispFnExpression blockWihObjcBlock:^id(RispVector *arguments) {
        id f = [arguments first];
        RispFnExpression *fn = nil;
        if (f && [f isKindOfClass:[RispClosureExpression class]]) {
            fn = [f fnExpression];
        } else {
            fn = f;
        }

        if (fn && [fn isKindOfClass:[RispFnExpression class]]) {
            RispMethodExpression *method = [fn methodForCountOfArgument:1];
            if (!method) {
                [NSException raise:RispIllegalArgumentException format:@"%@ should have only one argument", fn];
            }
            return [RispRuntime map:[arguments second] fn:^id(id object) {
                return [method applyTo:[RispVector listWithObjects:object, nil]];
            }];
        }
        return nil;
    } variadic:NO numberOfArguments:2];
    rootScope[[RispSymbol REDUCE]] = [RispFnExpression blockWihObjcBlock:^id(RispVector *arguments) {
        id f = [arguments first];
        RispFnExpression *fn = nil;
        if (f && [f isKindOfClass:[RispClosureExpression class]]) {
            fn = [f fnExpression];
        } else {
            fn = f;
        }
        
        if (fn && [fn isKindOfClass:[RispFnExpression class]]) {
            RispMethodExpression *method = [fn methodForCountOfArgument:2];
            return [RispRuntime reduce:[[arguments second] array] fn:^id(id coll, id object) {
                return [method applyTo:[RispVector listWithObjects:coll, object, nil]];
            }];
        }
        return nil;
    } variadic:NO numberOfArguments:2];
    rootScope[[RispSymbol FILTER]] = [RispFnExpression blockWihObjcBlock:^id(RispVector *arguments) {
        id f = [arguments first];
        RispFnExpression *fn = nil;
        if (f && [f isKindOfClass:[RispClosureExpression class]]) {
            fn = [f fnExpression];
        } else {
            fn = f;
        }
        
        if (fn && [fn isKindOfClass:[RispFnExpression class]]) {
            RispMethodExpression *method = [fn methodForCountOfArgument:1];
            if (!method) {
                [NSException raise:RispIllegalArgumentException format:@"%@ should have only one argument", fn];
            }
            return [RispRuntime filter:[[arguments second] array] pred:^id(id object) {
                return [method applyTo:[RispVector listWithObjects:object, nil]];
            }];
        }
        return nil;
    } variadic:NO numberOfArguments:2];
}
@end

NSString * const RispRuntimeException = @"RispRuntimeException";
NSString * const RispInvalidNumberFormatException = @"RispInvalidNumberFormatException";
NSString * const RispIllegalArgumentException = @"RispIllegalArgumentException";
