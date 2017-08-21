//
//  XLExifInfoHelper.m
//  ExifDemo
//
//  Created by 薛琳 on 16/4/21.
//  Copyright © 2016年 Welson. All rights reserved.
//
#import "UGCExifInfoDataProcesser.h"
#import "UGCExifInfoHelper.h"
#import "UGCExifInfoProperties.h"
#import "UGCExifItemModel.h"
//#import <webp/demux.h>
//#import <webp/mux_types.h>
//#import <webp/types.h>
#import "demux.h"
#import "mux_types.h"
#import "types.h"

#define kHeaderSize     8
#define kFlagSize       2
#define kItemTypeSize   2
#define kItemCount      4
#define kOffsetSize     4
#define kItemSize       12

typedef NS_ENUM(NSInteger, TIFFMode) {
    TIFFModeNone,
    TIFFModeIntel,
    TIFFModeMotorola
};

@interface UGCExifInfoHelper()

@property (nonatomic, strong) NSMutableDictionary *internalDic;

@property (nonatomic, assign) TIFFMode tiffMode;
@property (nonatomic, assign) NSUInteger ifdCount;
@property (nonatomic, assign) int currentPos;

//数据处理类
@property (nonatomic, strong) UGCExifInfoDataProcesser *dataProcesser;
@property (nonatomic, strong) UGCExifInfoProperties *dicPorcesser;

//子IFD0和interoperabilityIFD的偏移量
@property (nonatomic, strong) NSNumber *subIFDOffset;
@property (nonatomic, strong) NSNumber *interoperabilityIfdOffset;

@end

@implementation UGCExifInfoHelper

- (instancetype)init {
    if (self = [super init]) {
        _internalDic = [NSMutableDictionary new];
        _dataProcesser = [UGCExifInfoDataProcesser new];
        _dicPorcesser = [UGCExifInfoProperties new];
        _ifdCount = 0;
    }
    return self;
}

- (NSString *)artistInfoWithWebpData:(NSData *)webpData {
    if (self.internalDic.count) {
        UGCExifItemModel *artistModel = [self.internalDic objectForKey:kArtist];
        return artistModel.strValue;
    }
    [self exifInfoWithWebpData:webpData];
    UGCExifItemModel *artistModel = [self.internalDic objectForKey:kArtist];
    return artistModel.strValue;
}

- (NSDictionary *)exifInfoWithWebpData:(NSData *)webpData {
    if (!webpData) return nil;
    
    WebPData inputData = {webpData.bytes, webpData.length};
    WebPDemuxer *demux = WebPDemux(&inputData);
    uint32_t flags = WebPDemuxGetI(demux, WEBP_FF_FORMAT_FLAGS);
    WebPChunkIterator chunk_iter;
    if (flags & EXIF_FLAG) {
        WebPDemuxGetChunk(demux, "EXIF", 1, &chunk_iter);
        NSData *data = [[NSData alloc] initWithBytes:chunk_iter.chunk.bytes length:chunk_iter.chunk.size];
        NSLog(@"%@",data);
        NSDictionary *dictionary = [self exifInfoWithData:data];
        return dictionary;
    }
    WebPDemuxReleaseChunkIterator(&chunk_iter);
    WebPDemuxDelete(demux);
    return nil;
}

- (NSDictionary *)exifInfoWithData:(NSData *)exifData {
    Byte *byte = (Byte *)[exifData bytes];
    if (![self succeedProcessHeaderInfo:byte]) return nil;
    
    NSString *exifIFDOffsetFlag;
    while (![exifIFDOffsetFlag isEqualToString:kExifEndFlag]) {
        [self processEachGroup:byte];
        self.ifdCount ++;
        exifIFDOffsetFlag = [self.dataProcesser hexStrWithByte:byte
                                                      startPos:self.currentPos
                                                        length:2
                                                      readMode:[self dataReadMode]];
        self.currentPos = [self.dataProcesser convertHexStrToInt:exifIFDOffsetFlag];
    }
    
    if (self.subIFDOffset) {
        self.currentPos = [self.subIFDOffset intValue];
        [self processEachGroup:byte];
        self.ifdCount ++;
    }
    if (self.interoperabilityIfdOffset) {
        self.currentPos = [self.interoperabilityIfdOffset intValue];
        [self processEachGroup:byte];
    }
    
    return self.internalDic;
}

- (NSString *)artistInfoWithData:(NSData *)exifData {
    return nil;
}

#pragma mark - private methods

- (void)processEachGroup:(Byte *)byte {
    NSString *itemCountStr = [self.dataProcesser hexStrWithByte:byte
                                                       startPos:self.currentPos
                                                         length:2
                                                       readMode:[self dataReadMode]];
    int itemCount = [self.dataProcesser convertHexStrToInt:itemCountStr];
    self.currentPos += 2;
    
    for (int i = 0; i < itemCount; i++) {
        [self processEachItem:byte];
    }

}

