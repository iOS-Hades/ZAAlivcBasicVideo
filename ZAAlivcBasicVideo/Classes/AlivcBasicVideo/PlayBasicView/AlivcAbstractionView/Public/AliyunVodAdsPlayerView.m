//
//  AliyunVodAdsPlayerView.m
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/13.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AliyunVodAdsPlayerView.h"
#import "AliyunPlayerViewBottomView.h"
#import "AVC_VP_AdsViewController.h"
#import "AliyunPlayerViewBottomView.h"
#import "AlilyunViewLoadingView.h"
#import "NSString+AlivcHelper.h"

static  NSInteger const NotInAds  = 5;

@interface AliyunVodAdsPlayerView()<AVPDelegate>

@property (nonatomic, strong) AliPlayer *aliPlayer;
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, assign) NSInteger videoDuration; // 不包含广告时间
@property (nonatomic, assign) NSInteger duration; // 包含了广告的时间
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, assign) NSTimeInterval seekTime; //记住seek到的地方

@property (nonatomic, assign, readonly) BOOL isPresenting; // 广告播放器view是否是最上层的view，没有presentController 覆盖
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) AlilyunViewLoadingView *loadingView;         //loading
@property (nonatomic, strong) UILabel * adsLabel;
@end

@implementation AliyunVodAdsPlayerView


- (AlilyunViewLoadingView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[AlilyunViewLoadingView alloc] init];
    }
    return _loadingView;
}


- (void)changePresentStatue:(NSNotification *)noti {
    if ([noti.object isEqual:@"1"]) {
       
        _isPresenting = NO;
    }else if ([noti.object isEqual:@"0"]){
        
        _isPresenting = YES;
    }

}
- (void)becomeActive {
    
  
    // 广告视频正在播放，并且广告视频所在controller正在显示
    
   
    if (self.isPlay &&  _isPresenting == YES) {
        [self.aliPlayer start];
    }
    
}



- (void)willResignActive{
    if (self.isPlay) {
        [self.aliPlayer pause];
    }
}
- (void)resignActive {
    if (self.isPlay) {
        [self.aliPlayer pause];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePresentStatue:) name:@"ShowPresentView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resignActive)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResignActive)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        _adsIndex = 0;
        self.isPlay = NO;
        _isPresenting = YES;
        
        self.aliPlayer.delegate = self;
        self.aliPlayer.rate = 1;
        self.aliPlayer.playerView = self.playView;
        
        self.playView.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        
        self.playView.frame = self.bounds;
        [self addSubview:self.playView];
        [self.playView addSubview:self.backButton];
        [self addSubview:self.loadingView];
        [self addSubview:self.adsLabel];
        
        
        
    }
    
    return self;
}

- (void)setVideoAdsUrl:(NSString *)videoAdsUrl {
    _videoAdsUrl = videoAdsUrl;
    AVPUrlSource *urlSource = [[AVPUrlSource alloc]init];
    urlSource.playerUrl = [NSURL URLWithString:self.videoAdsUrl];
    [self.aliPlayer setUrlSource:urlSource];
    [self.aliPlayer prepare];
}

- (UIView *)playView {
    if (!_playView) {
        _playView = [[UIView alloc]init];
        _playView.backgroundColor = [UIColor colorWithRed:0.12f green:0.13f blue:0.18f alpha:1.00f];
    }
    return _playView;
}
- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[AlivcImage imageInBasicVideoNamed:@"avcBackIcon"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _backButton;
}

- (UILabel *)adsLabel {
    if (!_adsLabel) {
        _adsLabel = [[UILabel alloc]init];
        _adsLabel.backgroundColor = [UIColor blackColor];
        _adsLabel.textColor = [UIColor whiteColor];
        _adsLabel.textAlignment = NSTextAlignmentCenter;
        _adsLabel.text = [@"视频广告" localString];
        _adsLabel.font = [UIFont systemFontOfSize:14];
        _adsLabel.layer.masksToBounds = YES;
        _adsLabel.layer.cornerRadius = 10;
    }
    return _adsLabel;
}

- (void)back{
    
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
    [AliyunUtil setFullOrHalfScreen];

    } else {
        
    UIViewController * controller =  [self findSuperViewController:self];
    [controller.navigationController popViewControllerAnimated:YES];
        
    }
}

- (AliPlayer *)aliPlayer{
    if (!_aliPlayer) {
        _aliPlayer = [[AliPlayer alloc] init];
    }
    return _aliPlayer;
}


- (void)setControlView:(AliyunPlayerViewControlView *)controlView {
    _controlView = controlView;
    AliyunPlayerViewBottomView *view = [_controlView bottomView];
    [view addSubview:self.pauseButton];
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [[UIButton alloc]init];
        _pauseButton.selected = NO;
        [_pauseButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"al_play_start" skin:AliyunVodPlayerViewSkinBlue] forState:UIControlStateNormal];
        [_pauseButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"al_play_stop" skin:AliyunVodPlayerViewSkinBlue] forState:UIControlStateSelected];
        // [_pauseButton addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _pauseButton;
}
- (void)pause:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self.aliPlayer start];
    }else {
        [self.aliPlayer pause];
    }
    
}

