//
//  rtsplayer.h
//  ITBVideo
//
//  Created by Felipe Wagner on 7/6/15.
//
//

#import <Cordova/CDVPlugin.h>
#import <Foundation/Foundation.h>
#import "rtsplayerViewController.h"

@interface rtsplayer : CDVPlugin

-(void) watchVideo:(CDVInvokedUrlCommand*) command;
-(void) finishOkAndDismiss;

@property (readwrite, assign) BOOL hasPendingOperation;
@property (strong,nonatomic) rtsplayerViewController* overlay;
@property (strong,nonatomic) CDVInvokedUrlCommand* lastCommand;

@end
