//
//  main.m
//  RispLLVM
//
//  Created by closure on 8/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RispCompiler/RispCompiler.h>
static void usage() {
    printf("RispLLVM risp-code.risp\n");
}
int main(int argc, const char * argv[]) {
    if (argc < 2) {
        usage();
        return 1;
    }
    @autoreleasepool {
        // insert code here...
        NSString *code = [[NSString alloc] initWithContentsOfFile:[@(argv[1]) stringByStandardizingPath] encoding:NSUTF8StringEncoding error:nil];
        //    code = @"(def a \"hello\")";
        @autoreleasepool {
            printf("compiling risp...\n");
            RispASTContext *ASTContext = [RispASTContext ASTContext];
            NSArray *exprs = [RispASTContext expressionFromCurrentLine:code];
            for (id <RispExpression> expr in exprs) {
                [ASTContext emitRispAST:[[RispAbstractSyntaxTree alloc] initWithExpression:expr]];
            }
            [ASTContext done];
            printf("\nlinking...\n");
            system("cd ~/Desktop && ld -demangle -arch x86_64 -macosx_version_min 10.9.0 -o risp.out risp.o -lSystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/clang/5.1/lib/darwin/libclang_rt.osx.a -print_statistics -L/Users/closure/Library/Frameworks -F/Users/closure/Library/Frameworks -framework Foundation -framework Risp -framework RispCompiler");
        }
    }
    return 0;
}
