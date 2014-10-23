//
//  RispLexicalScope.h
//  Syrah
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispSymbol;

typedef NS_ENUM(NSUInteger, RispScopeType) {
    RispNormalScope = 0,
    RispLoadFileScope = 1
};

@interface RispLexicalScope : NSObject <NSCoding, NSCopying>
@property (strong, nonatomic, readonly) RispLexicalScope *inner;
@property (strong, nonatomic, readonly) NSException *exception;
@property (assign, nonatomic) NSUInteger depth;
@property (strong, nonatomic) NSDictionary *scope;
@property (assign, nonatomic) RispScopeType type; // the reason why the scope pushed

- (id)init;
- (id)initWithParent:(RispLexicalScope *)outer;
- (id)initWithParent:(RispLexicalScope *)outer child:(RispLexicalScope *)inner;

- (id)objectForKey:(RispSymbol *)symbol;
- (void)setObject:(id)object forKey:(RispSymbol <NSCopying>*)aKey;

- (id)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0);
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0);

- (RispLexicalScope *)outer;
- (RispLexicalScope *)root;

- (NSArray *)keys;
- (NSArray *)values;

- (void)addType:(RispScopeType)type;
- (void)removeType:(RispScopeType)type;

@end
