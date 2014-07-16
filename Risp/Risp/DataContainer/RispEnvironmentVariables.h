//
//  RispEnvironmentVariables.h
//  Risp
//
//  Created by closure on 3/13/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef Risp_RispEnvironmentVariables_h
#define Risp_RispEnvironmentVariables_h

#include <Foundation/Foundation.h>

FOUNDATION_EXPORT void RispEnvironmentVariablesInitialize();
FOUNDATION_EXPORT NSString * const RispEnvCurrentFrameworkDirectory;
FOUNDATION_EXPORT NSString * const RispEnvWorkDirectory;
FOUNDATION_EXPORT NSString * const RispEnvIn;
FOUNDATION_EXPORT NSString * const RispEnvOut;
FOUNDATION_EXPORT NSString * const RispEnvError;

#endif
