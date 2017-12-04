//
//  CRExifParse.m
//  FinalWebP
//
//  Created by Courser on 22/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import "CRExifParse.h"
#import "demux.h"
#import "decode.h"
#import <ImageIO/ImageIO.h>
#import "CRExifDict.h"

#define tagItemSize 2
#define tagFormatSize 2
#define dataSize 4
#define tagEnd 4

typedef NS_ENUM(NSUInteger,CRIFDType) {
    CRIFDTypeIFD0,
    CRIFDTypeChildIFD,
    CRIFDTypeIFD1
};

typedef NS_ENUM(NSUInteger,CRIFDMode) {
    CRIFDModeInOrder,
    CRIFDModeReverse
};

@interface CRExifParse ()

@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,copy) NSDictionary *tagDict;
@property (nonatomic,copy) NSDictionary *nextDict;
@property (nonatomic,copy) NSDictionary *typeDict;
@property (nonatomic,copy) NSDictionary *childDict;
@property (nonatomic,strong) NSMutableDictionary *resultDict;
@property (nonatomic,assign) NSUInteger childIndex;
@property (nonatomic,assign) NSUInteger loopCount;
@property (nonatomic,strong) NSMutableArray *addressArray;
@property (nonatomic,assign) CRIFDMode mode;

@end

@implementation CRExifParse

- (instancetype)init {
    if (self = [super init]) {
        CRExifDict *dict = [[CRExifDict alloc] init];
        _tagDict = dict.tagDict;
        _nextDict = dict.nextDict;
        _typeDict = dict.typeDict;
        _childDict = dict.childDict;
        _loopCount = 0;
        _addressArray = [NSMutableArray array];
        _resultDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)exifInfoWithWebPData:(NSData *)data {
    
    WebPData webpData = {data.bytes, data.length};
    WebPDemuxer *demux = WebPDemux(&webpData);
    uint32_t flags = WebPDemuxGetI(demux, WEBP_FF_FORMAT_FLAGS);
    WebPChunkIterator iter;
    if (flags & EXIF_FLAG) {
        WebPDemuxGetChunk(demux,"EXIF", 1, &iter);
        NSData *data = [NSData dataWithBytes:iter.chunk.bytes length:iter.chunk.size];
        [self handleExifData:data];
    }
    WebPDemuxReleaseChunkIterator(&iter);
    WebPDemuxDelete(demux);
    
    return _resultDict;
}

- (void)handleExifData:(NSData *)data {
    kCGImagePropertyExifOECF
    Byte *byte = (Byte *)data.bytes;
    self.mode = [self getExifDataMode:byte];
    
    NSArray *arr = [self getList:byte fromIndex:4];
    
    for (int i = 0 ; i < arr.count; i++) {
        NSString *str = [self convertByteToHexStr:byte fromIndex:[arr[i] integerValue] length:2];
        self.index = [arr[i] integerValue] + 2;
        NSUInteger num = [self convertHexstrToInteger:str];
        for (NSUInteger k = 0 ; k < num ; k++) {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (i == 0) {
                    [self handleEachTag:byte fromIndex:self.index type:CRIFDTypeIFD0];
                }else if (i == 1) {
                    [self handleEachTag:byte fromIndex:self.index type:CRIFDTypeIFD1];
                }
            });
        }
    }
}

- (CRIFDMode)getExifDataMode:(Byte *)byte {
    
    NSMutableString *hexStr = [NSMutableString string];
    for (NSUInteger i = 0; i < 4; i++) {
        NSString *byteStr = [NSString stringWithFormat:@"%x",byte[i]];
        if (byteStr.length == 2) {
            [hexStr appendString:byteStr];
        }else {
            [hexStr appendFormat:@"0%@",byteStr];
        }
    }
    
    if ([hexStr isEqualToString:@"4d4d002a"]) {
        return CRIFDModeInOrder;
    }else {
        return CRIFDModeReverse;
    }
    
}

