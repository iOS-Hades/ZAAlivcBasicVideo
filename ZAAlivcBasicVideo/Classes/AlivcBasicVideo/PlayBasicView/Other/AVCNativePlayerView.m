//
//  AVCNativePlayerView.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/3/15.
//  Copyright © 2019 Alibaba. All rights reserved.
//z

#import "AVCNativePlayerView.h"
#import "AVCAirPlayView.h"
#import "AliyunUtil.h"
#import "AliyunPrivateDefine.h"
#import "AVCNativePlayerController.h"
#import "NSString+AlivcHelper.h"
#import "AlivcVideoPlayDLNAController.h"
#define degressToRadian(x) (M_PI * (x)/180.0)

@interface AVCNativePlayerView ()

@property (nonatomic, strong) AVPlayer *nativePlayer;
@property (nonatomic, strong) UIImageView * imageView; // 正在投屏的显示图
@property (nonatomic, strong) UIImageView * redCircleImageView;
@property (nonatomic, strong) UILabel * airplayLabel;
@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, strong) NSTimer * currentTimer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIButton  *playButton;
@property (nonatomic, strong) UIButton  *backButton;
@property (nonatomic, strong) UISlider  *playSlider;
@property (nonatomic, strong) AVCAirPlayView  *switchDevice; // airplay投屏切换设备
@property (nonatomic, strong) UIButton  *switchDeviceButton; // DLNA 协议切换设备
@property (nonatomic, strong) UIButton *qualityButton;
@property (nonatomic, strong) UIButton  *definitionButton;
@property (nonatomic, strong) UILabel *leftTimeLabel;               //左侧时间
@property (nonatomic, strong) UILabel *rightTimeLabel;              //右侧时间
@property (nonatomic, strong) AVCAirPlayView  *closeView;  // airplay 投屏退出
@property (nonatomic, strong) UIButton   *closeViewButton;  // DLNA 投屏退出按钮

@property (nonatomic, strong) AliyunPlayerViewQualityListView *listView;
@property (nonatomic, strong) AVCNativePlayerController * controller;
@property (nonatomic, strong) AlivcVideoPlayDLNAController * DLNAcontroller;
@property (nonatomic, strong) NSArray <AVPTrackInfo*> * trackInfoArray;
@property (nonatomic, strong) UIButton *fullScreenButton; 

@end


@implementation AlivcNativePlayerManager

static AlivcNativePlayerManager * nativePlayerManager;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nativePlayerManager = [[AlivcNativePlayerManager alloc]init];
    });
    
    return nativePlayerManager;
}

@end

@implementation AVCNativePlayerView


- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url screenMirrorType:(ScreenMirrorType)type {
    
    if (self = [super initWithFrame:frame]) {
    
        _screenMirrorType = type;
        if (type == AirPlayType) {
            self.DLNAcontroller = nil;
            self.closeViewButton.hidden = YES;
            self.closeView.hidden = NO;
            self.switchDevice.hidden = NO;
            self.switchDeviceButton.hidden = YES;
            [self initPlayerWithUrl:url];
        }
        if (type == DLNAType) {

            self.controller = nil;
            self.closeView.hidden = YES;
            self.closeViewButton.hidden = NO;
            self.switchDevice.hidden = YES;
            self.switchDeviceButton.hidden = NO;
        }
    
       
        [self.currentTimer setFireDate:[NSDate distantFuture]];
        self.controller.nativePlayer = self.nativePlayer;
        self.controller.leftTimeLabel = self.leftTimeLabel;
        self.controller.rightTimeLabel = self.rightTimeLabel;
        self.controller.playSlider = self.playSlider;
        self.controller.listView = self.listView;
        self.controller.playView = self;
        
        
        
        self.DLNAcontroller.playView = self;
        self.DLNAcontroller.listView = self.listView;
        self.DLNAcontroller.nativePlayer = self.nativePlayer;
        self.DLNAcontroller.leftTimeLabel = self.leftTimeLabel;
        self.DLNAcontroller.rightTimeLabel = self.rightTimeLabel;
        self.DLNAcontroller.playSlider = self.playSlider;
        
        
        
        
        self.backgroundColor = [UIColor colorWithRed:0.12f green:0.13f blue:0.18f alpha:1.00f];
        self.trackInfoArray = [[NSArray alloc]init];
        [self addSubview:self.imageView];
        [self addSubview:self.playButton];
        [self addSubview:self.playSlider];
        [self addSubview:self.leftTimeLabel];
        [self addSubview:self.rightTimeLabel];
        [self addSubview:self.switchDevice];
        [self addSubview:self.switchDeviceButton];
        [self addSubview:self.closeView];
        [self addSubview:self.closeViewButton];
        [self addSubview:self.backButton];
        [self addSubview:self.qualityButton];
        [self addSubview:self.listView];
        [self addSubview:self.fullScreenButton];
        self.listView.hidden = YES;
       

        [self addPangesture];
        
      
    }
    return self;
}
- (AliyunPlayerViewQualityListView  *)listView {
    if (!_listView) {
        _listView = [[AliyunPlayerViewQualityListView alloc] init];
        _listView.delegate = self.controller;
        if (self.DLNAcontroller) {
            _listView.delegate = self.DLNAcontroller;
        }
    }
    return _listView;
}

