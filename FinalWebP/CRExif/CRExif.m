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
    NSLog(@"%@",data);
    return nil;
}

@end
