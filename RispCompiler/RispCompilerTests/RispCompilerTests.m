//
//  RispCompilerTests.m
//  RispCompilerTests
//
//  Created by closure on 8/11/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RispCompiler/RispCompiler.h>
#import <XCTest/XCTest.h>
@interface RispCompilerTests : XCTestCase

@end

@implementation RispCompilerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
//    const char *r = @encode(NSString *);
//    NSLog(@"%s", r);
    
//    NSString *code = @"(def x 5) (def my-list '(x 1 2 3 4 \"hello\")) (. RispBuiltin show: my-list)";
    NSString *code = [[NSString alloc] initWithContentsOfFile:[@"~/Desktop/rispCompiler.risp" stringByStandardizingPath] encoding:NSUTF8StringEncoding error:nil];
//    code = @"(def a \"hello\")";
    @autoreleasepool {
        RispASTContext *ASTContext = [RispASTContext ASTContext];
        NSArray *exprs = [RispASTContext expressionFromCurrentLine:code];
        for (id <RispExpression> expr in exprs) {
            [ASTContext emitRispAST:[[RispAbstractSyntaxTree alloc] initWithExpression:expr]];
        }
        [ASTContext done];
    }
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

