//
//  UGCImage.m
//  FinalWebP
//
//  Created by Courser on 18/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import "UGCImage.h"
#import "UGCImageCoder.h"

@implementation UGCImage {
    UGCImageDecoder *_decoder;
    dispatch_semaphore_t _preloadedLock;
}

+ (UGCImage *)imageWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale {
    if (data.length == 0) return nil;
    if (scale <= 0) scale = [UIScreen mainScreen].scale;
    _preloadedLock = dispatch_semaphore_create(1);
    @autoreleasepool {
        UGCImageDecoder *decoder = [UGCImageDecoder decoderWithData:data scale:scale];
        UGCImageFrame *frame = [decoder frameAtIndex:0 decodeForDisplay:YES];
        UIImage *image = frame.image;
        if (!image) return nil;
        self = [self initWithCGImage:image.CGImage scale:decoder.scale orientation:image.imageOrientation];
        if (!self) return nil;
        if (decoder.frameCount > 1) {
            _decoder = decoder;
        }
        self.isDecodedForDisplay = YES;
    }
    return self;
}

@end
