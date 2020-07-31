//
//  AVCWaterMarkView.m
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/9.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AVCWaterMarkView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AliyunUtil.h"

@interface AVCWaterMarkView ()

@property (nonatomic, assign) CGRect selfFrame;
@property (nonatomic, assign) CGFloat rightSpace;
@end

@implementation AVCWaterMarkView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handleDeviceOrientationDidChange:)
        name:UIDeviceOrientationDidChangeNotification object:nil];
        self.frame = frame;
        _selfFrame = frame;
        _rightSpace = ScreenWidth - frame.origin.x - frame.size.width;
        self.contentMode = UIViewContentModeScaleAspectFit;
        if (image) {
            self.image = image;
        }else {
             UIImage *image =  [AlivcImage imageInBasicVideoNamed:@"waterMark"];
             self.image = image;
        }
        
    }
    
    return self;
}

- (void)setWaterMarkImage:(UIImage *)waterMarkImage{
    
    if (waterMarkImage) {
        self.image = waterMarkImage;
    }
    
}

- (void)setFrame {
    
//    CGFloat width = _selfFrame.size.width;
//    CGFloat height = _selfFrame.size.height;
//    CGFloat y = _selfFrame.origin.y;
//    
//    self.frame = CGRectMake(ScreenWidth - _rightSpace - width, y, width, height);
//    
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    [self setFrame];
}

@end
