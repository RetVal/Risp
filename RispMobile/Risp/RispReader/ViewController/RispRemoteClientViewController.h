//
//  RispRemoteClientViewController.h
//  Risp
//
//  Created by closure on 7/29/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"

@class RispRemoteClientViewController;

@protocol RispRemoteClientViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(RispRemoteClientViewController *)vc;

@end

@interface RispRemoteClientViewController : JSQMessagesViewController

@property (weak, nonatomic) id<RispRemoteClientViewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

- (BOOL)ready;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;
@end
