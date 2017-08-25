//
//  UGCImageCoder.m
//  FinalWebP
//
//  Created by Courser on 18/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import "UGCImageCoder.h"
#import <ImageIO/ImageIO.h>
//#import <WebP/demux.h>
//#import <WebP/decode.h>
#import "decode.h"
#import "demux.h"
#import <pthread.h>
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Accelerate/Accelerate.h>

#define UGC_FOUR_CC(c1,c2,c3,c4) ((uint32_t)(((c4) << 24) | ((c3) << 16) | ((c2) << 8) | (c1)))
#define UGC_TWO_CC(c1,c2) ((uint16_t)(((c2) << 8) | (c1)))

/**
 Initialize a pthread mutex.
 */
static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define UGCMUTEX_ASSERT_ON_ERROR(x_) do { \
__unused volatile int res = (x_); \
assert(res == 0); \
} while (0)
    assert(mutex != NULL);
    if (!recursive) {
        UGCMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
    } else {
        pthread_mutexattr_t attr;
        UGCMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
        UGCMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
        UGCMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
        UGCMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
    }
#undef UGCMUTEX_ASSERT_ON_ERROR
}


UGCwebPImageType UGCImageDetectType(CFDataRef data) {
    if (!data) return UGCwebPImageTypeUnknown;
    uint64_t length = CFDataGetLength(data);
    if (length < 16) return UGCwebPImageTypeUnknown;
    
    const char *bytes = (char *)CFDataGetBytePtr(data);
    
    uint32_t magic4 = *((uint32_t *)bytes);
    switch (magic4) {
        case UGC_FOUR_CC(0x4D, 0x4D, 0x00, 0x2A): { // big endian TIFF
            return UGCwebPImageTypeTIFF;
        } break;
            
        case UGC_FOUR_CC(0x49, 0x49, 0x2A, 0x00): { // little endian TIFF
            return UGCwebPImageTypeTIFF;
        } break;
            
        case UGC_FOUR_CC(0x00, 0x00, 0x01, 0x00): { // ICO
            return UGCwebPImageTypeICO;
        } break;
            
        case UGC_FOUR_CC(0x00, 0x00, 0x02, 0x00): { // CUR
            return UGCwebPImageTypeICO;
        } break;
            
        case UGC_FOUR_CC('i', 'c', 'n', 's'): { // ICNS
            return UGCwebPImageTypeICNS;
        } break;
            
        case UGC_FOUR_CC('G', 'I', 'F', '8'): { // GIF
            return UGCwebPImageTypeGIF;
        } break;
            
        case UGC_FOUR_CC(0x89, 'P', 'N', 'G'): {  // PNG
            uint32_t tmp = *((uint32_t *)(bytes + 4));
            if (tmp == UGC_FOUR_CC('\r', '\n', 0x1A, '\n')) {
                return UGCwebPImageTypePNG;
            }
        } break;
            
        case UGC_FOUR_CC('R', 'I', 'F', 'F'): { // WebP
            uint32_t tmp = *((uint32_t *)(bytes + 8));
            if (tmp == UGC_FOUR_CC('W', 'E', 'B', 'P')) {
                return UGCwebPImageTypeWebP;
            }
        } break;
            /*
             case UGC_FOUR_CC('B', 'P', 'G', 0xFB): { // BPG
             return UGCwebPImageTypeBPG;
             } break;
             */
    }
    
    uint16_t magic2 = *((uint16_t *)bytes);
    switch (magic2) {
        case UGC_TWO_CC('B', 'A'):
        case UGC_TWO_CC('B', 'M'):
        case UGC_TWO_CC('I', 'C'):
        case UGC_TWO_CC('P', 'I'):
        case UGC_TWO_CC('C', 'I'):
        case UGC_TWO_CC('C', 'P'): { // BMP
            return UGCwebPImageTypeBMP;
        }
        case UGC_TWO_CC(0xFF, 0x4F): { // JPEG2000
            return UGCwebPImageTypeJPEG2000;
        }
    }
    
    // JPG             FF D8 FF
    if (memcmp(bytes,"\377\330\377",3) == 0) return UGCwebPImageTypeJPEG;
    
    // JP2
    if (memcmp(bytes + 4, "\152\120\040\040\015", 5) == 0) return UGCwebPImageTypeJPEG2000;
    
    return UGCwebPImageTypeUnknown;
}

