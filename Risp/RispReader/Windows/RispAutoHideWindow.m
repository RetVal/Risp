//
//  RispAutoHideWindow.m
//  Risp
//
//  Created by closure on 4/25/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RispAutoHideWindow.h"

@implementation NSTrackingArea (updateRect)
- (void)_updateRect:(NSRect)rect {
    uintptr_t pself = (uintptr_t)self;
    pself += sizeof(id);
    NSRect *rectPtr = (NSRect *)pself;
    *rectPtr = rect;
}
@end

@interface RispAutoHideWindow ()
@property (nonatomic, strong, readonly) NSTrackingArea *trackingArea;
@end

@implementation RispAutoHideWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    
    if ( self ) {
        [self setOpaque:NO]; // Needed so we can see through it when we have clear stuff on top
        [self setHasShadow:YES];
        [self setLevel:NSFloatingWindowLevel]; // Let's make it sit on top of everything else
        [self setAlphaValue:0.5]; // It'll start out mostly transparent
    }
    return self;
}

- (void)updateTrackingArea {
    if (_trackingArea) {
        [_trackingArea _updateRect:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)];
//        [[self contentView] removeTrackingArea:_trackingArea];
        return;
    }
    _trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height)
                                                 options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways
                                                   owner:self
                                                userInfo:nil];
    [[self contentView] addTrackingArea:_trackingArea];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self becomeFirstResponder];
    [self setAcceptsMouseMovedEvents:YES];
    [[self contentView] addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self updateTrackingArea];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        [self updateTrackingArea];
    }
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

// If the mouse enters a window, go make sure we fade in
- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[self animator] setAlphaValue:1.0];
    } completionHandler:^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}

// If the mouse exits a window, go make sure we fade out
- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[self animator] setAlphaValue:0.4];
    } completionHandler:^{
        // Stop all calls to moveCursor to suspend the movement of the trackingWin.
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}

@end
