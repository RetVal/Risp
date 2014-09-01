//
//  main.m
//  RispLLVM
//
//  Created by closure on 8/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RispCompiler/RispCompiler.h>
#import "RispLLVMBuilder.h"

static NSString * RispLLVMInputFileKey = @"i";
static NSString * RispLLVMInputFileListKey = @"fileList";
static NSString * RispLLVMOutputDirectory = @"o";
int main(int argc, const char * argv[]) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *inputFile = [userDefaults stringForKey:RispLLVMInputFileKey];
    NSString *fileList = [userDefaults stringForKey:RispLLVMInputFileListKey];
    NSString *outputDirectory = [userDefaults stringForKey:RispLLVMOutputDirectory];
    NSLog(@"%@, %@, %@", inputFile, fileList, outputDirectory);
    NSMutableArray *inputFiles = [[NSMutableArray alloc] init];
    if (inputFile) {
        [inputFiles addObject:inputFile];
    }
    if (fileList) {
        NSError *error = nil;
        NSString *fileListContents = [[NSString alloc] initWithContentsOfFile:[fileList stringByStandardizingPath] encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@", error);
            return 1;
        }
        [inputFiles addObjectsFromArray:[fileListContents componentsSeparatedByString:@"\n"]];
    }
    
    outputDirectory = outputDirectory ? [outputDirectory stringByStandardizingPath] : [[NSFileManager defaultManager] currentDirectoryPath];
    RispLLVMBuilder *dirBuilder = [RispLLVMBuilder builderWithRoot:outputDirectory];
    outputDirectory = [dirBuilder makeTargetBuildObjectDirectory:@"proj" targetName:@"target"];
    for (NSString *filePath in inputFiles) {
        @autoreleasepool {
            NSString *fullPath = [filePath stringByStandardizingPath];
            NSString *fileName = fullPath;
            NSString *code = [[NSString alloc] initWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
            fileName = [[fileName lastPathComponent] stringByDeletingPathExtension];
            @autoreleasepool {
                printf("compiling %s...\n", [fullPath UTF8String]);
                RispASTContext *ASTContext = [[RispASTContext alloc] initWithName:[fileName stringByDeletingPathExtension]];
                NSArray *exprs = [RispASTContext expressionFromCurrentLine:code];
                for (id <RispExpression> expr in exprs) {
                    RispAbstractSyntaxTree *AST = [[RispAbstractSyntaxTree alloc] initWithExpression:expr];
                    [ASTContext emitRispAST:AST];
                }
                [ASTContext doneWithOutputPath:outputDirectory];
            }
        }
    }
//    printf("\nlinking...\n");
    //            system("cd ~/Desktop && ld -demangle -arch x86_64 -macosx_version_min 10.9.0 -o risp.out risp.o -lSystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/clang/5.1/lib/darwin/libclang_rt.osx.a -print_statistics -L/Users/closure/Library/Frameworks -F/Users/closure/Library/Frameworks -framework Foundation -framework Risp -framework RispCompiler");
    return 0;
}
