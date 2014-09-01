//
//  RispSymbolExpression+Meta.h
//  RispCompiler
//
//  Created by closure on 8/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispSymbolExpression.h>

@interface RispSymbolExpression (Meta)
- (BOOL)isClass;
- (void)setIsClass:(BOOL)isClass;
@end
