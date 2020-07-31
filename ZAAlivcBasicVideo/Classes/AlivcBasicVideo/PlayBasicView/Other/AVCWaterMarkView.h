//
//  AVCWaterMarkView.h
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/9.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCWaterMarkView : UIImageView

/**
 水印图片链接
 */
@property (nonatomic, copy) UIImage * waterMarkImage;

/**
 初始化函数

 @param frame 水印坐标
 @param image 水印图片
 @return 水印iimageView
 */
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image ;

@end

NS_ASSUME_NONNULL_END
