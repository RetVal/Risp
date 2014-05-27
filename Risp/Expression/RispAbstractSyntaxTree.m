//
//  RispAbstractSyntaxTree.m
//  Risp
//
//  Created by closure on 5/24/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/RispAbstractSyntaxTree.h>
#import "RispAbstractSyntaxTree.h"
#import "RispBaseExpression+ASTDescription.h"

@interface RispAbstractSyntaxTree ()
@property (nonatomic, strong, readonly) id object;
@property (nonatomic, assign, readonly, getter = isExpression) BOOL expression;
@end

@implementation RispAbstractSyntaxTree
- (id)init {
    if (self = [super init]) {
        _object = nil;
        _expression = NO;
    }
    return self;
}

- (id)initWithExpression:(id<RispExpression>)expression {
    if (self = [self init]) {
        _object = expression;
        _expression = [_object conformsToProtocol:@protocol(RispExpression)];
    }
    return self;
}

+ (NSMutableString *)descriptionAppendIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    return [self descriptionAppendIndentation:indentation desc:desc fixupIfNeeded:YES];
}

+ (NSMutableString *)descriptionAppendIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc fixupIfNeeded:(BOOL)needFixup {
    for (NSInteger idx = 0; idx < indentation; idx++) {
        [desc appendString:@"    "];
    }
    if (indentation) {
        [desc appendString:@"|---"];
    }
    
    if (indentation > 0 && needFixup) {
        NSArray *lines = [desc componentsSeparatedByString:@"\n"];
        NSInteger stopCount = [lines count] - 1;
        NSMutableString *prefix = [[NSMutableString alloc] init];
        for (NSInteger idx = 0; idx < indentation; idx++) {
            [prefix appendString:@"    "];
        }
        __block NSInteger previousLength = 0;
        [lines enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            NSRange range = NSMakeRange(0, 0);
            if ([obj hasPrefix:prefix]) {
                range = NSMakeRange(previousLength + [prefix length], 1);
                [desc replaceCharactersInRange:range withString:@"|"];
            }
            previousLength += [obj length] + 1;
            *stop = idx == stopCount;
        }];
    }
    return desc;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    if ([self isExpression]) {
        [_object _descriptionWithIndentation:indentation + 1 desc:desc];
    } else {
        [desc appendString:[RispAbstractSyntaxTree descriptionAppendIndentation:indentation + 1 forObject:_object]];
    }
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale {
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"%@\n", NSStringFromClass([self class])];
    [self _descriptionWithIndentation:0 desc:desc];
    return desc;
}

- (NSString *)description {
    return [self descriptionWithLocale:nil];
}

+ (NSString *)descriptionAppendIndentation:(NSUInteger)indentation forObject:(id)object {
    NSMutableString *string = [[NSMutableString alloc] init];
    if ([object conformsToProtocol:@protocol(RispExpression)]) {
        [object _descriptionWithIndentation:indentation desc:string];
    } else if ([object conformsToProtocol:@protocol(RispSequence)]) {
        [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:string];
        [string appendString:[object className] ? : @""];
        [string appendString:@"\n"];
        [RispAbstractSyntaxTree descriptionAppendIndentation:indentation + 1 desc:string];
        [string appendFormat:@"%@", object];
        [string appendString:@"\n"];
    } else {
        [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:string];
        [string appendString:[object className] ? : @""];
        [string appendString:@" : "];
        [string appendFormat:@"%@", object];
        [string appendString:@"\n"];
    }
    return string;
}

+ (void)show:(id)object {
    NSLog(@"\n%@", [RispAbstractSyntaxTree descriptionAppendIndentation:0 forObject:object]);
}
@end
