//
//  Risp+DEBUG.h
//  Risp
//
//  Created by closure on 5/26/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Risp/Risp.h>

@interface NSObject (Debug)
- (NSString *)rispLocationInfomation;
@end

@interface Risp : NSObject

@end

@interface Risp (Debug)
+ (NSString *)decriptionForExpression:(id <RispExpression>)expression;
+ (void)show:(id)object;
@end

#if TARGET_OS_IPHONE
@interface NSObject (className)
- (NSString *)className;
- (BOOL)isEqualTo:(id)object;
@end
#endif