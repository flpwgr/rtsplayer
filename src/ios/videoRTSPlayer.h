//
//  videoRTSPlayer.h
//  ITBVideo
//
//  Created by Felipe Wagner on 7/6/15.
//
//

#import <Foundation/Foundation.h>
#import "avcodec.h"
#import "avformat.h"
#import "swscale.h"

@interface videoRTSPlayer : NSObject {
    AVFormatContext *pFormatCtx;
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVPacket packet;
    AVPicture picture;
    int videoStream;
    int audioStream;
    struct SwsContext *img_convert_ctx;
    int outputWidth, outputHeight;
}

@property (retain,nonatomic) UIImage* currentImage;
-(id) initWithVideo: (NSString*)videoPath;
-(BOOL) stepFrame;
-(void) closeStream;
-(void) seekTime: (double) seconds;

@end
