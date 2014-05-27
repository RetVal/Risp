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
    NSArray *values = [RispReaderEvalCore evalCurrentLine:[[_replWindowController inputTextView] string]];
    [values enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) return ;
        [RispReaderEvalCore renderWindowController:_replWindowController resultValue:obj insertNewLine:YES];
    }];
}
@end
