//
//  CRExifDict.h
//  FinalWebP
//
//  Created by Courser on 23/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRExifDict : NSObject

@property (nonatomic,copy) NSDictionary *tagDict;
@property (nonatomic,copy) NSDictionary *childDict;
@property (nonatomic,copy) NSDictionary *nextDict;
@property (nonatomic,copy) NSDictionary *typeDict;

@end
