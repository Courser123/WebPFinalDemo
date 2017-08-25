//
//  ViewController.m
//  FinalWebP
//
//  Created by Courser on 18/08/2017.
//  Copyright © 2017 Courser. All rights reserved.
//

#import "ViewController.h"
#import "UGCImageCoder.h"
#import "UGCImageView.h"
#import "FCFileManager.h"
#import "NSData+ImageContentType.h"
#import "CRExifParse.h"

@interface ViewController ()

@property (nonatomic,weak) UGCImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UGCImageView *imageView = [[UGCImageView alloc] init];
    self.imageView = imageView;
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_1600" ofType:@"webp"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"pic" ofType:@"webp"];
    NSMutableData *data = [NSMutableData dataWithContentsOfFile:path];
    [self.imageView setImageWithData:data];
    
    CRExifParse *exif = [[CRExifParse alloc] init];
    NSDictionary *dict = [exif exifInfoWithWebPData:data];
    NSLog(@"%@",dict);
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