static inline size_t UGCImageByteAlign(size_t size, size_t alignment) {
    return ((size + (alignment - 1)) / alignment) * alignment;
}


CGColorSpaceRef UGCCGColorSpaceGetDeviceRGB() {
    static CGColorSpaceRef space;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        space = CGColorSpaceCreateDeviceRGB();
    });
    return space;
}

static void UGCCGDataProviderReleaseDataCallback(void *info, const void *data, size_t size) {
    if (info) free(info);
}

CGImageRef UGCCGImageCreateDecodedCopy(CGImageRef imageRef, BOOL decodeForDisplay) {
    if (!imageRef) return NULL;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    if (width == 0 || height == 0) return NULL;
    
    if (decodeForDisplay) { //decode with redraw (may lose some precision)
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, UGCCGColorSpaceGetDeviceRGB(), bitmapInfo);
        if (!context) return NULL;
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef newImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        return newImage;
        
    } else {
        CGColorSpaceRef space = CGImageGetColorSpace(imageRef);
        size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
        size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
        size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
        if (bytesPerRow == 0 || width == 0 || height == 0) return NULL;
        
        CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
        if (!dataProvider) return NULL;
        CFDataRef data = CGDataProviderCopyData(dataProvider); // decode
        if (!data) return NULL;
        
        CGDataProviderRef newProvider = CGDataProviderCreateWithCFData(data);
        CFRelease(data);
        if (!newProvider) return NULL;
        
        CGImageRef newImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, space, bitmapInfo, newProvider, NULL, false, kCGRenderingIntentDefault);
        CFRelease(newProvider);
        return newImage;
    }
}

@implementation UGCImageFrame
+ (instancetype)frameWithImage:(UIImage *)image {
    UGCImageFrame *frame = [self new];
    frame.image = image;
    return frame;
}
- (id)copyWithZone:(NSZone *)zone {
    UGCImageFrame *frame = [self.class new];
    frame.index = _index;
    frame.width = _width;
    frame.height = _height;
    frame.offsetX = _offsetX;
    frame.offsetY = _offsetY;
    frame.duration = _duration;
    frame.dispose = _dispose;
    frame.blend = _blend;
    frame.image = _image.copy;
    return frame;
}
@end


@interface _UGCImageDecoderFrame : UGCImageFrame
@property (nonatomic, assign) BOOL hasAlpha;                ///< Whether frame has alpha.
@property (nonatomic, assign) BOOL isFullSize;              ///< Whether frame fill the canvas.
@property (nonatomic, assign) NSUInteger blendFromIndex;    ///< Blend from frame index to current frame.
@end

@implementation _UGCImageDecoderFrame
- (id)copyWithZone:(NSZone *)zone {
    _UGCImageDecoderFrame *frame = [super copyWithZone:zone];
    frame.hasAlpha = _hasAlpha;
    frame.isFullSize = _isFullSize;
    frame.blendFromIndex = _blendFromIndex;
    return frame;
}
@end


@implementation UGCImageDecoder {
    pthread_mutex_t _lock; // recursive lock
    
    BOOL _sourceTypeDetected;
    CGImageSourceRef _source;
    WebPDemuxer *_webpSource;

    UIImageOrientation _orientation;
    dispatch_semaphore_t _framesLock;
    NSArray *_frames; ///< Array<GGImageDecoderFrame>, without image
    BOOL _needBlend;
    NSUInteger _blendFrameIndex;
    CGContextRef _blendCanvas;
    NSUInteger _nextFrame;
}

- (void)multiThreadGetFrameAtIndex:(NSUInteger)index completedHandle:(void (^)(UGCImageFrame *))completed {
    if (_nextFrame == index) return;
    _nextFrame = index;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UGCImageFrame *frame = [weakSelf frameAtIndex:index decodeForDisplay:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(frame);
            }
        });
        self.bufferFrame = frame;
    });
    
}

- (void)dealloc {
    
    if (_source) CFRelease(_source);
    if (_webpSource) WebPDemuxDelete(_webpSource);
    if (_blendCanvas) CFRelease(_blendCanvas);
    pthread_mutex_destroy(&_lock);
}

