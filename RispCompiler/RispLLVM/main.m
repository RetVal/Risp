//
//  main.m
//  RispLLVM
//
//  Created by closure on 8/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RispCompiler/RispCompiler.h>
#import "RispLLVMDirectoryBuilder.h"
#import "RispLLVMCompiler.h"
#import "RispLLVMCommandLine.h"

static NSString * RispLLVMInputFileKey = @"i";
static NSString * RispLLVMInputFileListKey = @"fileList";
static NSString * RispLLVMOutputDirectory = @"o";
static NSString * RispLLVMEmitLLVMFile = @"-emit-llvm";
static NSString * RispLLVMShowLLVMFile = @"-show-llvm";
static NSString * RispLLVMEmitASMFile = @"-emit-asm";
static NSString * RispLLVMShowASMFile = @"-show-asm";

static NSString * RispLLVMShowPerformance = @"-show-performance";
static NSString * RispLLVMShowFunctionMeta = @"-show-func-meta";

int main(int argc, const char * argv[]) {
    RispLLVMCommandLine *userDefaults = [RispLLVMCommandLine parseArgc:argc argv:argv];
    
    NSString *inputFile = [userDefaults stringForKey:RispLLVMInputFileKey];
    NSString *fileList = [userDefaults stringForKey:RispLLVMInputFileListKey];
    NSString *outputDirectory = [userDefaults stringForKey:RispLLVMOutputDirectory];
    
    RispASTContextDoneOptions options = RispASTContextDoneWithShowNothing;
    
    options |= [userDefaults boolForKey:RispLLVMEmitLLVMFile] ? RispASTContextDoneWithOutputIRCode : 0;
    options |= outputDirectory ? RispASTContextDoneWithOutputObjectFile : 0;
    options |= [userDefaults boolForKey:RispLLVMEmitASMFile] ? RispASTContextDoneWithOutputASMCode : 0;
    options |= [userDefaults boolForKey:RispLLVMShowLLVMFile] ? RispASTContextDoneWithShowIRCode : 0;
    options |= [userDefaults boolForKey:RispLLVMShowASMFile] ? RispASTContextDoneWithShowASMCode : 0;
    options |= [userDefaults boolForKey:RispLLVMShowPerformance] ? RispASTContextDoneWithShowPerformance : 0;
    options |= [userDefaults boolForKey:RispLLVMShowFunctionMeta] ? RispASTContextDoneWithShowFunctionMeta : 0;
    
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
    RispLLVMDirectoryBuilder *dirBuilder = [RispLLVMDirectoryBuilder builderWithRoot:outputDirectory];
    outputDirectory = [dirBuilder makeTargetBuildObjectDirectory:@"proj" targetName:@"target"];
    NSArray *objectFiles = [RispLLVMCompiler compileFiles:inputFiles outputDirectory:outputDirectory options:options];
    NSLog(@"%@", objectFiles);
    printf("\nlinking...\n");
    NSString *append = @"-lSystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/../lib/clang/6.0/lib/darwin/libclang_rt.osx.a -print_statistics -L/Users/closure/Library/Frameworks -F/Users/closure/Library/Frameworks -framework Foundation -framework Risp -framework RispCompiler";
    NSString *ld = @"/SourceCache/Library/3rd/Apple/ld64-236.3/Build/Products/Debug/ld -demangle -arch x86_64 -macosx_version_min 10.10.0";
    NSString *objectFile = [objectFiles firstObject];
    NSString *dir = [objectFile stringByDeletingLastPathComponent];
    NSString *location = [NSString stringWithFormat:@"cd %@", dir];
    NSString *output = [NSString stringWithFormat:@"-o risp.out %@", objectFile];
    NSString *final = [NSString stringWithFormat:@"%@ && %@ %@ %@", location, ld, output, append];
    NSLog(@"%@", final);
    system([final UTF8String]);
    return 0;
}
