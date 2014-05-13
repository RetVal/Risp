//
//  RispSequenceProtocol.h
//  Syrah
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef Syrah_RispSequenceProtocol_h
#define Syrah_RispSequenceProtocol_h

@protocol RispSequence <NSObject, NSCopying>
@required
- (NSUInteger)count;
- (id)first;
- (id)next;
- (id)rest;
- (id)last;
- (id)drop:(NSNumber *)n;
- (id)cons:(id)o;
- (id)second;
- (id)copyWithZone:(NSZone *)zone;
- (NSArray *)array;
- (BOOL)isEqualTo:(id)object;
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
@optional
- (id)conj:(id)o;

+ (id)empty;
- (id)equiv:(id)o;
- (BOOL)isEmpty;
- (id)eval;
@end

#endif
