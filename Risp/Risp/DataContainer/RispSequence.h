//
//  RispSequence.h
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispSequenceProtocol.h>

@interface RispSequence : NSObject <RispSequence, NSCopying, NSFastEnumeration>
@property (nonatomic, assign, readonly) NSInteger count;
+ (id)listWithObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithObject:(id)object base:(RispSequence *)base;
- (id)initWithArray:(NSArray *)array;

- (id)first;
- (id)next;
- (id)second;
- (id)rest;
- (id)last;
- (id)reverse;
- (id)drop:(NSNumber *)n;
- (id)cons:(id)o;
- (id)conj:(id)o;
- (NSArray *)array;
- (BOOL)isEqualTo:(id)object;

+ (id)empty;
- (BOOL)isEmpty;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len;

- (NSString *)stringValue;
@end

@interface RispSequence (Sequence)
+ (id <RispSequence>)sequence:(id)obj;
@end