- (NSArray *)getList:(Byte *)byte fromIndex:(NSUInteger)index {
    
    NSUInteger address = [self convertByteToRealInteger:byte fromIndex:index length:4];
    if (address > 0) {
        index = index + 4;
        NSUInteger num = [self convertByteToRealInteger:byte fromIndex:index length:2];
        if (num > 0) {
            [_addressArray addObject:@(address)];
            index = index + 2;
            NSUInteger temp = num * 12;
            [self getList:byte fromIndex:index + temp];
        }
    }
    
    return _addressArray.copy;
}

- (void)handleEachTag:(Byte *)byte fromIndex:(NSUInteger)index type:(CRIFDType)IFDType {
    
    NSUInteger tempIndex  = index;
    
    NSString *hexStr = [self convertByteToHexStr:byte fromIndex:tempIndex length:2];
    NSString *key;
    
    switch (IFDType) {
            case CRIFDTypeIFD0:
            key = [self.tagDict objectForKey:hexStr];
            break;
            case CRIFDTypeChildIFD:
            key = [self.childDict objectForKey:hexStr];
            break;
            case CRIFDTypeIFD1:
            key = [self.nextDict objectForKey:hexStr];
        default:
            break;
    }

    if (!key) {
        tempIndex += tagItemSize;
        switch (IFDType) {
                case CRIFDTypeIFD0:
                self.index = tempIndex;
                break;
                case CRIFDTypeChildIFD:
                self.childIndex = tempIndex;
                break;
                case CRIFDTypeIFD1:
                self.index = tempIndex;
            default:
                break;
        }
        return;
    }
    
    tempIndex += tagItemSize;
    
    NSString *type = [self convertByteToHexStr:byte fromIndex:tempIndex length:2];
    NSString *typeStr = [self convertHexstrToNoneZeroStr:type];
    NSInteger typeSize = [[self.typeDict objectForKey:typeStr] integerValue];
    tempIndex += tagFormatSize;
    
    NSString *typeNumStr = [self convertByteToHexStr:byte fromIndex:tempIndex length:4];
    NSInteger typeNum = [self convertHexstrToInteger:typeNumStr];
    tempIndex += dataSize;
    
    NSInteger totalNum = typeNum * typeSize;
    if (totalNum > 4) {
        NSUInteger num = [self convertByteToRealInteger:byte fromIndex:tempIndex length:4];
        if (typeStr.intValue == 2 || typeStr.intValue == 7) {
            if ([key isEqualToString:@"ComponentsConfiguration"] || [key isEqualToString:@"SceneType"]) {
                NSString *config = [self convertByteToHexStr:byte fromIndex:num length:totalNum];
                [_resultDict setObject:config forKey:key];
            }else {
                NSString *str = [self asciiStrWithByte:byte startPos:num length:totalNum];
                [_resultDict setObject:str forKey:key];
            }
        }else if (typeStr.intValue == 5 || typeStr.intValue == 10) {
            NSUInteger num1 = [self convertByteToRealInteger:byte fromIndex:num length:totalNum * 0.5];
            NSUInteger num2 = [self convertByteToRealInteger:byte fromIndex:num + totalNum * 0.5 length:totalNum * 0.5];
            CGFloat res = num1 * 1.0 / num2;
            [_resultDict setObject:@(res) forKey:key];
        }else {
            NSUInteger n = [self convertByteToRealInteger:byte fromIndex:num length:totalNum];
            [_resultDict setObject:@(n) forKey:key];
        }
    }else {
        if (typeStr.intValue == 2 || typeStr.intValue == 7) {
            if ([key isEqualToString:@"ComponentsConfiguration"] || [key isEqualToString:@"SceneType"]) {
                NSString *config = [self convertByteToHexStr:byte fromIndex:tempIndex length:totalNum];
                [_resultDict setObject:config forKey:key];
            }else {
                NSString *str = [self asciiStrWithByte:byte startPos:tempIndex length:totalNum];
                [_resultDict setObject:str forKey:key];
            }
        }else if (typeStr.intValue == 5 || typeStr.intValue == 10) {
            NSUInteger num1 = [self convertByteToRealInteger:byte fromIndex:tempIndex length:totalNum * 0.5];
            NSUInteger num2 = [self convertByteToRealInteger:byte fromIndex:tempIndex + totalNum * 0.5 length:totalNum * 0.5];
            CGFloat res = num1 * 1.0 / num2;
            [_resultDict setObject:@(res) forKey:key];
        }else {
            NSUInteger n = [self convertByteToRealInteger:byte fromIndex:tempIndex length:totalNum];
            [_resultDict setObject:@(n) forKey:key];
            if ([key isEqualToString:@"ExifOffset"]) {
                self.childIndex = n;
                NSUInteger num = [self convertByteToRealInteger:byte fromIndex:n length:2];
                self.childIndex += 2;
                for (NSUInteger i = 0 ; i < num; i++) {
                    [self handleEachTag:byte fromIndex:self.childIndex type:CRIFDTypeChildIFD];
                }
            }
        }
    }
    
    tempIndex += tagEnd;
    
    switch (IFDType) {
            case CRIFDTypeIFD0:
            self.index = tempIndex;
            break;
            case CRIFDTypeChildIFD:
            self.childIndex = tempIndex;
            break;
            case CRIFDTypeIFD1:
            self.index = tempIndex;
        default:
            break;
    }
    
}

