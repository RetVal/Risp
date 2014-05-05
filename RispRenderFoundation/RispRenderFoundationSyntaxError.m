//
//  RispRenderFoundationSyntaxError.m
//  Fragaria
//
//  Created by Viktor Lidholt on 4/9/13.
//
//

#import "RispRenderFoundationSyntaxError.h"

@implementation RispRenderFoundationSyntaxError

@synthesize line, character, code, length, description;

- (void) dealloc
{
    self.description = NULL;
    self.code = NULL;
}

@end