- (void)setIsPlay:(BOOL)isPlay {
    
    _isPlay = isPlay;
    self.controlView.bottomView.hidden = _isPlay;
    UIButton *playButton = [self.controlView viewWithTag:1076399];
    playButton.hidden = _isPlay;
    self.pauseButton.hidden = !_isPlay;
    
    
    
}

- (void)startPlay {
    
    [self.aliPlayer start];
    _isPlay = YES;
    self.pauseButton.selected = YES;
    [self.videoPlayer pause];
    [self.loadingView show];
    
}

- (void)pausePlay {
    [self.aliPlayer pause];
}

/**
 判断是否到播放广告的时间
 
 @param currentTime 当前时间 单位毫秒
 @param duration 不包括广告的时间 单位毫秒
 */
- (void)isPlayAdsCurrentTime:(NSTimeInterval)currentTime  duration:(NSTimeInterval)duration{
    if (self.isPlay == YES || self.adsIndex >=3) {
        
        return;
    }
    // 第一次的时候更新
    AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
    
    if (progressView.duration == 0 && duration >0) {
        progressView.milliSeconds = self.seconds *1000;
        progressView.duration = duration;
        progressView.insertTimeArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:duration/2],[NSNumber numberWithInt:duration], nil];
        self.insertTimeArray = progressView.insertTimeArray;
        [progressView setAdsPart:@"1"];
        self.duration = duration + 3 * self.seconds *1000;
        self.videoDuration = duration;
    }
    
    NSInteger insetTime = [[progressView.insertTimeArray objectAtIndex:self.adsIndex]integerValue];
    currentTime = currentTime + self.adsIndex * self.seconds *1000;
    
    if ( self.isPlay == NO && currentTime >= insetTime +self.adsIndex * self.seconds*1000){
        if ([self.adsDelegate respondsToSelector:@selector(aliyunVodAdsPlayerViewStartPlay)] && _adsIndex<= 2) {
            [self.adsDelegate aliyunVodAdsPlayerViewStartPlay];
        }
        [self startPlay];
        
        
    }
    
    
}


// 判断当前进度是否在广告播放时间范围

- (CGFloat)allowSeek:(CGFloat)progressValue {
    // 1 广告播放中不允许seek 2 不得seek掉未播放的广告
    // 返回0 不允许 返回1 允许seek
    // 返回2 播放广告视频
    if (self.isPlay ) {
        return 0.0;
    }
    if (_adsIndex >= 3) {
        return 1.0;
    }else {
        
        NSInteger insertTime = [[self.insertTimeArray objectAtIndex:self.adsIndex]integerValue];
        
        CGFloat adsBegin = self.adsIndex * self.seconds *1000 + insertTime;
        
        CGFloat adsEnd = (self.adsIndex +1) * self.seconds *1000 + insertTime;;
        
        
        CGFloat currentTime =self.duration *progressValue;
        
        
        if (currentTime > adsBegin) {
            // 往前seek
            _seekTime = adsEnd - (self.adsIndex +1) * self.seconds *1000;;
            //currentTime - self.adsIndex * self.seconds *1000;
            // 越过第二个广告的操作
            if ( currentTime >adsEnd ) {
                _seekTime = currentTime - (self.adsIndex +1) * self.seconds *1000;
                if ([self checkCurrentTimeIsInAdsPlay:currentTime]<NotInAds) {
                    _seekTime = 1; // 返回1， 广告播放之后还播放广告
                }
                
            }
            
            if ([self.adsDelegate respondsToSelector:@selector(aliyunVodAdsPlayerViewStartPlay)] && _adsIndex<= 2) {
                [self.adsDelegate aliyunVodAdsPlayerViewStartPlay];
            }
            [self startPlay];
            return  2;
        }else {
            // 往后seek
           
            if ([self checkCurrentTimeIsInAdsPlay:currentTime] <NotInAds) {
                
                if ([self.adsDelegate respondsToSelector:@selector(aliyunVodAdsPlayerViewStartPlay)] && _adsIndex<= 2) {
                    [self.adsDelegate aliyunVodAdsPlayerViewStartPlay];
                }
                _seekTime = [[self.insertTimeArray objectAtIndex:(_adsIndex -1)]floatValue];
                --_adsIndex;
                [self startPlay];
                
                return 2;
      
            }
            
            
            
            return 1.0;
            
        }
        
    }
    
}

- (NSInteger)checkCurrentTimeIsInAdsPlay:(NSTimeInterval)currentTime {
    
    
    for (int i =0; i< self.insertTimeArray.count; ++i) {
        NSInteger time = [[self.insertTimeArray objectAtIndex:i] integerValue];
        
        if (currentTime >time+ self.seconds * 1000 * i  && currentTime <time + self.seconds * 1000 *( i+1)) {
            return  i;
        }
        
        
    }
    
    return NotInAds;
    
    
}


