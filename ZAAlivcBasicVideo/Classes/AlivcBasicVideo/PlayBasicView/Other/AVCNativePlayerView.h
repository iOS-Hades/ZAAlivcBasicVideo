//
//  AVCNativePlayerView.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/3/15.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPlayerViewControlView.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, ScreenMirrorType)
{
    AirPlayType,
    DLNAType
};

@interface AlivcNativePlayerManager : NSObject

@property (nonatomic, strong, nullable)AVPlayer *nativePlayer;

+ (instancetype)sharedManager;

@end

@interface AVCNativePlayerView : UIView

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url screenMirrorType:(ScreenMirrorType)type;


@property (nonatomic, assign)ScreenMirrorType screenMirrorType;

@property (nonatomic, assign)BOOL isPlay;

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, assign) NSTimeInterval firstSeekTime; // ali播放器当前的播放时间，单位 秒

@property (nonatomic, assign)NSTimeInterval currentPlayTime; // 当前原生播放器播放的时间，单位 秒



- (void)setCurrentTrackInfo:(AVPTrackInfo *)trackInfo; //设置视频当前清晰度
- (void)setListViewTrack:(NSArray *)array; // 设置清晰度列表
- (void)play;
- (void)pause;
- (void)releasePlayer;
- (ScreenMirrorType)getScreenMirrorType;

@end

NS_ASSUME_NONNULL_END