// 将byte转换成16进制字符串
- (NSString *)convertByteToHexStr:(Byte *)byte fromIndex:(NSUInteger)index length:(NSUInteger)length {
    
    NSMutableString *hexStr = [NSMutableString string];
    if (self.mode == CRIFDModeInOrder) {
        for (NSInteger i = index ; i < index + length; i++) {
            NSString *byteStr = [NSString stringWithFormat:@"%x",byte[i]];
            if (byteStr.length == 2) {
                [hexStr appendString:byteStr];
            }else {
                [hexStr appendFormat:@"0%@",byteStr];
            }
        }
        return hexStr.copy;
    }else {
        for (NSUInteger i = index + length ; i > index ; i--) {
            NSString *byteStr = [NSString stringWithFormat:@"%x",byte[i]];
            if (byteStr.length == 2) {
                [hexStr appendString:byteStr];
            }else {
                [hexStr appendFormat:@"0%@",byteStr];
            }
        }
        return hexStr.copy;
    }
}

// 将byte转换为16进制数字
- (NSUInteger)convertByteToInteger:(Byte *)byte fromIndex:(NSUInteger)index length:(NSUInteger)length {
    
    NSString *hexStr = [self convertByteToHexStr:byte fromIndex:index length:length];
    
    return [hexStr integerValue];
}

// 将byte转换成10进制数字
- (NSUInteger)convertByteToRealInteger:(Byte *)byte fromIndex:(NSUInteger)index length:(NSUInteger)length {
    
    NSString *hexStr = [self convertByteToHexStr:byte fromIndex:index length:length];
    
    return [self convertHexstrToInteger:hexStr];
}

// 将16进制字符串转换为10进制数字
- (NSUInteger)convertHexstrToInteger:(NSString *)string {
    if (!string.length) return 0;
    return strtoul([string UTF8String], 0, 16);
}

// 16进制字符串去0
- (NSString *)convertHexstrToNoneZeroStr:(NSString *)hexStr {
    if (!hexStr.length) return nil;
    NSUInteger num = strtoul([hexStr UTF8String], 0, 16);
    return [NSString stringWithFormat:@"%lu",num];
}

// 将byte转换成ASCII字符
- (NSString *)asciiStrWithByte:(Byte *)byte
                      startPos:(NSUInteger)st
                        length:(NSUInteger)length {
    NSMutableString *asciiStr = [[NSMutableString alloc] initWithCapacity:length];
    for (NSUInteger i = st; i < st + length; i++) {
        NSString *byteStr = [NSString stringWithFormat:@"%c",(int)[self convertHexstrToInteger:[self convertByteToHexStr:byte fromIndex:i length:1]]];
        [asciiStr appendString:byteStr];
    }
    
    return asciiStr;
    // 其实值一直存在,不过有时候po不出来
//    if (![asciiStr isEqualToString:@""]) {
//        return asciiStr;
//    }else {
//        return [self convertByteToHexStr:byte fromIndex:st length:length];
//    }
}


@end
