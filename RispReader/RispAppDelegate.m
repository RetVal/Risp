//
//  RispAppDelegate.m
//  RispReader
//
//  Created by closure on 4/15/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispAppDelegate.h"
#import <Risp/RispSymbol.h>
#import <Risp/RispList.h>

#import "RispRenderWindowController.h"
#import "RispREPLAlphaWindowController.h"

#import "RispReaderEvalCore.h"

@interface RispAppDelegate ()
@property (nonatomic, strong) RispRenderWindowController *rootWindowController;
@property (nonatomic, strong) RispREPLAlphaWindowController *replWindowController;
@end

@implementation RispAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    _rootWindowController = [[RispRenderWindowController alloc] initWithWindowNibName:@"RispRenderWindowController"];
//    [[_rootWindowController window] makeKeyAndOrderFront:nil];
    _replWindowController = [[RispREPLAlphaWindowController alloc] initWithWindowNibName:@"RispREPLAlphaWindowController"];
    [[_replWindowController window] makeKeyAndOrderFront:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (IBAction)evalCurrentLine:(id)sender {
    [RispReaderEvalCore evalCurrentLine:[[_replWindowController inputeView] string]];
}
@end
