//
//  RispRenderWindowController.m
//  Risp
//
//  Created by closure on 4/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispRenderWindowController.h"

@interface RispRenderWindowController ()

@end

@implementation RispRenderWindowController

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
    [_editorView setShowInvisibles:NO];
    [_editorView setMode:RispIDEViewModeClojure];
    [_editorView setTheme:RispIDEViewThemeXcode];
    [_editorView setShowPrintMargin:NO];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
