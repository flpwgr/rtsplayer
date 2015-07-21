//
//  videoRTSPlayer.m
//  ITBVideo
//
//  Created by Felipe Wagner on 7/6/15.
//
//

#import "videoRTSPlayer.h"

@implementation videoRTSPlayer

-(id)initWithVideo: (NSString*)moviePath {
    
    if (!(self=[super init])) {
        return nil;
    }
    
    // initialize context and packet
    pFormatCtx = avformat_alloc_context();
    av_init_packet(&packet);
    
    
    // setupVideoContext
    AVCodec         *pCodec;
    
    // Register all formats and codecs
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    
    if (avformat_open_input(&pFormatCtx, [moviePath UTF8String], NULL, NULL) !=0 ) {
        NSLog(@"Couldn't open stream\n");
        return nil;
    }
    
    
    // Retrieve stream information
    if (avformat_find_stream_info(pFormatCtx,NULL) < 0) {
        NSLog(@"Couldn't find stream information\n");
        return nil;
    }
    
    // Find the first video stream
    videoStream=-1;
    
    for (int i=0; i<pFormatCtx->nb_streams; i++) {
        if (pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
            NSLog(@"found video stream");
            videoStream=i;
        }
    }
    
    if(videoStream==-1) {
        return nil;
    }
    
    // Get a pointer to the codec context for the video stream
    pCodecCtx = pFormatCtx->streams[videoStream]->codec;
    
    // Find the decoder for the video stream
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if (pCodec == NULL) {
        NSLog(@"Unsupported codec!\n");
        return nil;
    }
    
    // Open codec
    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
        NSLog(@"Cannot open video decoder");
        return nil;
    }
    
    pCodecCtx->flags2 = CODEC_FLAG2_CHUNKS;
    pCodecCtx->error_concealment = FF_EC_GUESS_MVS | FF_EC_DEBLOCK;
    
    // Allocate video frame
    pFrame = av_frame_alloc();

    
    outputWidth = pCodecCtx->width;
    outputHeight = pCodecCtx->height;
    
    if( outputWidth < 1 || outputHeight < 1) {
        NSLog(@"Failed to get dimensions: %d x %d",outputWidth, outputHeight);
        return nil;
    }
    
    [self setupScaler];
    
    return self;
}

- (UIImage *)currentImage
{
    if (!pFrame->data[0]) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:outputWidth height:outputHeight];
}

- (BOOL)stepFrame
{
    // AVPacket packet;
    int frameFinished=0;
    
    while (!frameFinished && av_read_frame(pFormatCtx, &packet) >=0 ) {
        // Is this a packet from the video stream?
        if(packet.stream_index==videoStream) {
            // Decode video frame
            int len = avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
            if (len < 0 || (packet.flags & AV_PKT_FLAG_CORRUPT)) {
                NSLog(@"Error decoding video");
                return NO;
            }
        }
        
        av_free_packet(&packet);
    }
    
    return frameFinished!=0;
}

- (void)setupScaler
{
    // Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    // Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24, outputWidth, outputHeight);
    
    // Setup scaler
    static int sws_flags =  SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(pCodecCtx->width,
                                     pCodecCtx->height,
                                     pCodecCtx->pix_fmt,
                                     outputWidth,
                                     outputHeight,
                                     PIX_FMT_RGB24,
                                     sws_flags, NULL, NULL, NULL);
    
}

- (void)seekTime:(double)seconds
{
    AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
    avformat_seek_file(pFormatCtx, videoStream, targetFrame, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(pCodecCtx);
}

-(void) closeStream {
    // Free scaler
    sws_freeContext(img_convert_ctx);
    
    // Free RGB picture
    avpicture_free(&picture);
    
    // Free the packet that was allocated by av_read_frame
    av_free_packet(&packet);
    
    // Free the YUV frame
    av_free(pFrame);
    
    // Close the codec
    if (pCodecCtx) avcodec_close(pCodecCtx);
    
    // Close the video file
    if (pFormatCtx) avformat_close_input(&pFormatCtx);
}

- (void)convertFrameToRGB
{
    sws_scale(img_convert_ctx,
              pFrame->data,
              pFrame->linesize,
              0,
              pCodecCtx->height,
              picture.data,
              picture.linesize);
}

- (UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height
{
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

@end
