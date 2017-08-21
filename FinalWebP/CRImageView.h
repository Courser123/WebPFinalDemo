//
//  CRImageView.h
//  TestWebP
//
//  Created by Courser on 15/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CRImageView : UIImageView

@property (nonatomic,assign) BOOL isPlaying;

- (void)setImageWithData:(NSData *)data;
- (void)startAnimating;
- (void)pauseAnimating;
- (void)stopAnimating;

@end

@interface WeakProxy : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;

@end
