//
//  RispFoundationPrefsWindowController.h
//  Fragaria
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RispRenderFoundationPreferences.h"
#import "RispPrefsWindowController.h"

@interface RispFoundationPrefsWindowController : RispPrefsWindowController {
    IBOutlet NSView *generalView;
    RispRenderFoundationFontsAndColoursPrefsViewController *fontsAndColoursPrefsViewController;
    RispRenderFoundationTextEditingPrefsViewController *textEditingPrefsViewController;
    NSString *toolbarIdentifier;
    NSString *generalIdentifier;
    NSString *textIdentifier;
    NSString *fontIdentifier;
    
}
- (IBAction)revertToStandardSettings:(id)sender;
@end
