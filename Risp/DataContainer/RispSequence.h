//
//  RispSequence.h
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispSequenceProtocol.h>

@interface RispSequence : NSObject <RispSequence, NSCopying>
@property (nonatomic, assign, readonly) NSInteger count;

- (id)initWithObject:(id)object base:(RispSequence *)base;
- (id)initWithArray:(NSArray *)array;

- (id)first;
- (id)next;
- (id)second;
- (id)rest;
- (id)last;
- (id)reverse;
- (id)drop:(NSUInteger)n;
- (id)cons:(id)o;
- (id)conj:(id)o;
- (NSArray *)array;
- (BOOL)isEqualTo:(id)object;

+ (id)empty;
- (BOOL)isEmpty;
@end
