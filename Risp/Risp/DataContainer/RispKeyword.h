//
//  RispKeyword.h
//  Risp
//
//  Created by closure on 4/17/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Risp/RispSymbol.h>

@interface RispKeyword : RispSymbol
+ (id)named:(NSString *)name;
+ (BOOL)isKeyword:(NSString *)object;
- (BOOL)isEqualTo:(id)object;
@end
