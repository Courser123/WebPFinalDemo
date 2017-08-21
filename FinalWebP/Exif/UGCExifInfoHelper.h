//
//  XLExifInfoHelper.h
//  ExifDemo
//
//  Created by 薛琳 on 16/4/21.
//  Copyright © 2016年 Welson. All rights reserved.
//


@interface UGCExifInfoHelper : NSObject

@property (nonatomic, copy, readonly) NSDictionary *exifDictionary;

- (NSDictionary *)exifInfoWithWebpData:(NSData *)webpData;
- (NSDictionary *)exifInfoWithData:(NSData *)exifData;
- (NSString *)artistInfoWithWebpData:(NSData *)webpData;

@end