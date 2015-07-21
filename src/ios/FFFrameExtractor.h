//
//  FFFrameExtractor.h
//  LiluCam
//
//  Created by Takashi Okamoto on 12/15/13.
//  Copyright (c) 2013 Takashi Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FFFrameExtractorDelegate <NSObject>

@required
- (void)updateWithCurrentUIImage:(UIImage *)image;

@end


@interface FFFrameExtractor : NSObject

- (id)initWithInputPath:(NSString *)path;
- (BOOL)start;
- (BOOL)stop;
- (BOOL)nextFrame;
- (UIImage *)frameImage;
- (void)processNextFrame;

@property (strong, nonatomic) NSString *inputPath;
@property (weak, nonatomic) id delegate;

@end
