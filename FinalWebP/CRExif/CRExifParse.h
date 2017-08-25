//
//  CRExifParse.h
//  FinalWebP
//
//  Created by Courser on 22/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRExifParse : NSObject

- (NSDictionary *)exifInfoWithWebPData:(NSData *)data;

@end
