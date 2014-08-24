//
//  RispNameMangling.h
//  RispCompiler
//
//  Created by closure on 8/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispInvokeExpression.h>

@interface RispNameMangling : NSObject
+ (NSString *)nameManglingForFunction:(RispInvokeExpression *)invokeExpression;
@end
