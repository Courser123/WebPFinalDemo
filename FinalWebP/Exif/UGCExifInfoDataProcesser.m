//
//  XLExifInfoDataProcesser.m
//  ExifDemo
//
//  Created by 薛琳 on 16/4/21.
//  Copyright © 2016年 Welson. All rights reserved.
//
#import "UGCExifInfoDataProcesser.h"

@implementation UGCExifInfoDataProcesser

- (int)convertHexStrToInt:(NSString *)hex {
    if (!hex.length) return 0;
    return (int)strtoul([hex UTF8String], 0, 16);
}

- (NSString *)hexStrWithData:(NSData *)data {
    int length = (int)data.length;
    return [self hexStrWithData:data
                       startPos:0
                         length:length];
}

- (NSString *)hexStrWithData:(NSData *)data
                    startPos:(int)st
                      length:(int)length {
    return [self hexStrWithData:data
                       startPos:st
                         length:length
                       readMode:ExifDataReadModeInOrder];
}

- (NSString *)hexStrWithData:(NSData *)data
                    startPos:(int)st
                      length:(int)length
                    readMode:(ExifDataReadMode)mode {
    Byte *byte = (Byte *)[data bytes];
    return [self hexStrWithByte:byte
                       startPos:st
                         length:length
                       readMode:mode];
}

- (NSString *)hexStrWithByte:(Byte *)byte
                    startPos:(int)st
                      length:(int)length {
    return [self hexStrWithByte:byte
                       startPos:st
                         length:length
                       readMode:ExifDataReadModeInOrder];
}

- (NSString *)hexStrWithByte:(Byte *)byte
                    startPos:(int)st
                      length:(int)length
                    readMode:(ExifDataReadMode)mode {
    NSMutableString *hexStr = [[NSMutableString alloc] initWithCapacity:length];
    switch (mode) {
        case ExifDataReadModeReverse:
            for (int i = (st + length) - 1; i >= st; i--) {
                NSString *byteStr = [NSString stringWithFormat:@"%x",(byte[i] & 0xff)];
                if ([byteStr length] == 2) {
                    [hexStr appendString:byteStr];
                }else {
                    [hexStr appendFormat:@"0%@", byteStr];
                }
            }
            break;
        case ExifDataReadModeInOrder:
            for (int i = st; i < st + length; i++) {
                NSString *byteStr = [NSString stringWithFormat:@"%x",(byte[i] & 0xff)];
                if ([byteStr length] == 2) {
                    [hexStr appendString:byteStr];
                }else {
                    [hexStr appendFormat:@"0%@", byteStr];
                }
            }
            break;
        default:
            break;
    }
    return hexStr;
}

- (NSString *)asciiStrWithData:(NSData *)data {
    Byte *byte = (Byte *)[data bytes];
    int length = (int)data.length;
    return [self asciiStrWithByte:byte
                         startPos:0
                           length:length];
}

- (NSString *)asciiStrWithData:(NSData *)data
                      startPos:(int)st
                        length:(int)length {
    Byte *byte = (Byte *)[data bytes];
    return [self asciiStrWithByte:byte
                         startPos:st
                           length:length];
}

- (NSString *)asciiStrWithByte:(Byte *)byte
                      startPos:(int)st
                        length:(int)length {
    NSMutableString *asciiStr = [[NSMutableString alloc] initWithCapacity:length];
    for (int i = st; i < st + length; i++) {
        NSString *byteStr = [NSString stringWithFormat:@"%c",[self convertHexStrToInt:[self hexStrWithByte:byte startPos:i length:1]]];
        [asciiStr appendString:byteStr];
    }
    return asciiStr;
}

@end