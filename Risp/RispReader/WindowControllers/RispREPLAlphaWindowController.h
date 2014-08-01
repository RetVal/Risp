//
//  RispREPLAlphaWindowController.h
//  Risp
//
//  Created by closure on 4/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Risp/Risp.h>

@class RispRenderFoundation;
@interface RispREPLAlphaWindowController : NSWindowController

@property (weak) IBOutlet NSView *editorView;
@property (strong) IBOutlet RispRenderFoundation *renderCore;
@property (nonatomic, strong) NSTextView *inputTextView;
@property (nonatomic, strong) NSScrollView *scrollView;

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;

@end

FOUNDATION_EXPORT NSString * RispREPLAlphaWindowWillCloseNotification;
