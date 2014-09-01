//
//  RispLLVMBuilder.h
//  RispCompiler
//
//  Created by closure on 9/2/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RispLLVMBuilderMode) {
    RispLLVMBuilderDebugMode = 0,
    RispLLVMBuilderReleaseMode = 1
};

@interface RispLLVMBuilder : NSObject
@property (nonatomic, copy, readonly) NSString *root;
@property (nonatomic, assign) RispLLVMBuilderMode builderMode;
+ (NSString *)outputFileDirectory:(NSString *)root mode:(RispLLVMBuilderMode)mode;
+ (instancetype)builderWithRoot:(NSString *)root;
- (instancetype)initWithRoot:(NSString *)root;
- (NSString *)makeProductDirectory;
- (NSString *)makeBuildDirectory;
- (NSString *)makeIntermediatesDirectory;
- (NSString *)makeProjectBuildTempDirectory:(NSString *)projectName;
- (NSString *)makeModeOutputDirectory:(NSString *)projectName;
- (NSString *)makeTargetBuildTempDirectory:(NSString *)projectName targetName:(NSString *)targetName;
- (NSString *)makeTargetBuildObjectDirectory:(NSString *)projectName targetName:(NSString *)targetName;
@end
