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
- (id)initWithExpression:(id)object;
- (id)object;
+ (NSMutableString *)descriptionAppendIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc;
+ (NSMutableString *)descriptionAppendIndentation:(NSUInteger)indentation desc:(NSMutableString *)desc fixupIfNeeded:(BOOL)needFixup;
- (NSString *)description;
- (NSString *)descriptionWithLocale:(NSLocale *)locale;

+ (NSString *)descriptionAppendIndentation:(NSUInteger)indentation forObject:(id)object;
+ (void)show:(id)object;
@end
