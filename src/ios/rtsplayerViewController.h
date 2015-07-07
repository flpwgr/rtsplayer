//
//  rtsplayerViewController.h
//  ITBVideo
//
//  Created by Felipe Wagner on 7/6/15.
//
//

#import <UIKit/UIKit.h>
#import "videoRTSPlayer.h"

@class rtsplayer;

@interface rtsplayerViewController : UIViewController {
    videoRTSPlayer *video;
    float lastFrameTime;
}

- (IBAction)buttonDismissPressed:(id)sender;

-(IBAction)playButtonAction:(id)sender;

-(void) imageTap;

@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIImageView *videoView;
@property (retain, nonatomic) rtsplayer* origem;
@property (retain, nonatomic) NSString* videoAddress;

@end