+ (instancetype)decoderWithData:(NSData *)data scale:(CGFloat)scale {
    if (!data) return nil;
    UGCImageDecoder *decoder = [[UGCImageDecoder alloc] initWithScale:scale];
    [decoder updateData:data final:YES];
    if (decoder.frameCount == 0) return nil;
    return decoder;
}

- (instancetype)init {
    return [self initWithScale:[UIScreen mainScreen].scale];
}

- (instancetype)initWithScale:(CGFloat)scale {
    self = [super init];
    if (scale <= 0) scale = 1;
    _scale = scale;
    _framesLock = dispatch_semaphore_create(1);
    pthread_mutex_init_recursive(&_lock, true);
    return self;
}

- (BOOL)updateData:(NSData *)data final:(BOOL)final {
    BOOL result = NO;
    pthread_mutex_lock(&_lock);
    result = [self _updateData:data final:final];
    pthread_mutex_unlock(&_lock);
    return result;
}

- (UGCImageFrame *)frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay {
    UGCImageFrame *result = nil;
    pthread_mutex_lock(&_lock);
    result = [self _frameAtIndex:index decodeForDisplay:decodeForDisplay];
    pthread_mutex_unlock(&_lock);
    return result;
}

#pragma private (wrap)

- (BOOL)_updateData:(NSData *)data final:(BOOL)final {
    if (_finalized) return NO;
    if (data.length < _data.length) return NO;
    _finalized = final;
    _data = data;
    
    UGCwebPImageType type = UGCImageDetectType((__bridge CFDataRef)data);
    if (_sourceTypeDetected) {
        if (_type != type) {
            return NO;
        } else {
            [self _updateSource];
        }
    } else {
        if (_data.length > 16) {
            _type = type;
            _sourceTypeDetected = YES;
            [self _updateSource];
        }
    }
    return YES;
}

- (UGCImageFrame *)_frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay {
    if (index >= _frames.count) return 0;
    _UGCImageDecoderFrame *frame = [(_UGCImageDecoderFrame *)_frames[index] copy];
    BOOL decoded = NO;
    BOOL extendToCanvas = NO;
    if (_type != UGCwebPImageTypeICO && decodeForDisplay) { // ICO contains multi-size frame and should not extend to canvas.
        extendToCanvas = YES;
    }
    
    if (!_needBlend) {
        CGImageRef imageRef = [self _newUnblendedImageAtIndex:index extendToCanvas:extendToCanvas decoded:&decoded];
        if (!imageRef) return nil;
        if (decodeForDisplay && !decoded) {
            CGImageRef imageRefDecoded = UGCCGImageCreateDecodedCopy(imageRef, YES);
            if (imageRefDecoded) {
                CFRelease(imageRef);
                imageRef = imageRefDecoded;
                decoded = YES;
            }
        }
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:_scale orientation:_orientation];
        CFRelease(imageRef);
        if (!image) return nil;
        image.isDecodedForDisplay = decoded;
        frame.image = image;
        if (index == 0) {
            self.bufferFrame = frame;
        }
        return frame;
    }
    
    // blend
    if (![self _createBlendContextIfNeeded]) return nil;
    CGImageRef imageRef = NULL;
    
    if (_blendFrameIndex + 1 == frame.index) {
        imageRef = [self _newBlendedImageWithFrame:frame];
        _blendFrameIndex = index;
    } else { // should draw canvas from previous frame
        _blendFrameIndex = NSNotFound;
        CGContextClearRect(_blendCanvas, CGRectMake(0, 0, _width, _height));
        
        if (frame.blendFromIndex == frame.index) {
            CGImageRef unblendedImage = [self _newUnblendedImageAtIndex:index extendToCanvas:NO decoded:NULL];
            if (unblendedImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendedImage);
                CFRelease(unblendedImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            if (frame.dispose == UGCImageDisposeBackground) {
                CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
            }
            _blendFrameIndex = index;
        } else { // canvas is not ready
            for (uint32_t i = (uint32_t)frame.blendFromIndex; i <= (uint32_t)frame.index; i++) {
                if (i == frame.index) {
                    if (!imageRef) imageRef = [self _newBlendedImageWithFrame:frame];
                } else {
                    [self _blendImageWithFrame:_frames[i]];
                }
            }
            _blendFrameIndex = index;
        }
    }
    
    if (!imageRef) return nil;
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:_scale orientation:_orientation];
    CFRelease(imageRef);
    if (!image) return nil;
    
    image.isDecodedForDisplay = YES;
    frame.image = image;
    if (extendToCanvas) {
        frame.width = _width;
        frame.height = _height;
        frame.offsetX = 0;
        frame.offsetY = 0;
        frame.dispose = UGCImageDisposeNone;
        frame.blend = UGCImageBlendNone;
    }
    
    if (index == 0) {
        self.bufferFrame = frame;
    }
    
    return frame;
}


