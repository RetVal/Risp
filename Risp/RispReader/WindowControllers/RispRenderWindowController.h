//
//  RispRenderWindowController.h
//  Risp
//
//  Created by closure on 4/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RispIDEView/RispIDEView.h>
@interface RispRenderWindowController : NSWindowController
@property (weak) IBOutlet RispIDEView *editorView;

@end
