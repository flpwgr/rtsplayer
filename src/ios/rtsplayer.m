//
//  rtsplayer.m
//  ITBVideo
//
//  Created by Felipe Wagner on 7/6/15.
//
//

#import "rtsplayer.h"

@implementation rtsplayer

-(void) watchVideo:(CDVInvokedUrlCommand*) command {
    // avoid webview being released from memory
    self.hasPendingOperation = YES;
    // we use that to respond to the plugin when it finishes
    self.lastCommand = command;
    
    // load the view
    self.overlay = [[rtsplayerViewController alloc] initWithNibName:@"rtsplayerViewController" bundle:nil];
    
    // on the view controller make a reference to this class
    self.overlay.origem = self;
    self.overlay.videoAddress = [command argumentAtIndex:0];
    NSLog(@"%@",[command argumentAtIndex:0]);
    
    // present the View
    [self.viewController presentViewController:self.overlay animated:YES completion:nil];
}

-(void) finishOkAndDismiss {
    // End the execution
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:self.lastCommand.callbackId];
    
    // dismiss view from stack
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    // Free to go..
    self.hasPendingOperation = NO;
}

@end