- (void)setListViewTrack:(NSArray *)array{
    
    if (array && array.count >0) {
        
        for (AVPTrackInfo * info in array) {
            if ([info.trackDefinition isEqualToString:@"video"]) {
                array = nil;
                break;
            }
        }
    }
    
    if (!array || array.count ==0) {
        _qualityButton.hidden = YES;
        return;
    }
    _trackInfoArray = array;
    self.controller.trackInfoArray = _trackInfoArray;
    self.listView.allSupportQualities = array;
    self.DLNAcontroller.trackInfoArray = _trackInfoArray;
    
}




- (AVCNativePlayerController *)controller {
    if (!_controller) {
        if (self.screenMirrorType == DLNAType) {
            return nil;
        }
        _controller = [[AVCNativePlayerController alloc]init];
    }
    return _controller;
}

- (AlivcVideoPlayDLNAController *)DLNAcontroller {
    if (!_DLNAcontroller) {
        if (self.screenMirrorType == AirPlayType) {
            return nil;
        }
        
        _DLNAcontroller = [[AlivcVideoPlayDLNAController alloc]init];
    }
    return _DLNAcontroller;
}

- (void)setScreenMirrorType:(ScreenMirrorType)screenMirrorType {
    _screenMirrorType = screenMirrorType;
    if (screenMirrorType == AirPlayType) {
        self.DLNAcontroller = nil;
        self.closeViewButton.hidden = YES;
        self.closeView.hidden = NO;
        self.switchDevice.hidden = NO;
        self.switchDeviceButton.hidden = YES;
    }
    if (screenMirrorType == DLNAType) {
    
        self.controller = nil;
        self.closeView.hidden = YES;
        self.closeViewButton.hidden = NO;
        self.switchDevice.hidden = YES;
        self.switchDeviceButton.hidden = NO;
    }
    
}
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[AlivcImage imageInBasicVideoNamed:@"avcBackIcon"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _backButton;
}

- (UIButton *)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [[UIButton alloc] init];
        [_fullScreenButton setImage:[AlivcImage imageInBasicVideoNamed:@"alivc_fullScreen"] forState:UIControlStateSelected];
        [_fullScreenButton setImage:[AlivcImage imageInBasicVideoNamed:@"alivc_fullScreen"] forState:UIControlStateNormal];
        [_fullScreenButton addTarget:self.controller action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenButton addTarget:self.DLNAcontroller action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}