#pragma private

- (void)_updateSource {
    [self _updateSourceWebP];
}

- (void)_updateSourceWebP {

    _width = 0;
    _height = 0;
    _loopCount = 0;
    if (_webpSource) WebPDemuxDelete(_webpSource);
    _webpSource = NULL;
    dispatch_semaphore_wait(_framesLock, DISPATCH_TIME_FOREVER);
    _frames = nil;
    dispatch_semaphore_signal(_framesLock);
    
    /*
     https://developers.google.com/speed/webp/docs/api
     The documentation said we can use WebPIDecoder to decode webp progressively,
     but currently it can only returns an empty image (not same as progressive jpegs),
     so we don't use progressive decoding.
     
     When using WebPDecode() to decode multi-frame webp, we will get the error
     "VP8_STATUS_UNSUPPORTED_FEATURE", so we first use WebPDemuxer to unpack it.
     */
    
    WebPData webPData = {0};
    webPData.bytes = _data.bytes;
    webPData.size = _data.length;
    WebPDemuxer *demuxer = WebPDemux(&webPData);
    if (!demuxer) return;
    
    uint32_t webpFrameCount = WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT);
    uint32_t webpLoopCount =  WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT);
    uint32_t canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
    uint32_t canvasHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
    if (webpFrameCount == 0 || canvasWidth < 1 || canvasHeight < 1) {
        WebPDemuxDelete(demuxer);
        return;
    }
    
    NSMutableArray *frames = [NSMutableArray new];
    NSMutableArray *durations = [NSMutableArray new];
    BOOL needBlend = NO;
    uint32_t iterIndex = 0;
    uint32_t lastBlendIndex = 0;
    WebPIterator iter = {0};
    if (WebPDemuxGetFrame(demuxer, 1, &iter)) { // one-based index...
        do {
            _UGCImageDecoderFrame *frame = [_UGCImageDecoderFrame new];
            [frames addObject:frame];
            if (iter.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND) {
                frame.dispose = UGCImageDisposeBackground;
            }
            if (iter.blend_method == WEBP_MUX_BLEND) {
                frame.blend = UGCImageBlendOver;
            }
            
            int canvasWidth = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH);
            int canvasHeight = WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT);
            frame.index = iterIndex;
            frame.duration = iter.duration / 1000.0;
            frame.width = iter.width;
            frame.height = iter.height;
            frame.hasAlpha = iter.has_alpha;
            frame.blend = iter.blend_method == WEBP_MUX_BLEND;
            frame.offsetX = iter.x_offset;
            frame.offsetY = canvasHeight - iter.y_offset - iter.height;
            
            [durations addObject:@(frame.duration)];
            
            BOOL sizeEqualsToCanvas = (iter.width == canvasWidth && iter.height == canvasHeight);
            BOOL offsetIsZero = (iter.x_offset == 0 && iter.y_offset == 0);
            frame.isFullSize = (sizeEqualsToCanvas && offsetIsZero);
            
            if ((!frame.blend || !frame.hasAlpha) && frame.isFullSize) {
                frame.blendFromIndex = lastBlendIndex = iterIndex;
            } else {
                if (frame.dispose && frame.isFullSize) {
                    frame.blendFromIndex = lastBlendIndex;
                    lastBlendIndex = iterIndex + 1;
                } else {
                    frame.blendFromIndex = lastBlendIndex;
                }
            }
            if (frame.index != frame.blendFromIndex) needBlend = YES;
            iterIndex++;
        } while (WebPDemuxNextFrame(&iter));
        WebPDemuxReleaseIterator(&iter);
    }
    
    if (frames.count != webpFrameCount) {
        WebPDemuxDelete(demuxer);
        return;
    }
    
    _width = canvasWidth;
    _height = canvasHeight;
    _frameCount = frames.count;
    _loopCount = webpLoopCount;
    _needBlend = needBlend;
    _webpSource = demuxer;
    dispatch_semaphore_wait(_framesLock, DISPATCH_TIME_FOREVER);
    _frames = frames;
    _durations = durations;
    dispatch_semaphore_signal(_framesLock);

}