- (void)processEachItem:(Byte *)byte {
    UGCExifItemModel *model = [UGCExifItemModel new];
    NSMutableArray *fValueArray = [NSMutableArray new];
    
    int curPos = self.currentPos;
    NSString *flagStr = [self.dataProcesser hexStrWithByte:byte
                                                  startPos:curPos
                                                    length:kFlagSize
                                                  readMode:[self dataReadMode]];
    model.key = flagStr;
    model.keyName = [self.dicPorcesser.flagNameDictionary objectForKey:flagStr];
    curPos += kFlagSize;
    NSString *itemTypeStr = [self.dataProcesser hexStrWithByte:byte
                                                      startPos:curPos
                                                        length:kItemTypeSize
                                                      readMode:[self dataReadMode]];
    int itemType = [self.dataProcesser convertHexStrToInt:itemTypeStr];
    model.type = itemType;
    model.typeName = [self.dicPorcesser.byteTypeNameDictionary objectForKey:[@(itemType) stringValue]];
    int typeByte = [[self.dicPorcesser.byteTypeDictionary objectForKey:[@(itemType) stringValue]] intValue];
    curPos += kItemTypeSize;
    NSString *itemCountStr = [self.dataProcesser hexStrWithByte:byte
                                                       startPos:curPos
                                                         length:kItemCount
                                                       readMode:[self dataReadMode]];
    int itemCount = [self.dataProcesser convertHexStrToInt:itemCountStr];
    int totalItemBytes = typeByte * itemCount;
    curPos += kItemCount;
    
    NSString *offsetStr = [self.dataProcesser hexStrWithByte:byte
                                                    startPos:curPos
                                                      length:kOffsetSize
                                                    readMode:[self dataReadMode]];
    int offset = [self.dataProcesser convertHexStrToInt:offsetStr];
    
    if ([flagStr isEqualToString:kExifInteroperabilityOffset]) {
        model.strValue = [@(offset) stringValue];
        [fValueArray addObject:@(offset)];
        model.fValueArray = [NSArray arrayWithArray:fValueArray];
        self.interoperabilityIfdOffset = @(offset);

    }else if ([flagStr isEqualToString:kExifOffset]) {
        model.strValue = [@(offset) stringValue];
        [fValueArray addObject:@(offset)];
        model.fValueArray = [NSArray arrayWithArray:fValueArray];
        self.subIFDOffset = @(offset);
    }else if (totalItemBytes <= 4) {
        if (itemType == 2 || itemType == 7) {
            model.strValue = [self.dataProcesser asciiStrWithByte:byte
                                                         startPos:curPos
                                                           length:totalItemBytes];
        }else {
            NSString *hexStr = [self.dataProcesser hexStrWithByte:byte
                                                         startPos:curPos
                                                           length:totalItemBytes
                                                         readMode:[self dataReadMode]];
            [fValueArray addObject:@([self.dataProcesser convertHexStrToInt:hexStr])];
            model.fValueArray = [NSArray arrayWithArray:fValueArray];
            model.strValue = [self.dicPorcesser strValueFromKey:flagStr fValueArray:model.fValueArray];
        }
    }else {
        if (itemType == 2 || itemType == 7) {
            model.strValue = [self.dataProcesser asciiStrWithByte:byte
                                                         startPos:offset
                                                           length:totalItemBytes];
        }else if (itemType == 5) {
            for (int i = 0; i < itemCount; i++) {
                offset += i * itemType;
                NSString *molecule = [self.dataProcesser hexStrWithByte:byte startPos:offset length:typeByte/2 readMode:[self dataReadMode]];
                NSString *denominatorStr = [self.dataProcesser hexStrWithByte:byte startPos:offset + typeByte/2 length:typeByte/2 readMode:[self dataReadMode]];
                ;
                [fValueArray addObject:@([self.dataProcesser convertHexStrToInt:molecule]/(float)[self.dataProcesser convertHexStrToInt:denominatorStr])];
            }
            model.fValueArray = [NSArray arrayWithArray:fValueArray];
            model.strValue = [self.dicPorcesser strValueFromKey:flagStr fValueArray:model.fValueArray];
        }else {
            for (int i = 0; i < itemCount; i++) {
                offset += i * itemType;
                NSString *hexStr = [self.dataProcesser hexStrWithByte:byte
                                                             startPos:offset
                                                               length:typeByte
                                                             readMode:[self dataReadMode]];
                [fValueArray addObject:@([self.dataProcesser convertHexStrToInt:hexStr])];
            }
            model.fValueArray = [NSArray arrayWithArray:fValueArray];
            model.strValue = [self.dicPorcesser strValueFromKey:flagStr fValueArray:model.fValueArray];
        }
    }
    
    [self.internalDic setObject:model forKey:flagStr];
    self.currentPos += kItemSize;
}

- (BOOL)succeedProcessHeaderInfo:(Byte *)byte {
    NSString *tiffModeStr = [self.dataProcesser hexStrWithByte:byte
                                                      startPos:0
                                                        length:2];
    if ([tiffModeStr isEqualToString:kExifTypeIntel]) {
        self.tiffMode = TIFFModeIntel;
    }else if ([tiffModeStr isEqualToString:kExifTypeMotorola]) {
        self.tiffMode = TIFFModeMotorola;
    }else {
        return NO;
    }
    
    NSString *originStr = [self.dataProcesser hexStrWithByte:byte
                                                    startPos:2
                                                      length:2
                                                    readMode:[self dataReadMode]];
    if (![originStr isEqualToString:kExifStartFlag]) return NO;
    
    NSString *offsetStr = [self.dataProcesser hexStrWithByte:byte
                                                    startPos:4
                                                      length:4
                                                    readMode:[self dataReadMode]];
    self.currentPos = [self.dataProcesser convertHexStrToInt:offsetStr];
    return YES;
}

#pragma mark - properties

- (NSDictionary *)exifDictionary {
    return [NSDictionary dictionaryWithDictionary:self.internalDic];
}

- (ExifDataReadMode)dataReadMode {
    return self.tiffMode == TIFFModeIntel?ExifDataReadModeReverse:ExifDataReadModeInOrder;
}

@end
