//
//  CRExif.h
//  FinalWebP
//
//  Created by Courser on 22/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRExif : NSObject

+ (void)exifInfoWithWebPData:(NSData *)data;

@end
