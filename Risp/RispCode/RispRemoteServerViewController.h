//
//  RispRemoteServerViewController.h
//  Risp
//
//  Created by closure on 7/23/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RispRemoteServerViewController : NSViewController
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *pushButton;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSImageView *imageView;
@end
