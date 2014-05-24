//
//  RispAbstractSyntaxTree.h
//  Risp
//
//  Created by closure on 5/24/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Risp/RispBaseExpression.h>
@interface RispAbstractSyntaxTree : NSObject
- (id)init;
- (id)initWithExpression:(id <RispExpression>)expression;
- (id <RispExpression>)expression;
+ (NSMutableString *)descriptionAppendIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc;
- (NSString *)description;
- (NSString *)descriptionWithLocale:(NSLocale *)locale;
@end