- (AVCAirPlayView *) closeView {
    
    if (!_closeView) {
        _closeView = [AVCAirPlayView airPlayViewWithFrame:CGRectZero image:[AlivcImage imageInBasicVideoNamed:@""]];
        _closeView.backgroundColor = [UIColor colorWithRed:0.00f green:0.76f blue:0.87f alpha:1.00f];
        [_closeView setText:[@"退出投屏" localString]];
    }
    return _closeView;
}
- (UIButton *)closeViewButton {
    if (!_closeViewButton) {
        _closeViewButton = [[UIButton alloc]init];
        [_closeViewButton setTitle:[@"退出投屏" localString] forState:UIControlStateNormal];
        _closeViewButton.backgroundColor = [UIColor colorWithRed:0.00f green:0.76f blue:0.87f alpha:1.00f];
        [_closeViewButton addTarget:self.DLNAcontroller action:@selector(closeDLNA) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeViewButton;
}

- (UIButton *)definitionButton {
    if (_definitionButton) {
        _definitionButton = [[UIButton alloc]init];
        [_definitionButton setTitle:[@"高清" localString] forState:UIControlStateNormal];
        [ _definitionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    
    return _definitionButton;
}

- (UIButton *)qualityButton{
    if (!_qualityButton) {
        _qualityButton = [[UIButton alloc] init];
        [_qualityButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_qualityButton setTitleColor:kALYPVColorTextNomal forState:UIControlStateNormal];
        [_qualityButton setTitleColor:kALYPVColorBlue forState:UIControlStateSelected];
        [_qualityButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"al_quality_btn_nomal" skin:AliyunVodPlayerViewSkinBlue] forState:UIControlStateNormal];
        [_qualityButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"al_quality_btn_press" skin:AliyunVodPlayerViewSkinBlue] forState:UIControlStateSelected];
        [_qualityButton addTarget:self.controller action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
         [_qualityButton addTarget:self.DLNAcontroller action:@selector(qualityButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qualityButton;
}


- (void)setCurrentTrackInfo:(AVPTrackInfo *)trackInfo{
    if (!trackInfo) {
        return;
    }
    
    NSString *title = [self qualityFromTrackDefinition:trackInfo.trackDefinition];
    if (trackInfo.trackDefinition) {
        [self.qualityButton setTitle:title forState:UIControlStateNormal];
    }
    
    if (self.DLNAcontroller) {
       
        [self.DLNAcontroller playUrl:trackInfo.vodPlayUrl];
        
    }else {
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:trackInfo.vodPlayUrl]];
    [self.nativePlayer replaceCurrentItemWithPlayerItem:item];
    self.controller.nativePlayer = self.nativePlayer;
    [AlivcNativePlayerManager sharedManager].nativePlayer = self.nativePlayer;
        
    }
    
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



- (UISlider *)playSlider{
    if (!_playSlider) {
        _playSlider = [[UISlider alloc]init];
        
        _playSlider.value = 0.0;
        //thumb左侧条的颜色
        _playSlider.minimumTrackTintColor = [UIColor colorWithRed:0.00f green:0.76f blue:0.87f alpha:1.00f];
        _playSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        //thumb图片
        [_playSlider setThumbImage:[AliyunUtil imageWithNameInBundle:@"al_play_settings_radiobtn_normal" skin:AliyunVodPlayerViewSkinBlue] forState:UIControlStateNormal];
       
        //value发生变化
        [_playSlider addTarget:self.controller action:@selector(updateProgressSliderAction:) forControlEvents:UIControlEventValueChanged];
        [_playSlider addTarget:self.controller action:@selector(seekVideo:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
         [_playSlider addTarget:self.DLNAcontroller action:@selector(updateProgressSliderAction:) forControlEvents:UIControlEventValueChanged|UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
        
    }
    return _playSlider;
}



- (UILabel *)leftTimeLabel{
    if (!_leftTimeLabel) {
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.textAlignment = NSTextAlignmentRight;
        [_leftTimeLabel setFont:[UIFont systemFontOfSize:12]];
        [_leftTimeLabel setTextColor:[UIColor whiteColor]];
        _leftTimeLabel.text = @"00:00";
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.textAlignment = NSTextAlignmentLeft;
        [_rightTimeLabel setFont:[UIFont systemFontOfSize:12]];
        [_rightTimeLabel setTextColor:[UIColor colorWithRed:0.60f green:0.60f blue:0.6f alpha:1.00f]];
        _rightTimeLabel.text = @"/00:00";
    }
    return _rightTimeLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.image = [AliyunUtil imageWithNameInBundle:@"pic_airplay" skin:AliyunVodPlayerViewSkinBlue];
        _redCircleImageView = [[UIImageView alloc]init];
        _redCircleImageView.image = [AliyunUtil imageWithNameInBundle:@"tip_airplay" skin:AliyunVodPlayerViewSkinBlue];
        _airplayLabel = [[UILabel alloc]init];
        _airplayLabel.text = [@"正在投屏中..." localString];
        _airplayLabel.font = [UIFont systemFontOfSize:14];
        _airplayLabel.textColor = [UIColor whiteColor];
        _airplayLabel.textAlignment = NSTextAlignmentLeft;
        [_imageView addSubview:_redCircleImageView];
        [_imageView addSubview:_airplayLabel];
        
        
        
    }
    return _imageView;
    
}
- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        [_playButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"al_play_start"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"al_play_stop"] forState:UIControlStateSelected];
        _playButton.selected = YES;
        [_playButton addTarget:self.controller action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton addTarget:self.DLNAcontroller action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}





- (AVCAirPlayView *)switchDevice {
    if (!_switchDevice) {

        _switchDevice = [AVCAirPlayView airPlayViewWithFrame:CGRectZero image: [AlivcImage imageInBasicVideoNamed:@"avcTV"] ];
        _switchDevice.backgroundColor = [UIColor clearColor];
        [_switchDevice setText:[@"切换设备" localString] ];

    }

    return _switchDevice;
}


- (UIButton *)switchDeviceButton {
    if (!_switchDeviceButton) {
        _switchDeviceButton = [[UIButton alloc]init];
        [_switchDeviceButton setTitle:[@"切换设备" localString] forState:UIControlStateNormal];
        _switchDeviceButton.titleLabel.font = [UIFont systemFontOfSize:16];
       
        [_switchDeviceButton addTarget:self.DLNAcontroller action:@selector(SwitchDevice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchDeviceButton;
}

- (void)setFirstSeekTime:(NSTimeInterval)firstSeekTime {
    _firstSeekTime = firstSeekTime;
    _controller.firstSeekTime = firstSeekTime;
    
}
- (void)setVideoUrl:(NSString *)videoUrl {
    
    if (self.DLNAcontroller) {
        //  如果是DLNA 投屏 不需要nativePlayer
        return;
    }
    
    [self.playerLayer removeFromSuperlayer];
    self.item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoUrl]];
    self.nativePlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.nativePlayer.volume = 1;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.nativePlayer];
    [self.layer addSublayer:self.playerLayer];
    [self play];
}


- (NSTimer *)currentTimer {
    
    [_currentTimer invalidate];
    _currentTimer = nil;
    
    if (!_currentTimer) {
        
        if (self.DLNAcontroller) {
             _currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self.DLNAcontroller selector:@selector(updateProgressValue) userInfo:nil repeats:YES];
        }else {
            _currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self.controller selector:@selector(updateProgressValue) userInfo:nil repeats:YES];
        }
       
    
    }
    return _currentTimer;
}

- (void)back {
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
        [AliyunUtil setFullOrHalfScreen];
    } else {
        UIViewController * controller =  [self findSuperViewController:self];
        [controller.navigationController popViewControllerAnimated:YES];
    }
    
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

- (void)initPlayerWithUrl:(NSString *)url{
    
    if (self.screenMirrorType == DLNAType) {
        return;
    }
    
    self.item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    self.nativePlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.nativePlayer];
    [self.layer addSublayer:self.playerLayer];
    
    AVPlayer * player = [AlivcNativePlayerManager sharedManager].nativePlayer;
    if (player) {
        [player pause];
        [player.currentItem cancelPendingSeeks];
        [player.currentItem.asset cancelLoading];
        player = nil;
        [AlivcNativePlayerManager sharedManager].nativePlayer = player;
    }
    
}
- (void)play {
    [_currentTimer setFireDate:[NSDate distantPast]];
    [self.nativePlayer play];
    self.nativePlayer.volume = 0.2;

}

- (void)pause{
    [self.nativePlayer pause];
   
}



#pragma Mark 添加手势

- (void)addPangesture {
    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
//    [self addGestureRecognizer:panGesture];
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture {
    
     CGPoint transP = [panGesture translationInView:self];
    
    NSLog(@"%f %f",transP.x,transP.y);
   
    CMTime time = self.nativePlayer.currentTime;
    NSTimeInterval currentTimeSec = time.value / time.timescale;
    NSLog(@"%lld %f",self.nativePlayer.currentItem.duration.value/self.nativePlayer.currentItem.duration.timescale,currentTimeSec);
    currentTimeSec = currentTimeSec + transP.x/ 15;
    
    CMTime startTime = CMTimeMakeWithSeconds(currentTimeSec, self.item.currentTime.timescale);
    
    [self.nativePlayer seekToTime:startTime completionHandler:^(BOOL finished) {
        NSLog(@"finishe seek");
    }];
    
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (self.screenMirrorType == DLNAType) {
         self.playerLayer.frame = CGRectZero;
    }else {
         self.playerLayer.frame = self.bounds;
    }
   
   
    self.imageView.frame = CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height/3);
    self.imageView.center = CGPointMake(self.center.x, self.center.y - 50);
    self.airplayLabel.frame = CGRectMake(0, 0, 100, 25);
    self.airplayLabel.center = CGPointMake(self.imageView.bounds.size.width/2 + 10, self.imageView.bounds.size.height/2);
    self.redCircleImageView.frame = CGRectMake(0, 0, 20, 20);
    self.redCircleImageView.center = CGPointMake(self.imageView.bounds.size.width/2 - 55, self.imageView.bounds.size.height/2);
    
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    float bottomBarY = height - 52;
    self.playButton.frame = CGRectMake(0,bottomBarY,52, 52);
    self.leftTimeLabel.frame =  CGRectMake(52,bottomBarY , 60, 52);
    self.rightTimeLabel.frame = CGRectMake(52+60,bottomBarY , 60, 52);
   
    self.closeView.frame = CGRectMake(0, 0, 100, 40);
    self.closeView.center = CGPointMake(self.center.x, self.center.y +40);
    self.closeViewButton.frame = CGRectMake(0, 0, 100, 40);
    self.closeViewButton.center = CGPointMake(self.center.x, self.center.y +40);
    self.backButton.frame = CGRectMake(0, 0, 50,45);
   
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
        
        self.qualityButton.hidden = NO;
        self.playSlider.frame = CGRectMake(52+60 + 60,bottomBarY , width - 360, 52);
        self.switchDeviceButton.frame = CGRectMake( width- 200 , bottomBarY, 100, 52);
        self.switchDevice.frame = CGRectMake( width- 200 , bottomBarY, 100, 52);
        self.qualityButton.frame = CGRectMake(width- 90, bottomBarY, 64, 52);
        self.listView.frame = CGRectMake(width- 100, bottomBarY - 32* _trackInfoArray.count, 64, 32* _trackInfoArray.count+6);

        
        if (!_trackInfoArray|| _trackInfoArray.count ==0) {
            self.qualityButton.hidden = YES;
            self.playSlider.frame = CGRectMake(52+60 + 60,bottomBarY , width - 280, 52);
            self.switchDeviceButton.frame = CGRectMake( width- 120 , bottomBarY, 100, 52);
            self.switchDevice.frame = CGRectMake( width- 120 , bottomBarY, 100, 52);
        }
        
        self.fullScreenButton.hidden = YES;
        
    } else {
       
        self.qualityButton.hidden = YES;
        self.playSlider.frame = CGRectMake(52+60 + 60,bottomBarY , width - 250, 52);
        self.switchDeviceButton.frame = CGRectMake( width- 100 , 9, 100, 52);
        self.switchDevice.frame = CGRectMake( width- 100 , 9, 100, 52);
        self.fullScreenButton.hidden = NO;
        self.fullScreenButton.frame = CGRectMake( width - 60, bottomBarY, 52, 52);
    }
    
    

}

- (void)releasePlayer{
    
    if (_nativePlayer) {
    [_nativePlayer pause];
 
    [_nativePlayer.currentItem cancelPendingSeeks];
    [_nativePlayer.currentItem.asset cancelLoading];
   
    [_playerLayer removeFromSuperlayer];
    _controller = nil;
    _playerLayer=nil;
    _item = nil;
    _nativePlayer = nil;
    }
    
    if (_currentTimer) {
        [_currentTimer invalidate];
        _currentTimer = nil;
    }
    
}

- (ScreenMirrorType)getScreenMirrorType {
    return _screenMirrorType;
}


@end
