//
//  RispREPLAlphaWindowController.m
//  Risp
//
//  Created by closure on 4/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispREPLAlphaWindowController.h"
#import <RispRenderFoundation/RispRenderFoundation.h>
@interface RispREPLAlphaWindowController ()
@end

@implementation RispREPLAlphaWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    [_renderCore setSyntaxColoured:YES];
//    [_renderCore setObject:@YES forKey:ro_MGSFOSyntaxColouring];
    [_renderCore setObject:self forKey:RispRenderFoundationFODelegate];
    [_renderCore embedInView:_editorView];
    [_renderCore setObject:@"Risp" forKey:@"syntaxDefinition"];
    _scrollView = [_renderCore objectForKey:ro_MGSFOScrollView];
    _inputeView = [_renderCore objectForKey:ro_MGSFOTextView];
    [[self window] setRepresentedFilename:@"RispReader"];
    [[[self window] standardWindowButton:NSWindowDocumentIconButton] setImage:[NSApp applicationIconImage]];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
