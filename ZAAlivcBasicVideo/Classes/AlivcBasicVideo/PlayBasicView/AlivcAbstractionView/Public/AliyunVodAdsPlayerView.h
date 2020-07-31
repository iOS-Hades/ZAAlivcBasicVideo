//
//  AliyunVodAdsPlayerView.h
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/13.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import "AliyunPlayerViewProgressView.h"
#import "AliyunPlayerViewControlView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol AliyunVodAdsPlayerViewDelegate <NSObject>

- (void)aliyunVodAdsPlayerViewCompletePlay:(NSTimeInterval)seekTime;

- (void)aliyunVodAdsPlayerViewStartPlay;

@end


@interface AliyunVodAdsPlayerView : UIView

@property (nonatomic, strong)AliPlayer *videoPlayer;

/**
 播放视频的进度条
 */
@property (nonatomic, strong) UISlider *playSlider;
@property (nonatomic, strong) AliyunPlayerViewControlView * controlView;// 用于寻找公用进度条的view

/**
 广告视频地址
 */
@property (nonatomic, copy) NSString *videoAdsUrl;
/**
 广告播放代理
 */
@property (nonatomic, weak) id <AliyunVodAdsPlayerViewDelegate>adsDelegate;// 广告开始和结束播放的代理

/**
 广告视频点击跳入的链接
 */
@property (nonatomic, copy) NSString *adsLink;

/**
 广告播放时间单位秒
 */
@property (nonatomic, assign) NSInteger seconds;

/**
 广告插入时间
 */
@property (nonatomic, strong) NSArray * insertTimeArray;

/**
 已经播放完成的广告数目
 */
@property (nonatomic, assign) NSInteger adsIndex;

/**
 当前是否正在播放广告
 */
@property (nonatomic, assign, readonly) BOOL isPlay;

/**
 开始播放
 */
- (void)startPlay;

/**
 暂停播放
 */
- (void)pausePlay;

/**
 释放播放器
 */
- (void)releaseAdsPlayer;

/**
 当前是否进入广告播放的时间

 @param currentTime 当前视频播放的进度时间，单位毫秒
 @param duration 当前播放的视频总的时间，单位毫秒
 */
- (void)isPlayAdsCurrentTime:(NSTimeInterval)currentTime  duration:(NSTimeInterval)duration;

/**
当前视频是否可以seek

 @param progressValue 当前视频播放的进度百分比，不包含广告的百分比
 @return 是否可以seek
 */
- (CGFloat)allowSeek:(CGFloat)progressValue; // 是否允许seek

/**
 跳到广告页面
 */
- (void)goAdsLink;

/**
 视频seek函数

 @param progressValue 进度
 @return 时间
 */
- (NSTimeInterval)seekWithProgressValue:(CGFloat)progressValue;



/**
 广告播放器重置
 */
- (void)adsReplay;

@end

NS_ASSUME_NONNULL_END
