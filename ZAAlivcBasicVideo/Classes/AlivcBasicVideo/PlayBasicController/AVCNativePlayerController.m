//
//  AVCNativePlayerController.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/3/27.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "AVCNativePlayerController.h"

#import "NSString+AlivcHelper.h"
@interface AVCNativePlayerController ()<AliyunPVQualityListViewDelegate>

@property (nonatomic, assign) BOOL  hasFirstSeek;
@property (nonatomic, assign) BOOL  finishedSeek;
@property (nonatomic, assign) BOOL  switchQuality;
@property (nonatomic, strong) UIButton * qualityButton;
@property (nonatomic, assign) NSTimeInterval currentSeekTime;


@end


@implementation AVCNativePlayerController


- (instancetype)init {
    if (self =[super init]) {
        _hasFirstSeek = NO;
        _finishedSeek = YES;
        _switchQuality = NO;
    }
    
    return self;
}
// 播放按钮
- (void)playButtonClicked:(UIButton *)button {
    
    button.selected = !button.selected;
    if (button.selected) {
        [self.nativePlayer play];
    }else {
        [self.nativePlayer pause];
    }
    
}

- (void)seekVideo:(UISlider *)slider  {
    
    _finishedSeek = NO;
    
    CGFloat progress = slider.value;
    NSLog(@"%f",slider.value);
    NSTimeInterval duration = self.nativePlayer.currentItem.duration.value/self.nativePlayer.currentItem.duration.timescale;
    NSTimeInterval currentTimeSec = duration* progress;
   
    CMTime startTime = CMTimeMakeWithSeconds(currentTimeSec, self.nativePlayer.currentTime.timescale);
    [self.nativePlayer seekToTime:startTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000)completionHandler:^(BOOL finished) {
        if (finished) {
            _finishedSeek = YES;
        }
        
    }];
    
    
}

// 拖动进度条
- (void)updateProgressSliderAction:(UISlider *)slider {
    
    CGFloat progress = slider.value;
    NSLog(@"%f",slider.value);
    NSTimeInterval duration = self.nativePlayer.currentItem.duration.value/self.nativePlayer.currentItem.duration.timescale;
    NSTimeInterval currentTimeSec = duration* progress;
    NSString *curTimeStr = [AliyunUtil timeformatFromSeconds:roundf(currentTimeSec *1000)];
    NSString *totalTimeStr = [AliyunUtil timeformatFromSeconds:roundf(duration *1000)];
    self.rightTimeLabel.text = totalTimeStr;
    self.leftTimeLabel.text = curTimeStr;
    NSLog(@"airplay～～拖动进度条毫秒seek: %@",curTimeStr);
}

// 全屏按钮
- (void)fullScreenButtonClicked:(UIButton *)sender{

        [AliyunUtil setFullOrHalfScreen];
}


// 定时器更新进度条
- (void)updateProgressValue {
 
    if (_finishedSeek == NO) {
        return;
    }
    
   
    if (self.nativePlayer.status == AVPlayerStatusReadyToPlay && self.hasFirstSeek == NO) {
        _hasFirstSeek = YES;
        if (self.firstSeekTime >0) {
            CMTime startTime = CMTimeMakeWithSeconds(self.firstSeekTime, self.nativePlayer.currentItem.currentTime.timescale);
            [self.nativePlayer seekToTime:startTime completionHandler:^(BOOL finished) {
                NSLog(@"finishe seek");
            }];
        }
        
    }else if (self.nativePlayer.status == AVPlayerStatusReadyToPlay && self.switchQuality == YES){
        _switchQuality = NO;
        if (self.currentSeekTime >0) {
            CMTime startTime = CMTimeMakeWithSeconds(self.currentSeekTime, self.nativePlayer.currentItem.currentTime.timescale);
            [self.nativePlayer seekToTime:startTime completionHandler:^(BOOL finished) {
                NSLog(@"finishe seek");
            }];
        }
        
    }else {
    
    NSTimeInterval duration = self.nativePlayer.currentItem.duration.value/self.nativePlayer.currentItem.duration.timescale;
    NSTimeInterval currentTimeSec = self.nativePlayer.currentTime.value/self.nativePlayer.currentTime.timescale;
    _currentSeekTime = currentTimeSec;
    self.playView.currentPlayTime = currentTimeSec;
   
    NSString *curTimeStr = [AliyunUtil timeformatFromSeconds:roundf(currentTimeSec *1000)];
    NSLog(@"airplay～～播放进度: %@",curTimeStr);
    NSString *totalTimeStr = [AliyunUtil timeformatFromSeconds:roundf(duration *1000)];
    dispatch_async(dispatch_get_main_queue(), ^{
            self.playSlider.value = currentTimeSec/duration;
            self.rightTimeLabel.text = [NSString stringWithFormat:@"/%@",totalTimeStr] ;
            self.leftTimeLabel.text = curTimeStr;
    });
   
    
    }
   
    
    
}


- (void)qualityButtonClicked:(UIButton *)button {
    _qualityButton = button;
    button.selected = !button.selected;
    if (!button.selected) {
        [self.listView removeFromSuperview];
        
    } else {
       self.listView.hidden = NO;
        [self.playView addSubview:self.listView];
    }
    
}


- (void)qualityListViewOnItemClick:(int)index {
    _qualityButton.selected = NO;
    for (AVPTrackInfo * info in self.trackInfoArray) {
        if (info.trackIndex == index) {
            AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:info.vodPlayUrl]];
            [self.nativePlayer replaceCurrentItemWithPlayerItem:item];
            NSString *title = [self qualityFromTrackDefinition:info.trackDefinition];
            if (info.trackDefinition) {
                [self.qualityButton setTitle:title forState:UIControlStateNormal];
            }
            _switchQuality = YES;
            
        }
    }
   
    
    // 切换清晰度
}
- (NSString *)qualityFromTrackDefinition:(NSString *)definition {
    
    NSArray *array = @[@"FD",@"HD",@"LD",@"OD",@"SD",@"2K",@"4K"];
    NSInteger index = [array indexOfObject:definition];
    NSString * nameStr;
    switch (index) {
        case 0:
            nameStr = [@"流畅" localString];
            break;
        case 1:
            nameStr = [@"超清" localString];
            break;
        case 2:
            nameStr = [@"标清" localString];
            break;
        case 3:
            nameStr = [@"原画" localString];
            break;
        case 4:
            nameStr = [@"高清" localString];
            break;
        case 5:
            nameStr = [@"2K" localString];
            break;
        case 6:
            nameStr = [@"4K" localString];
            break;
        default:
            break;
    }
    
    return nameStr;
}



- (void)qualityListViewOnDefinitionClick:(NSString*)videoDefinition {
    _qualityButton.selected = !_qualityButton.selected;
    [_qualityButton setTitle:videoDefinition forState:UIControlStateNormal];
}

@end
