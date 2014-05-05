//
//  RispVector.h
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Risp/RispSequenceProtocol.h>

@interface RispVector : NSObject <RispSequence, NSCopying>
+ (id)listWithObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)listWithObjectsFromArray:(NSArray *)array;
+ (id)listWithObjectsFromArrayNoCopy:(NSArray *)array;

- (id)init;
- (id)initWithArray:(NSArray *)array;
- (id)initWithArrayNoCopy:(NSArray *)array;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;

- (NSArray *)array;

- (id)nth:(NSUInteger)idx;

+ (id)empty;
- (BOOL)isEmpty;

@end

@interface RispVector (Mutable)
- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);
@end

