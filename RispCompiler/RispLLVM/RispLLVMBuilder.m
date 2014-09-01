//
//  RispLLVMBuilder.m
//  RispCompiler
//
//  Created by closure on 9/2/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispLLVMBuilder.h"

@interface RispLLVMBuilder ()
+ (NSString *)_modeDescriptor:(RispLLVMBuilderMode)mode;
@end

@implementation RispLLVMBuilder
+ (NSString *)_modeDescriptor:(RispLLVMBuilderMode)mode {
    NSString *desc = @"";
    switch (mode) {
        case RispLLVMBuilderDebugMode:
            desc = @"Debug";
            break;
        case RispLLVMBuilderReleaseMode:
            desc = @"Release";
            break;
        default:
            break;
    }
    return desc;
}

+ (NSString *)outputFileDirectory:(NSString *)root mode:(RispLLVMBuilderMode)mode {
    return [NSString stringWithFormat:@"%@/%@", root, [RispLLVMBuilder _modeDescriptor:mode]];
}

+ (NSString *)intermediatesDirectory:(NSString *)root {
    return [NSString stringWithFormat:@"%@/Build/Intermediates", root];
}

+ (instancetype)builderWithRoot:(NSString *)root {
    return [[self alloc] initWithRoot:root];
}

- (instancetype)initWithRoot:(NSString *)root {
    BOOL isDir = NO;
    if (!([[NSFileManager defaultManager] fileExistsAtPath:[root stringByStandardizingPath] isDirectory:&isDir] && isDir == YES)) {
        return nil;
    }
    if (self = [super init]) {
        _root = [root stringByStandardizingPath];
    }
    return self;
}

+ (NSString *)_makeDirectory:(NSString *)path {
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (result) {
        return path;
    }
    NSLog(@"%@", error);
    return nil;
}

- (NSString *)makeBuildDirectory {
    NSString *path = [NSString stringWithFormat:@"%@/Build", _root];
    return [RispLLVMBuilder _makeDirectory:path];
}

- (NSString *)makeProductDirectory {
    NSString *path = [self makeBuildDirectory];
    path = [NSString stringWithFormat:@"%@/%@", path, @"Products"];
    return [RispLLVMBuilder _makeDirectory:path];
}

- (NSString *)makeIntermediatesDirectory {
    NSString *path = [self makeBuildDirectory];
    path = [NSString stringWithFormat:@"%@/%@", path, @"Intermediates"];
    return [RispLLVMBuilder _makeDirectory:path];
}

- (NSString *)makeProjectBuildTempDirectory:(NSString *)projectName {
    NSString *path = [self makeIntermediatesDirectory];
    path = [NSString stringWithFormat:@"%@/%@", path, projectName];
    return [RispLLVMBuilder _makeDirectory:path];
}

- (NSString *)makeModeOutputDirectory:(NSString *)projectName {
    return [RispLLVMBuilder _makeDirectory:[NSString stringWithFormat:@"%@/%@", [self makeProjectBuildTempDirectory:projectName], [RispLLVMBuilder _modeDescriptor:_builderMode]]];
}

- (NSString *)makeTargetBuildTempDirectory:(NSString *)projectName targetName:(NSString *)targetName {
    return [RispLLVMBuilder _makeDirectory:[NSString stringWithFormat:@"%@/%@/", [self makeModeOutputDirectory:projectName], targetName]];
}

- (NSString *)makeTargetBuildObjectDirectory:(NSString *)projectName targetName:(NSString *)targetName {
    return [RispLLVMBuilder _makeDirectory:[NSString stringWithFormat:@"%@/%@", [self makeTargetBuildTempDirectory:projectName targetName:targetName], @"Objects-normal"]];
}
@end
