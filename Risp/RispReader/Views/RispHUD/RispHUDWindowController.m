//
//  RispHUDWindowController.m
//  Risp
//
//  Created by closure on 5/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispHUDWindowController.h"
#import "RispREPLAlphaWindowController.h"

@interface RispHUDWindowController ()

@end

@implementation RispHUDWindowController

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
    [[NSNotificationCenter defaultCenter] addObserverForName:RispREPLAlphaWindowWillCloseNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self close];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setValue:(id)value {
    if ([value isKindOfClass:[NSImage class]]) {
        return;
    }
    if (value == nil) {
        [[self content] setStringValue:@""];
        return;
    }
    
    NSString *content = [NSString stringWithFormat:@"%@\n%@", [_textView string], [value description]];
    [_textView setString:content];
    NSRect old = [_textView frame];
    if ([_textView frame].size.height < [[NSScreen mainScreen] frame].size.height) {
        [_textView sizeToFit];
        if ([_textView frame].size.height >= [[NSScreen mainScreen] frame].size.height) {
            old = [_textView frame];
            old.size.height = [[NSScreen mainScreen] frame].size.height - 20;
            [_textView setFrame:old];
            return;
        }
    }
    
    NSRect newFrame = [_textView frame];
    NSRect frame = [[self window] frame];
    frame.size.height = newFrame.size.height;
    [[self window] setFrame:frame display:YES animate:YES];
}

@end
