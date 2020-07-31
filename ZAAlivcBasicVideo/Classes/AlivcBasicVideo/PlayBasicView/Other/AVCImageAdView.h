//
//  AVCImageAdView.h
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunPlayer/AliyunPlayer.h>
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    StartStatus,
    PauseStatus,
} AdsStatus;

@interface AVCImageAdView : UIImageView

@property (nonatomic, strong)AliPlayer *player;
/**
 开始计时秒数
 */
@property (nonatomic, assign) NSInteger countNum;
/**
 广告链接
 */
@property (nonatomic, copy) NSString *adsLink;
/**
 关闭广告执行的block
 */
@property (nonatomic, copy) void(^close)(void);

/**
 返回执行的block
 */
@property (nonatomic, copy) void(^goback)(void);

/**
 初始化函数

 @param image 广告图片
 @param status 状态 暂停或者开始播放
 @return imageAdView
 */
- (instancetype)initWithImage:(UIImage *)image status:(AdsStatus) status inView:(UIView *)view;

// 适配XR
- (void)setFrame;

- (void)pauseAds;

- (BOOL)reviveAds;

- (void)releaseTimer;

@end

NS_ASSUME_NONNULL_END
