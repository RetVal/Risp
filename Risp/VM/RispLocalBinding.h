//
//  RispLocalBinding.h
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RispSymbol, NSTreeNode, RispBaseExpression;
@interface RispLocalBinding : NSObject
@property (nonatomic, strong, readonly) RispSymbol *sym;
@property (nonatomic, strong, readonly) RispSymbol *tag;
@property (nonatomic, strong) RispBaseExpression *expr;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) NSInteger idx;
@property (nonatomic, assign, readonly) BOOL isArg;
@property (nonatomic, strong) NSTreeNode *clearPathRoot;
@property (nonatomic, assign) BOOL canBeCleared;
@property (nonatomic, assign) BOOL recurMistmatch;

- (id)initWithIndex:(NSInteger)index symbol:(RispSymbol *)sym tag:(RispSymbol *)tag init:(RispBaseExpression *)expr isArg:(BOOL)isArg pathNode:(NSTreeNode *)clearPathRoot;

@end
