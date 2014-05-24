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
@property (nonatomic, strong, readonly) RispBaseExpression *expression;
@end

@implementation RispAbstractSyntaxTree
- (id)init {
    if (self = [super init]) {
        _expression = nil;
    }
    return self;
}

- (id)initWithExpression:(id<RispExpression>)expression {
    if (self = [self init]) {
        _expression = expression;
    }
    return self;
}

+ (NSMutableString *)descriptionAppendIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    for (NSUInteger idx = 0; idx < indentation; idx++) {
        [desc appendFormat:@"\t"];
    }
    return desc;
}

- (void)_descriptionWithIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc {
    [RispAbstractSyntaxTree descriptionAppendIndentation:indentation desc:desc];
    [desc appendFormat:@"%@", [_expression class]];
    [_expression _descriptionWithIndentation:indentation desc:desc];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale {
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"%@------------------------------------------------------------------------------\r\n", NSStringFromClass([self class])];
    [self _descriptionWithIndentation:1 desc:desc];
    return desc;
}

- (NSString *)description {
    return [self descriptionWithLocale:nil];
}
@end
