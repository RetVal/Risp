//
//  RispHUDWindowController.h
//  Risp
//
//  Created by closure on 5/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MDBorderlessWindow.h"
#import "RispTextFieldVCenteredCell.h"

@interface RispHUDWindowController : NSWindowController
@property (strong) IBOutlet MDBorderlessWindow *hudWindow;
@property (weak) IBOutlet RispTextFieldVCenteredCell *contentCell;
@property (weak) IBOutlet NSTextField *content;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

- (void)setValue:(id)value;
@end
