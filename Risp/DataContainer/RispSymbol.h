//
//  RispSymbol.h
//  Risp
//
//  Created by closure on 4/14/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RispSymbol : NSObject <NSCopying> {
    @protected
    NSString *_stringValue;
    NSUInteger _hashCode;
}
@property (strong, nonatomic, readonly) NSString *stringValue;
+ (id)named:(NSString *)name;
- (BOOL)isEqualTo:(id)object;
- (NSUInteger)length;
@end
