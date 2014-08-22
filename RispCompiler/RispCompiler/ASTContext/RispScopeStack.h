//
//  RispScopeStack.h
//  RispCompiler
//
//  Created by closure on 8/21/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <llvm/ADT/DenseMap.h>
#include <llvm/IR/Value.h>

@interface RispScopeStack : NSObject
@property (nonatomic, strong, readonly) RispScopeStack *next;
@property (nonatomic, weak,   readonly) RispScopeStack *previous;
- (instancetype)init;

- (llvm::Value *)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0);
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0);
@end
