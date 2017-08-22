//
//  ViewController.m
//  FinalWebP
//
//  Created by Courser on 18/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import "ViewController.h"
#import "UGCImageCoder.h"
#import "CRImageView.h"
#import "FCFileManager.h"
#import "UGCExifInfoHelper.h"
#import "UGCExifItemModel.h"
#import "NSData+ImageContentType.h"

@interface ViewController ()

@property (nonatomic,weak) CRImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CRImageView *imageView = [[CRImageView alloc] init];
    self.imageView = imageView;
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"webp_test" ofType:@"webp"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self.imageView setImageWithData:data];
    
    UGCExifInfoHelper *helper = [[UGCExifInfoHelper alloc] init];
    NSDictionary *dict = [helper exifInfoWithWebpData:data];
    NSLog(@"%@",dict);
    
//    [NSData sd_imageFormatForImageData:data];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.imageView.isPlaying) {
        [self.imageView pauseAnimating];
    }else {
        [self.imageView startAnimating];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
