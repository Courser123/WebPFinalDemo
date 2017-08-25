//
//  UGCImageCoder.h
//  FinalWebP
//
//  Created by Courser on 18/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UGCwebPImageType) {
    UGCwebPImageTypeUnknown = 0, ///< unknown
    UGCwebPImageTypeJPEG,        ///< jpeg, jpg
    UGCwebPImageTypeJPEG2000,    ///< jp2
    UGCwebPImageTypeTIFF,        ///< tiff, tif
    UGCwebPImageTypeBMP,         ///< bmp
    UGCwebPImageTypeICO,         ///< ico
    UGCwebPImageTypeICNS,        ///< icns
    UGCwebPImageTypeGIF,         ///< gif
    UGCwebPImageTypePNG,         ///< png
    UGCwebPImageTypeWebP,        ///< webp
    UGCwebPImageTypeOther,       ///< other image format
};


typedef NS_ENUM(NSUInteger, UGCImageDisposeMethod) {
    
    /**
     No disposal is done on this frame before rendering the next; the contents
     of the canvas are left as is.
     */
    UGCImageDisposeNone = 0,
    
    /**
     The frame's region of the canvas is to be cleared to fully transparent black
     before rendering the next frame.
     */
    UGCImageDisposeBackground,
    
    /**
     The frame's region of the canvas is to be reverted to the previous contents
     before rendering the next frame.
     */
    UGCImageDisposePrevious,
};

/**
 Blend operation specifies how transparent pixels of the current frame are
 blended with those of the previous canvas.
 */
typedef NS_ENUM(NSUInteger, UGCImageBlendOperation) {
    
    /**
     All color components of the frame, including alpha, overwrite the current
     contents of the frame's canvas region.
     */
    UGCImageBlendNone = 0,
    
    /**
     The frame should be composited onto the output buffer based on its alpha.
     */
    UGCImageBlendOver,
};

@interface UGCImageFrame : NSObject <NSCopying>
@property (nonatomic) NSUInteger index;    ///< Frame index (zero based)
@property (nonatomic) NSUInteger width;    ///< Frame width
@property (nonatomic) NSUInteger height;   ///< Frame height
@property (nonatomic) NSUInteger offsetX;  ///< Frame origin.x in canvas (left-bottom based)
@property (nonatomic) NSUInteger offsetY;  ///< Frame origin.y in canvas (left-bottom based)
@property (nonatomic) NSTimeInterval duration;          ///< Frame duration in seconds
@property (nonatomic) UGCImageDisposeMethod dispose;     ///< Frame dispose method.
@property (nonatomic) UGCImageBlendOperation blend;      ///< Frame blend operation.
@property (nullable, nonatomic, strong) UIImage *image; ///< The image.
+ (instancetype _Nullable )frameWithImage:(UIImage *_Nullable)image;
@end


@interface UGCImageDecoder : NSObject

@property (nullable, nonatomic, readonly) NSData *data;    ///< Image data.
@property (nonatomic, readonly) UGCwebPImageType type;          ///< Image data type.
@property (nonatomic, readonly) CGFloat scale;             ///< Image scale.
@property (nonatomic, readonly) NSUInteger frameCount;     ///< Image frame count.
@property (nonatomic, readonly) NSUInteger loopCount;      ///< Image loop count, 0 means infinite.
@property (nonatomic, readonly) NSUInteger width;          ///< Image canvas width.
@property (nonatomic, readonly) NSUInteger height;         ///< Image canvas height.
@property (nonatomic, readonly, getter=isFinalized) BOOL finalized;

@property (nonatomic,copy) NSArray * _Nullable durations;
@property (nonatomic,strong) UGCImageFrame * _Nullable bufferFrame;

- (void)multiThreadGetFrameAtIndex:(NSUInteger)index completedHandle:(void (^_Nullable)(UGCImageFrame *_Nullable))completed;

/**
 Creates an image decoder.
 
 @param scale  Image's scale.
 @return An image decoder.
 */
- (instancetype _Nullable )initWithScale:(CGFloat)scale ;

/**
 Updates the incremental image with new data.
 
 @discussion You can use this method to decode progressive/interlaced/baseline
 image when you do not have the complete image data. The `data` was retained by
 decoder, you should not modify the data in other thread during decoding.
 
 @param data  The data to add to the image decoder. Each time you call this
 function, the 'data' parameter must contain all of the image file data
 accumulated so far.
 
 @param final  A value that specifies whether the data is the final set.
 Pass YES if it is, NO otherwise. When the data is already finalized, you can
 not update the data anymore.
 
 @return Whether succeed.
 */
- (BOOL)updateData:(nullable NSData *)data final:(BOOL)final;

/**
 Convenience method to create a decoder with specified data.
 @param data  Image data.
 @param scale Image's scale.
 @return A new decoder, or nil if an error occurs.
 */
+ (nullable instancetype)decoderWithData:(NSData *_Nullable)data scale:(CGFloat)scale;

/**
 Decodes and returns a frame from a specified index.
 @param index  Frame image index (zero-based).
 @param decodeForDisplay Whether decode the image to memory bitmap for display.
 If NO, it will try to returns the original frame data without blend.
 @return A new frame with image, or nil if an error occurs.
 */
- (nullable UGCImageFrame *)frameAtIndex:(NSUInteger)index decodeForDisplay:(BOOL)decodeForDisplay;

@end

#pragma mark - UIImage

@interface UIImage (UGCImageCoder)

/**
 Decompress this image to bitmap, so when the image is displayed on screen,
 the main thread won't be blocked by additional decode. If the image has already
 been decoded or unable to decode, it just returns itself.
 
 @return an image decoded, or just return itself if no needed.
 @see isDecodedForDisplay
 */
- (instancetype _Nullable )imageByDecoded;

/**
 Wherher the image can be display on screen without additional decoding.
 @warning It just a hint for your code, change it has no other effect.
 */
@property (nonatomic) BOOL isDecodedForDisplay;


@end

