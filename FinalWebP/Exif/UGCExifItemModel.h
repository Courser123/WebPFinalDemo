//
//  XLExifItemModel.h
//  ExifDemo
//
//  Created by 薛琳 on 16/4/22.
//  Copyright © 2016年 Welson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UGCExifItemModel : NSObject

/*
 * 标识符 如0x013b
 */
@property (nonatomic, copy) NSString *key;

/*
 * 标识符对应字段 如 Orientation
 */
@property (nonatomic, copy) NSString *keyName;

/*
 * 数据类型 0-11 对应字典 dataTypeNameDic
 */
@property (nonatomic, assign) NSInteger type;

/*
 * 数据类型名称 如 unsigned byte
 */
@property (nonatomic, copy) NSString *typeName;

/*
 * 字符串内容
 */
@property (nonatomic, copy) NSString *strValue;

/*
 * 非字符串数据
 */
@property (nonatomic, strong) NSArray<NSNumber *> *fValueArray;
@end
