//
//  CRExif.m
//  FinalWebP
//
//  Created by Courser on 22/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import "CRExif.h"
#import "demux.h"
#import "decode.h"
#import <ImageIO/ImageIO.h>

@implementation CRExif

+ (void)exifInfoWithWebPData:(NSData *)data {
    
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
}

+ (NSDictionary *)handleExifData:(NSData *)data {
    Byte *byte = (Byte *)data.bytes;
    
    NSMutableString *hexStr = [NSMutableString string];
    for (int i = 0 ; i < data.length ; i++) {
        NSString *byteStr = [NSString stringWithFormat:@"%x",byte[i]];
        if (byteStr.length == 2) {
            [hexStr appendString:byteStr];
        }else {
            [hexStr appendFormat:@"0%@",byteStr];
        }
        
    }
    
    NSRange range = [hexStr rangeOfString:@"011a"];
    NSLog(@"%lu",(unsigned long)range.location);
    
    
    
    return nil;
}

@end
