//
//  AVCThrowScreenView.h
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/9.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

#define SwitchPlayer @"SwitchPlayer"

@protocol AVCAirPlayDelegate <NSObject>

- (void)airPlayViewPlayPauseWithInterrupt;
- (void)airPlayViewPlayResume;

@end


@interface AVCAirPlayView : MPVolumeView

@property (nonatomic, weak) id <AVCAirPlayDelegate> delegate;

+ (instancetype)airPlayViewWithFrame:(CGRect)rect image:(UIImage *)image;
- (void)setText:(NSString *)text;
- (NSString*)activeAirplayOutputRouteName; //返回当前输出端口
// 弹出系统的AirPlayView
- (void)showAirplayView;

@end

NS_ASSUME_NONNULL_END
