//
//  XLExifInfoDataProcesser.h
//  ExifDemo
//
//  Created by 薛琳 on 16/4/21.
//  Copyright © 2016年 Welson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ExifDataReadMode) {
    ExifDataReadModeInOrder,
    ExifDataReadModeReverse
};

@interface UGCExifInfoDataProcesser : NSObject

- (int)convertHexStrToInt:(NSString *)hex;

- (NSString *)hexStrWithData:(NSData *)data;
- (NSString *)hexStrWithData:(NSData *)data
                    startPos:(int)st
                      length:(int)length;
- (NSString *)hexStrWithData:(NSData *)data
                    startPos:(int)st
                      length:(int)length
                    readMode:(ExifDataReadMode)mode;
- (NSString *)hexStrWithByte:(Byte *)byte
                    startPos:(int)st
                      length:(int)length;
- (NSString *)hexStrWithByte:(Byte *)byte
                    startPos:(int)st
                      length:(int)length
                    readMode:(ExifDataReadMode)mode;

- (NSString *)asciiStrWithData:(NSData *)data;
- (NSString *)asciiStrWithData:(NSData *)data
                      startPos:(int)st
                        length:(int)length;
- (NSString *)asciiStrWithByte:(Byte *)byte
                      startPos:(int)st
                        length:(int)length;

@end
