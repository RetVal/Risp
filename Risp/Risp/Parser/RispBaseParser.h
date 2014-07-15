//
//  RispBaseParser.h
//  Risp
//
//  Created by closure on 4/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispBaseExpression.h>

@class RispContext, RispSymbol, RispLexicalScope;
@interface RispBaseParser : NSObject
+ (id)parser:(id)object context:(RispContext *)context;
+ (id <RispExpression>)analyze:(RispContext *)context form:(id)form;
@end

@interface RispBaseParser (tag)
+ (RispSymbol *)tagOfObject:(id)o;
+ (id)resolveSymbol:(RispSymbol *)symbol allowPrivate:(BOOL)allowPrivate inScope:(RispLexicalScope *)scope;
@end
