//
//  RispLexicalScope.h
//  Syrah
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RispSymbol;
@interface RispLexicalScope : NSObject <NSCoding, NSCopying>
@property (strong, nonatomic, readonly) RispLexicalScope *inner;
@property (weak,   nonatomic, readonly) RispLexicalScope *outer;
@property (strong, nonatomic, readonly) NSException *exception;
@property (assign, nonatomic, readonly) NSUInteger depth;
- (id)init;
- (id)initWithParent:(RispLexicalScope *)outer;
- (id)initWithParent:(RispLexicalScope *)outer child:(RispLexicalScope *)inner;

- (id)objectForKey:(RispSymbol *)symbol;
- (void)setObject:(id)object forKey:(RispSymbol <NSCopying>*)aKey;

- (id)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0);
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0);

- (NSArray *)keys;
- (NSArray *)values;
@end
