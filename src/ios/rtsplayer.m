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

-(void) watch:(CDVInvokedUrlCommand*) command {
    NSString* url = [command argumentAtIndex:0];
    NSString* usr = [command argumentAtIndex:1];
    NSString* pwd = [command argumentAtIndex:2];
    
    url = [url substringFromIndex:[@"rtsp://" length]]; // remove rtsp:// from url
    url = [NSString stringWithFormat:@"rtsp://%@:%@@%@",usr,pwd,url]; // append the usr/pwd
    
    NSLog(@"URL IS: %@", url);
    // avoid webview being released from memory
    self.hasPendingOperation = YES;
    // we use that to respond to the plugin when it finishes
    self.lastCommand = command;
    
    // load the view
    self.overlay = [[rtsplayerViewController alloc] initWithNibName:@"rtsplayerViewController" bundle:nil];
    
    // on the view controller make a reference to this class
    self.overlay.origem = self;
    self.overlay.videoAddress = url;
    
    
    
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

-(void)pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void) onPause {
    NSLog(@"pausou..");
    [self.overlay buttonDismissPressed:nil];
}

@end
