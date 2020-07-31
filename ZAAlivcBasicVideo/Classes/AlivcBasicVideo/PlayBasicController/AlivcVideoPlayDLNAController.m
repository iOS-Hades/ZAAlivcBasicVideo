//
//  AlivcVideoPlayDLNAViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/10.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcVideoPlayDLNAController.h"
#import "AliyunUtil.h"
#import "AlivcVideoPlayScreenSelectViewController.h"
#import "NSString+AlivcHelper.h"
#import "AlivcLongVideoCommonFunc.h"
@interface AlivcVideoPlayDLNAController ()<AliyunPVQualityListViewDelegate>

@property (nonatomic, assign) BOOL  hasFirstSeek;
@property (nonatomic, assign) BOOL  finishedSeek;
@property(nonatomic,strong) MRDLNA *dlnaManager;
@property (nonatomic, strong) UIButton * qualityButton;
@property (nonatomic, assign) BOOL  switchQuality;
@property (nonatomic, assign) NSTimeInterval currentSeekTime;

@end

@implementation AlivcVideoPlayDLNAController

- (instancetype)init {

    if (self = [super init]) {
        self.dlnaManager = [MRDLNA sharedMRDLNAManager];
        [self.dlnaManager startDLNA];
        [AlivcLongVideoCommonFunc setDlNAStatus:YES];
        _hasFirstSeek = NO;
        _finishedSeek = YES;
        _switchQuality = NO;
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return self;
}

-(void)volumeChanged:(NSNotification *)notification{
    CGFloat  volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]floatValue] ;
    volume = volume *100;
    NSInteger volumeStr = volume;
    [self.dlnaManager volumeChanged:[NSString stringWithFormat:@"%ld",volumeStr]];
    NSLog(@"DLNA 音量调节值： %ld",volumeStr);
}

#pragma mark -播放控制


- (void)closeAction:(id)sender {
    [self.dlnaManager endDLNA];

}

/**
 播放/暂停
 */
- (void)playButtonClicked:(UIButton *)button {
     button.selected = !button.selected;

    if (button.selected) {
        [self.dlnaManager dlnaPause];
    }else{
        [self.dlnaManager dlnaPlay];
    }

}


/**
 进度条
 */
- (void)seekChanged:(UISlider *)sender{
    NSInteger sec = sender.value * 60 * 60;
    NSLog(@"播放进度条======>: %zd",sec);
    [self.dlnaManager seekChanged:sec];
}


/**
 音量
 */
- (void)volumeChange:(UISlider *)sender {
    NSString *vol = [NSString stringWithFormat:@"%.f",sender.value * 100];
    NSLog(@"音量========>: %@",vol);
    [self.dlnaManager volumeChanged:vol];
}


/**
 切集
 */
- (void)playNext:(id)sender {
    NSString *testVideo = @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
    [self.dlnaManager playTheURL:testVideo];
}

- (void)playUrl:(NSString *)playUrl {
    [self.dlnaManager playTheURL:playUrl];
}


// 全屏按钮
- (void)fullScreenButtonClicked:(UIButton *)sender{

    [AliyunUtil setFullOrHalfScreen];
}


// 切换设备
- (void)SwitchDevice{

    AlivcVideoPlayScreenSelectViewController *vc = [[AlivcVideoPlayScreenSelectViewController alloc]init];
    vc.playUrl = self.dlnaManager.playUrl;
    UIViewController * controller =  [self findSuperViewController:self.playView];
    [controller.navigationController pushViewController:vc animated:YES];


}

- (void)closeDLNA {
    NSLog(@"end DLNA 结束投屏");
   [self.dlnaManager endDLNA];
    [AlivcLongVideoCommonFunc setDlNAStatus:NO];
   [[NSNotificationCenter defaultCenter]postNotificationName:@"SwitchPlayer" object:@"0"];

}

- (UIViewController *)findSuperViewController:(UIView *)view
{
    UIResponder *responder = view;
    // 循环获取下一个响应者,直到响应者是一个UIViewController类的一个对象为止,然后返回该对象.
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}



// 拖动进度条
- (void)updateProgressSliderAction:(UISlider *)slider {
    _finishedSeek = NO;
    CGFloat progress = slider.value;
    NSLog(@"%f",slider.value);
    NSTimeInterval duration = self.nativePlayer.currentItem.duration.value/self.nativePlayer.currentItem.duration.timescale;
    NSTimeInterval currentTimeSec = duration* progress;

    [self.dlnaManager seekChanged:currentTimeSec];

    return;



    CMTime startTime = CMTimeMakeWithSeconds(currentTimeSec, self.nativePlayer.currentTime.timescale);
    [self.nativePlayer seekToTime:startTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000)completionHandler:^(BOOL finished) {
        if (finished) {
            _finishedSeek = YES;
        }

    }];
    NSString *curTimeStr = [AliyunUtil timeformatFromSeconds:roundf(currentTimeSec *1000)];
    NSString *totalTimeStr = [AliyunUtil timeformatFromSeconds:roundf(duration *1000)];
    self.rightTimeLabel.text = totalTimeStr;
    self.leftTimeLabel.text = curTimeStr;

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
        self.playSlider.value = currentTimeSec/duration;
        NSString *curTimeStr = [AliyunUtil timeformatFromSeconds:roundf(currentTimeSec *1000)];
        NSString *totalTimeStr = [AliyunUtil timeformatFromSeconds:roundf(duration *1000)];
        self.rightTimeLabel.text = [NSString stringWithFormat:@"/%@",totalTimeStr] ;
        self.leftTimeLabel.text = curTimeStr;

    }


    NSLog(@"adsTime: %lld",self.nativePlayer.currentTime.value);
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

            [self.dlnaManager playTheURL:info.vodPlayUrl];

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
    self.playView.backgroundColor = [UIColor colorWithRed:0.12f green:0.13f blue:0.18f alpha:1.00f];
    _qualityButton.selected = !_qualityButton.selected;
    [_qualityButton setTitle:videoDefinition forState:UIControlStateNormal];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
