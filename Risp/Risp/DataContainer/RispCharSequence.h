//
//  RispCharSequence.h
//  Risp
//
//  Created by closure on 5/18/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RispCharSequence : NSObject <RispSequence>
- (id)initWithString:(NSString *)str;
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
@end