- (NSTimeInterval)seekWithProgressValue:(CGFloat)progressValue {
    
    // 考虑向前seek
    NSTimeInterval seekTime =   self.duration *progressValue - self.adsIndex *self.seconds*1000;
    NSTimeInterval currentTime = self.duration *progressValue;
    // 考虑向后seek
    
    if (_adsIndex >=1) {
        NSInteger insertTime = [[self.insertTimeArray objectAtIndex:_adsIndex- 1]integerValue];
        while (self.duration *progressValue < insertTime + _adsIndex *self.seconds*1000 && _adsIndex >= 0) {
            _adsIndex --;
            if (_adsIndex == 0) {
                seekTime = 0;
                break;
            }
            seekTime =  self.duration *progressValue - self.adsIndex *self.seconds*1000;
            insertTime = [[self.insertTimeArray objectAtIndex:_adsIndex- 1]integerValue];
        }
    }
    //
    if ([self checkCurrentTimeIsInAdsPlay:currentTime] <NotInAds) {
        CGFloat time = [[self.insertTimeArray objectAtIndex:_adsIndex]floatValue];
        seekTime = time;
    }
    
    
    return seekTime;
}



#pragma Mark player delegate

-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    
    if (eventType == AVPEventCompletion) {
        self.adsIndex ++;
        self.isPlay = NO;
        if (self.adsIndex == 3) {
            [self.playView removeFromSuperview];
            [self.aliPlayer destroy];
            _aliPlayer = nil;
        }else {
            self.playView.hidden = YES;
            [self.aliPlayer prepare];
        }
        
        // 如果seekTime 在广告中间就直接播放广告
        
        if (_seekTime == 1) {
            _seekTime = 0;
            
            if ([self.adsDelegate respondsToSelector:@selector(aliyunVodAdsPlayerViewStartPlay)] && _adsIndex<= 2) {
                [self.adsDelegate aliyunVodAdsPlayerViewStartPlay];
            }
            [self startPlay];
            return;
        }
        
        
        if ([self.adsDelegate respondsToSelector:@selector(aliyunVodAdsPlayerViewCompletePlay:)]) {
            [self.adsDelegate aliyunVodAdsPlayerViewCompletePlay:_seekTime];
        }
        _seekTime = 0;
        
    }else if (eventType == AVPEventFirstRenderedStart){
        self.playView.hidden = NO;
        [self.loadingView dismiss];
       // [self.videoPlayer pause];
        
    }else if (eventType == AVPEventPrepareDone){
        
    }
    
}

- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    
    AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
    NSArray *insetArray = progressView.insertTimeArray;
    
    NSInteger insertTime = [[insetArray objectAtIndex:_adsIndex]integerValue];
    CGFloat oringin = insertTime + self.seconds * _adsIndex *1000;
    // ??  以前是durationTime
    [self.controlView updateProgressWithCurrentTime:position + oringin durationTime:self.duration ];
    
}

- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.playView.frame = self.bounds;
    self.pauseButton.frame = CGRectMake(0, 0,52, 52);
    self.backButton.frame = CGRectMake(0, 0, 50,45);
    if (self.bounds.size.width >0) {
        self.loadingView.frame = CGRectMake((self.bounds.size.width -130)/2, (self.bounds.size.height -120)/2, 130, 120);
        self.adsLabel.frame  = CGRectMake(SCREEN_WIDTH - 85, 5, 80, 30);
    }else {
        [self.loadingView dismiss];
        self.adsLabel.frame  = CGRectZero;
    }
   
    
}


- (void)releaseAdsPlayer{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_pauseButton removeFromSuperview];
    UIButton *playButton = [self.controlView viewWithTag:1076399];
    playButton.hidden = NO;
    [_backButton removeFromSuperview];
    [self.aliPlayer stop];
    [self.aliPlayer destroy];
}


- (void)goAdsLink {
    
    // 跳到广告链接
    UIViewController * currentVC = [self findSuperViewController:self];
    AVC_VP_AdsViewController * adsVC = [[AVC_VP_AdsViewController alloc]init];
    adsVC.goBackBlock = ^{
        [self pause:_pauseButton];
    };
    if (!self.adsLink || self.adsLink.length == 0) {
        self.adsLink = @"https://www.aliyun.com/product/vod?spm=5176.10695662.782639.1.4ac218e2p7BEEf";
    }
    adsVC.urlLink = self.adsLink;
    [self pause:_pauseButton];
    
    [currentVC presentViewController:adsVC animated:YES completion:nil];
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

- (void)adsReplay{
    
    _adsIndex = 0;
    
    if ([self.adsDelegate respondsToSelector:@selector(aliyunVodAdsPlayerViewStartPlay)] && _adsIndex<= 2) {
        [self.adsDelegate aliyunVodAdsPlayerViewStartPlay];
    }
    [self startPlay];
    
//    if (!_isPlay) {
//        //重新播放
//       
//        
//    }else if (_isPlay){
//        
//     [self.aliPlayer seekToTime:0 seekMode:AVP_SEEKMODE_INACCURATE];
//        
//    }
    
}

- (void)dealloc {
    [self releaseAdsPlayer];
}

@end
