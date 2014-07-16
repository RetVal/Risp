//
//  RispToken.h
//  Risp
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispSymbol.h"

@interface RispToken : RispSymbol <NSCopying>
@property (strong, nonatomic, readonly) NSString *stringValue;
+ (id)named:(NSString *)name;
@end
