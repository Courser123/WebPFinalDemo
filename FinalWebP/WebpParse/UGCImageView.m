//
//  UGCImageView.m
//  TestWebP
//
//  Created by Courser on 15/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import "UGCImageView.h"
#import "UGCImageCoder.h"

@interface UGCImageView ()

@property (nonatomic,assign) NSUInteger webpCurrentFrameIndex;
@property (nonatomic,assign) NSTimeInterval webpAccumulator;
@property (nonatomic,strong) UIImage *webpAnimatedImage;
@property (nonatomic,strong) UIImage *webpPosterImage;
@property (nonatomic,strong) CADisplayLink *webpDisplayLink;
@property (nonatomic,assign) BOOL webpCurrentAnimating;
@property (nonatomic,assign) BOOL webpNeedsDisplayWhenImageBecomesAvailable;
@property (nonatomic,strong) UGCImageDecoder *decoder;

@end

@implementation UGCImageView

- (instancetype)init {
    if (self = [super init]) {
        _webpNeedsDisplayWhenImageBecomesAvailable = NO;
    }
    return self;
}

- (void)setWebpAnimatedImage:(UIImage *)webpAnimatedImage {
    _webpAnimatedImage = webpAnimatedImage;
    self.image = webpAnimatedImage;
    self.webpPosterImage = webpAnimatedImage;

}

- (void)setImageWithData:(NSData *)data {
    [self reset];
    UGCImageDecoder *decoder = [UGCImageDecoder decoderWithData:data scale:[UIScreen mainScreen].scale];
    self.webpAnimatedImage = [decoder frameAtIndex:0 decodeForDisplay:YES].image;
    _decoder = decoder;
    [self startAnimating];
}

- (void)reset {
    
    if (_webpDisplayLink) {
        _webpDisplayLink.paused = YES;
    }
    self.webpCurrentFrameIndex = 0;
    self.webpAccumulator = 0;
    self.webpAnimatedImage = nil;
    self.webpPosterImage = nil;
    self.webpNeedsDisplayWhenImageBecomesAvailable = NO;
    _decoder = nil;
}

- (BOOL)isPlaying {
    
    if (_webpCurrentAnimating) {
        return YES;
    }else {
        return NO;
    }
}

- (void)startAnimating {
    
    if (_decoder.frameCount > 1) {
        _webpCurrentAnimating = YES;
        if (!_webpDisplayLink) {
            WeakProxy *weakProxy = [WeakProxy weakProxyForObject:self];
            _webpDisplayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(loopWebPImages:)];
            [_webpDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
        _webpDisplayLink.paused = NO;
    }
    
}

- (void)pauseAnimating {
    
    if (_decoder.frameCount > 1) {
        _webpCurrentAnimating = NO;
        if (_webpDisplayLink) {
            _webpDisplayLink.paused = YES;
        }
    }
}

- (void)stopAnimating {
    
    if (_decoder.frameCount > 1) {
        _webpCurrentAnimating = NO;
        if (_webpDisplayLink) {
            _webpDisplayLink.paused = YES;
            [_webpDisplayLink invalidate];
            _webpDisplayLink = nil;
        }
        self.image = self.webpPosterImage;
        self.webpCurrentFrameIndex = 0;
        self.webpAccumulator = 0;
        [_decoder multiThreadGetFrameAtIndex:(self.webpCurrentFrameIndex + 1) % _decoder.frameCount completedHandle:nil];
    }
}

- (void)loopWebPImages:(CADisplayLink *)webpDisplayLink
{
    
    NSTimeInterval delayTime = [_decoder.durations[self.webpCurrentFrameIndex] floatValue];
    if (delayTime) {
        
        UIImage *image = _decoder.bufferFrame.image;
        if (image) {
            if (self.webpNeedsDisplayWhenImageBecomesAvailable) {
                self.image = image;
                [_decoder multiThreadGetFrameAtIndex:(self.webpCurrentFrameIndex + 1) % _decoder.frameCount completedHandle:nil];
                self.webpNeedsDisplayWhenImageBecomesAvailable = NO;
            }
        }
        
        _webpAccumulator += webpDisplayLink.duration;
        while (_webpAccumulator >= delayTime) {
            _webpAccumulator -= delayTime;
            self.webpCurrentFrameIndex++;
            if (self.webpCurrentFrameIndex >= _decoder.frameCount) {
                self.webpCurrentFrameIndex = 0;
            }
            self.webpNeedsDisplayWhenImageBecomesAvailable = YES;
        }
        
    }else {
        self.webpCurrentFrameIndex++;
    }
}

- (void)dealloc {
    
    [_webpDisplayLink invalidate];
    _webpDisplayLink = nil;
}

@end

#pragma mark - WeakProxy

@interface WeakProxy ()

@property (nonatomic, weak) id target;

@end

@implementation WeakProxy

#pragma mark Life Cycle

+ (instancetype)weakProxyForObject:(id)targetObject {
    WeakProxy *weakProxy = [WeakProxy alloc];
    weakProxy.target = targetObject;
    return weakProxy;
}

#pragma mark Forwarding Messages

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}


#pragma mark - NSWeakProxy Method Overrides
#pragma mark Handling Unimplemented Methods

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end

