//
//  AlivcVideoPlayDLNAViewController.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/10.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRDLNA.h"
#import "AVCNativePlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcVideoPlayDLNAController : NSObject
 
@property (nonatomic, strong) CLUPnPDevice *model;
@property (nonatomic, weak) AVCNativePlayerView *playView;
@property (nonatomic, strong) AVPlayer *nativePlayer;
@property (nonatomic, strong) AliyunPlayerViewQualityListView *listView;
@property (nonatomic, strong) NSArray <AVPTrackInfo*> * trackInfoArray;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UISlider  *playSlider;
@property (nonatomic, assign) NSTimeInterval firstSeekTime;
@property (nonatomic, assign,readonly) NSTimeInterval currentPlayTime;


- (void)DLNASeekToTime:(NSTimeInterval)time; //seek
- (void)playUrl:(NSString *)playUrl;
@end

NS_ASSUME_NONNULL_END