#pragma mark -- exif
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"info:%@",info);
}

- (CGImageRef)_newUnblendedImageAtIndex:(NSUInteger)index
                         extendToCanvas:(BOOL)extendToCanvas
                                decoded:(BOOL *)decoded CF_RETURNS_RETAINED {
    
    if (!_finalized && index > 0) return NULL;
    if (_frames.count <= index) return NULL;
//    _UGCImageDecoderFrame *frame = _frames[index];
    
    if (_source) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_source, index, (CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
        if (imageRef && extendToCanvas) {
            size_t width = CGImageGetWidth(imageRef);
            size_t height = CGImageGetHeight(imageRef);
            if (width == _width && height == _height) {
                CGImageRef imageRefExtended = UGCCGImageCreateDecodedCopy(imageRef, YES);
                if (imageRefExtended) {
                    CFRelease(imageRef);
                    imageRef = imageRefExtended;
                    if (decoded) *decoded = YES;
                }
            } else {
                CGContextRef context = CGBitmapContextCreate(NULL, _width, _height, 8, 0, UGCCGColorSpaceGetDeviceRGB(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
                if (context) {
                    CGContextDrawImage(context, CGRectMake(0, _height - height, width, height), imageRef);
                    CGImageRef imageRefExtended = CGBitmapContextCreateImage(context);
                    CFRelease(context);
                    if (imageRefExtended) {
                        CFRelease(imageRef);
                        imageRef = imageRefExtended;
                        if (decoded) *decoded = YES;
                    }
                }
            }
        }
        return imageRef;
    }
    
    if (_webpSource) {
        WebPIterator iter;
        if (!WebPDemuxGetFrame(_webpSource, (int)(index + 1), &iter)) return NULL; // demux webp frame data
        // frame numbers are one-based in webp -----------^
        
        int frameWidth = iter.width;
        int frameHeight = iter.height;
        if (frameWidth < 1 || frameHeight < 1) return NULL;
        
        int width = extendToCanvas ? (int)_width : frameWidth;
        int height = extendToCanvas ? (int)_height : frameHeight;
        if (width > _width || height > _height) return NULL;
        
        const uint8_t *payload = iter.fragment.bytes;
        size_t payloadSize = iter.fragment.size;
        
        WebPDecoderConfig config;
        if (!WebPInitDecoderConfig(&config)) {
            WebPDemuxReleaseIterator(&iter);
            return NULL;
        }
        if (WebPGetFeatures(payload , payloadSize, &config.input) != VP8_STATUS_OK) {
            WebPDemuxReleaseIterator(&iter);
            return NULL;
        }
        
        size_t bitsPerComponent = 8;
        size_t bitsPerPixel = 32;
        size_t bytesPerRow = UGCImageByteAlign(bitsPerPixel / 8 * width, 32);
        size_t length = bytesPerRow * height;
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst; //bgrA
        
        void *pixels = calloc(1, length);
        if (!pixels) {
            WebPDemuxReleaseIterator(&iter);
            return NULL;
        }
        
        config.output.colorspace = MODE_bgrA;
        config.output.is_external_memory = 1;
        config.output.u.RGBA.rgba = pixels;
        config.output.u.RGBA.stride = (int)bytesPerRow;
        config.output.u.RGBA.size = length;
        VP8StatusCode result = WebPDecode(payload, payloadSize, &config); // decode
        if ((result != VP8_STATUS_OK) && (result != VP8_STATUS_NOT_ENOUGH_DATA)) {
            WebPDemuxReleaseIterator(&iter);
            free(pixels);
            return NULL;
        }
        WebPDemuxReleaseIterator(&iter);
        
        if (extendToCanvas && (iter.x_offset != 0 || iter.y_offset != 0)) {
            void *tmp = calloc(1, length);
            if (tmp) {
                vImage_Buffer src = {pixels, height, width, bytesPerRow};
                vImage_Buffer dest = {tmp, height, width, bytesPerRow};
                vImage_CGAffineTransform transform = {1, 0, 0, 1, iter.x_offset, -iter.y_offset};
                uint8_t backColor[4] = {0};
                vImage_Error error = vImageAffineWarpCG_ARGB8888(&src, &dest, NULL, &transform, backColor, kvImageBackgroundColorFill);
                if (error == kvImageNoError) {
                    memcpy(pixels, tmp, length);
                }
                free(tmp);
            }
        }
        
        CGDataProviderRef provider = CGDataProviderCreateWithData(pixels, pixels, length, UGCCGDataProviderReleaseDataCallback);
        if (!provider) {
            free(pixels);
            return NULL;
        }
        pixels = NULL; // hold by provider
        
        CGImageRef image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, UGCCGColorSpaceGetDeviceRGB(), bitmapInfo, provider, NULL, false, kCGRenderingIntentDefault);
        CFRelease(provider);
        if (decoded) *decoded = YES;
        return image;
    }
    
    return NULL;
}

- (BOOL)_createBlendContextIfNeeded {
    if (!_blendCanvas) {
        _blendFrameIndex = NSNotFound;
        _blendCanvas = CGBitmapContextCreate(NULL, _width, _height, 8, 0, UGCCGColorSpaceGetDeviceRGB(), kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    }
    BOOL suc = _blendCanvas != NULL;
    return suc;
}

- (void)_blendImageWithFrame:(_UGCImageDecoderFrame *)frame {
    if (frame.dispose == UGCImageDisposePrevious) {
        // nothing
    } else if (frame.dispose == UGCImageDisposeBackground) {
        CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
    } else { // no dispose
        if (frame.blend == UGCImageBlendOver) {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
        } else {
            CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
        }
    }
}

- (CGImageRef)_newBlendedImageWithFrame:(_UGCImageDecoderFrame *)frame CF_RETURNS_RETAINED{
    CGImageRef imageRef = NULL;
    if (frame.dispose == UGCImageDisposePrevious) {
        if (frame.blend == UGCImageBlendOver) {
            CGImageRef previousImage = CGBitmapContextCreateImage(_blendCanvas);
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            CGContextClearRect(_blendCanvas, CGRectMake(0, 0, _width, _height));
            if (previousImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(0, 0, _width, _height), previousImage);
                CFRelease(previousImage);
            }
        } else {
            CGImageRef previousImage = CGBitmapContextCreateImage(_blendCanvas);
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            CGContextClearRect(_blendCanvas, CGRectMake(0, 0, _width, _height));
            if (previousImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(0, 0, _width, _height), previousImage);
                CFRelease(previousImage);
            }
        }
    } else if (frame.dispose == UGCImageDisposeBackground) {
        if (frame.blend == UGCImageBlendOver) {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
        } else {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
            CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
        }
    } else { // no dispose
        if (frame.blend == UGCImageBlendOver) {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
        } else {
            CGImageRef unblendImage = [self _newUnblendedImageAtIndex:frame.index extendToCanvas:NO decoded:NULL];
            if (unblendImage) {
                CGContextClearRect(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height));
                CGContextDrawImage(_blendCanvas, CGRectMake(frame.offsetX, frame.offsetY, frame.width, frame.height), unblendImage);
                CFRelease(unblendImage);
            }
            imageRef = CGBitmapContextCreateImage(_blendCanvas);
        }
    }
    return imageRef;
}

@end


@implementation UIImage (UGCImageCoder)

- (instancetype)imageByDecoded {
    if (self.isDecodedForDisplay) return self;
    CGImageRef imageRef = self.CGImage;
    if (!imageRef) return self;
    CGImageRef newImageRef = UGCCGImageCreateDecodedCopy(imageRef, YES);
    if (!newImageRef) return self;
    UIImage *newImage = [[self.class alloc] initWithCGImage:newImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(newImageRef);
    if (!newImage) newImage = self; // decode failed, return self.
    newImage.isDecodedForDisplay = YES;
    return newImage;
}

- (BOOL)isDecodedForDisplay {
    if (self.images.count > 1) return YES;
    NSNumber *num = objc_getAssociatedObject(self, @selector(isDecodedForDisplay));
    return [num boolValue];
}

- (void)setIsDecodedForDisplay:(BOOL)isDecodedForDisplay {
    objc_setAssociatedObject(self, @selector(isDecodedForDisplay), @(isDecodedForDisplay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end



