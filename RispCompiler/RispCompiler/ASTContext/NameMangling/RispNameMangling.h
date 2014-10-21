//
//  RispNameMangling.h
//  RispCompiler
//
//  Created by closure on 8/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Risp/RispMethodExpression.h>
#import <Risp/RispFnExpression.h>

@class RispASTContext, RispNameManglingFunctionDescriptor, RispNameManglingArgumentsDescriptor;
@interface RispNameMangling : NSObject
+ (instancetype)nameMangling;
- (RispNameManglingFunctionDescriptor *)functionManglingWithName:(NSString *)name arguments:(RispVector *)args;
- (RispNameManglingFunctionDescriptor *)methodMangling:(RispMethodExpression *)method functionName:(NSString *)functionName;
- (NSArray *)functionMangling:(RispFnExpression *)fnExpression; // RispNameManglingFunctionDescriptor* inside
- (BOOL)isManglingFunction:(NSString *)name context:(RispASTContext *)context;
- (RispNameManglingFunctionDescriptor *)demanglingFunctionName:(NSString *)name context:(RispASTContext *)context;
+ (NSString *)anonymousFunctionName:(NSUInteger)count;
@end
