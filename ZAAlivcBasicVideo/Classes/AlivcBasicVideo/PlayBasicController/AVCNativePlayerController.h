//
//  AVCNativePlayerController.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/3/27.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import "AliyunPlayerViewQualityListView.h"
#import "AVCNativePlayerView.h"
NS_ASSUME_NONNULL_BEGIN

@interface AVCNativePlayerController : NSObject

@property (nonatomic, weak) AVCNativePlayerView *playView;
@property (nonatomic, strong) AVPlayer *nativePlayer;
@property (nonatomic, strong) UILabel *leftTimeLabel;              
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UISlider  *playSlider;
@property (nonatomic, assign) NSTimeInterval firstSeekTime;
@property (nonatomic, strong) AliyunPlayerViewQualityListView *listView;
@property (nonatomic, strong) NSArray <AVPTrackInfo*> * trackInfoArray;
@property (nonatomic, assign,readonly) NSTimeInterval currentPlayTime;
@end

NS_ASSUME_NONNULL_END
