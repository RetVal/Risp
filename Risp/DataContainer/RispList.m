//
//  RispList.m
//  Risp
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispList.h>
#include <objc/runtime.h>
#import <Risp/RispRuntime.h>
#import <Risp/RispSequenceProtocol.h>

#import <Risp/RispFnExpression.h>
#import <Risp/RispBlockExpression.h>

@interface RispList() {
    
}
@end


static RispList * __RispEmptyList = nil;
@implementation RispList
+ (void)load {
    __RispEmptyList = [[RispList alloc] initWithArray:@[]];
}

+ (id)listWithObjects:(id)object, ... {
    if (!object) {
        return [[RispList alloc] initWithArray:@[]];
    }
    RispSequence *list = [[RispSequence alloc] init];
    va_list ap;
    va_start(ap, object);
    id o = object;
    do {
        list = [list cons:o];
        o = va_arg(ap, id);
    } while (o);
    va_end(ap);
    return list;
}

+ (id)listWithObjectsFromArray:(NSArray *)array {
    return [[RispList alloc] initWithArray:array];
}

+ (id)listWithRest:(id <RispSequence>)rest objects:(id)object, ... {
    if (!object) {
        return [rest copyWithZone:nil];
    }
    if (!object) {
        return [[RispList alloc] initWithArray:@[]];
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    va_list ap;
    va_start(ap, object);
    id o = object;
    do {
        [array addObject:o];
        o = va_arg(ap, id);
    } while (o);
    va_end(ap);
    
    if (rest) {
        id x = rest;
        while (x) {
            [array addObject:[x first]];
            x = [x next];
        }
    }
    return [[RispList alloc] initWithArray:array];
}

+ (id)creator {
    RispFnExpression *fn = [[RispFnExpression alloc] init];
    [fn setName:[RispSymbol named:@"list"]];
    RispBlockExpression *method = [[RispBlockExpression alloc] initWithBlock:^id(RispVector *arguments) {
        return [RispList listWithObjectsFromArray:[arguments array]];
    } variadic:YES numberOfArguments:0];
    [fn setVariadicMethod:method];
    return fn;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithArray:(NSArray *)array {
    if (self = [super initWithArray:array]) {
        
    }
    return self;
}

+ (id)empty {
    return [[RispList alloc] init];
}
@end
