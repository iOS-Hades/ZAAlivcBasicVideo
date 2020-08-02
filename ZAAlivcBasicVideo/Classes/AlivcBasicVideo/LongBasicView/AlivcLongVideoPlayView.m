//
//  AlivcLongVideoPlayView.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/26.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoPlayView.h"

//public
#import "AliyunPrivateDefine.h"
#import "AliyunReachability.h"

//data
#import "AliyunDataSource.h"

//view
#import "AliyunPlayerViewControlView.h"
#import "AliyunViewMoreView.h"
#import "AliyunPlayerViewFirstStartGuideView.h"

//tipsView
#import "AliyunPlayerViewPopLayer.h"
#import "AliyunPlayerViewErrorView.h"
#import "MBProgressHUD+AlivcHelper.h"

//loading
#import "AlilyunViewLoadingView.h"

//log
#import "AliyunLog.h"

#import "NSString+AlivcHelper.h"
#import "AVCFreeTrialView.h"
#import "AVCWaterMarkView.h"
#import "AliyunVodAdsPlayerView.h"
#import "AliyunPlayerViewProgressView.h"
#import "AVCNativePlayerView.h"
#import "AVCAirPlayView.h"
#import "AVCImageAdView.h"
#import "AVCBarrageSettingView.h"
#import "QHDanmu.h"
#import "AlivcLongVideoDotView.h"
#import "AlivcLongVideoThumbnailView.h"
#import "AlivcLongVideoCommonFunc.h"
#import "AlivcLongVideoPreviewLogoView.h"
#import "AlivcVideoPlayScreenSelectViewController.h"
#import "AlivcDefine.h"

#define PLAY_VIEW @"playView"

static const CGFloat AlilyunViewLoadingViewWidth  = 130;
static const CGFloat AlilyunViewLoadingViewHeight = 120;

@interface AlivcLongVideoPlayView ()<AVPDelegate,AliyunPVPopLayerDelegate,AliyunControlViewDelegate,AliyunViewMoreViewDelegate,AliyunVodAdsPlayerViewDelegate,AVCBarrageSettingViewDelegate,QHDanmuSendViewDelegate,AlivcLongVideoDotViewDelegate>

#pragma mark - view

@property (nonatomic, strong) AliPlayer *aliPlayer;               //点播播放器
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIImageView *coverImageView;              //封面
@property (nonatomic, strong) AliyunPlayerViewControlView *controlView;
@property (nonatomic, strong) AliyunViewMoreView *moreView;             //更多界面
@property (nonatomic, strong) AVCBarrageSettingView *barrageSettingView;  //弹幕设置视图
@property (nonatomic, strong) QHDanmuSendView *danmuSendV; //发送弹幕view
@property (nonatomic, strong) AliyunPlayerViewFirstStartGuideView *guideView;     //导航
@property (nonatomic, strong) AliyunPlayerViewPopLayer *popLayer;               //弹出的提示界面
@property (nonatomic, strong) AlilyunViewLoadingView *loadingView;         //loading
@property (nonatomic, strong) AlilyunViewLoadingView *qualityLoadingView;  //清晰度loading

#pragma mark - data
@property (nonatomic, strong) AliyunReachability *reachability;       //网络监听
@property (nonatomic, assign) CGRect saveFrame;                         //记录竖屏时尺寸,横屏时为全屏状态。
@property (nonatomic ,assign) ALYPVPlayMethod playMethod; //播放方式
@property (nonatomic, weak  ) NSTimer *timer;                           //计时器
@property (nonatomic, assign) NSTimeInterval currentDuration;           //记录播放时长
@property (nonatomic, copy  ) NSString *currentMediaTitle;              //设置标题，如果用户已经设置自己标题，不在启用请求获取到的视频标题信息。
@property (nonatomic, assign) BOOL isProtrait;                          //是否是竖屏
@property (nonatomic, assign) BOOL isRerty;                             //default：NO
@property (nonatomic, assign) float saveCurrentTime;                    //保存重试之前的播放时间
@property (nonatomic, assign) BOOL mProgressCanUpdate;                  //进度条是否更新，默认是NO
@property (nonatomic, strong) AliyunLog *playerViewLog;    //日志

#pragma mark - 播放方式
@property (nonatomic, strong) AliyunLocalSource *localSource;   //url 播放方式
@property (nonatomic, strong) AliyunPlayAuthModel *playAuthModel;    //vid+playAuth 播放方式
@property (nonatomic, strong) AliyunSTSModel *stsModel;              //vid+STS 播放方式
@property (nonatomic, strong) AliyunMPSModel *mpsModel;              //vid+MPS 播放方式

@property (nonatomic, assign) AVPStatus currentPlayStatus; //记录播放器的状态
@property (nonatomic, strong) AVCFreeTrialView * freeTrialView; // 试看
@property (strong, nonatomic) AVCWaterMarkView *waterMarkView; //  水印

@property (nonatomic, strong) AliyunVodAdsPlayerView * adsPlayerView; //  广告播放部分
@property (nonatomic, strong) AVCNativePlayerView * nativePlayerView; //  原生播放器部分
@property (strong, nonatomic) AVCImageAdView *imageAdsView;

@property (nonatomic, assign) CGFloat touchDownProgressValue;

@property (nonatomic, assign) NSTimeInterval keyFrameTime;

@property (nonatomic, strong) AVCAirPlayView * airPlayView;

@property (nonatomic, assign) BOOL isSeek;

@property (nonatomic, strong)AlivcLongVideoDotView *dotView;
@property (nonatomic, strong)AlivcLongVideoPreviewLogoView * previewLogoView;
@property (nonatomic, assign) BOOL trackHasThumbnai;
@property (nonatomic, strong)AlivcLongVideoThumbnailView * thumbnailView;  //缩略图功能

@property (nonatomic,assign)AVPSeekMode seekMode;

@property (nonatomic,assign)BOOL allowFinsh; // 防止原生播放器结束播放事件调用两次

@property (nonatomic,assign)BOOL noneAdvertisement;

@property (nonatomic,strong)UILabel *subTitleLabel;

@property (nonatomic,strong)AlivcVideoPlayPlayerConfig *playerConfig;

//标准网络监听状态，保证只有切换网络时才调用reload
@property (nonatomic,assign) BOOL isNetChange;

@property (nonatomic,assign) BOOL isEnterBackground;

@end

@implementation AlivcLongVideoPlayView

#pragma mark - set And get

- (AlivcLongVideoDotView *)dotView {
    if (!_dotView) {
        _dotView = [[AlivcLongVideoDotView alloc]init];
        _dotView.delegate = self;
        _dotView.hidden = YES;
    }
    return _dotView;
}

- (AlivcLongVideoPreviewLogoView *)previewLogoView {
    if (!_previewLogoView) {
        _previewLogoView = [[AlivcLongVideoPreviewLogoView alloc]init];
    }
    return _previewLogoView;
}

- (AliPlayer *)aliPlayer{
    if (!_aliPlayer && UIApplicationStateActive == [[UIApplication sharedApplication] applicationState]) {
        _aliPlayer = [[AliPlayer alloc] init];
        _aliPlayer.scalingMode =  AVP_SCALINGMODE_SCALEASPECTFIT;
        _aliPlayer.rate = 1;
        _aliPlayer.delegate = self;
        _aliPlayer.playerView = self.playerView;
        self.muted = _aliPlayer.muted;
    }
    return _aliPlayer;
}

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc]init];
    }
    return _playerView;
}

- (AVCAirPlayView *)airPlayView {
    if (!_airPlayView) {
        _airPlayView = [[AVCAirPlayView alloc]initWithFrame:CGRectZero];
    }
    return _airPlayView;
}

- (UIImageView *)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.backgroundColor = [UIColor colorWithRed:0.12f green:0.13f blue:0.18f alpha:1.00f];
        _coverImageView.contentMode =  UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (AliyunPlayerViewControlView *)controlView{
    if (!_controlView) {
        _controlView = [[AliyunPlayerViewControlView alloc] init];
        [_controlView.sendTextButton removeFromSuperview];
        [_controlView.snapshopButton removeFromSuperview];
        [_controlView.topView.danmuButton removeFromSuperview];
        _controlView.topView.titleLabel.hidden = true;
        _controlView.bottomView.audioButton.hidden = true;
        _controlView.bottomView.subtitleButton.hidden = true;
        [_controlView isShowLoopView:NO];
    }
    return _controlView;
}

/// 上部控制视图的返回按钮和标题是否隐藏
/// @param backBtnisShow 返回按钮是否隐藏
/// @param titleisShow 标题标签是否隐藏
- (void)setTopViewWithBackBtnisShow:(BOOL)backBtnisShow topViewWithTitleisShow:(BOOL)titleisShow {
    self.controlView.topView.backButton.hidden = !backBtnisShow;
    self.controlView.topView.titleLabel.hidden = !titleisShow;
}

- (AliyunViewMoreView *)moreView{
    if (!_moreView) {
        _moreView = [[AliyunViewMoreView alloc] init];
    }
    return  _moreView;
}

- (AVCBarrageSettingView *)barrageSettingView {
    if (!_barrageSettingView) {
        _barrageSettingView = [[AVCBarrageSettingView alloc]init];
        _barrageSettingView.hidden = true;
    }
    return _barrageSettingView;
}

- (AliyunPlayerViewFirstStartGuideView *)guideView{
    if (!_guideView) {
        _guideView = [[AliyunPlayerViewFirstStartGuideView alloc] init];
    }
    return _guideView;
}

- (AliyunPlayerViewPopLayer *)popLayer{
    if (!_popLayer) {
        _popLayer = [[AliyunPlayerViewPopLayer alloc] init];
        _popLayer.frame = self.bounds;
        _popLayer.hidden = YES;
    }
    return _popLayer;
}

- (AlivcLongVideoPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[AlivcLongVideoPreviewView alloc]init];
        _previewView.frame = self.bounds;
        _previewView.hidden = YES;
    }
    return _previewView;
}

- (AlilyunViewLoadingView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[AlilyunViewLoadingView alloc] init];
    }
    return _loadingView;
}

- (AlilyunViewLoadingView *)qualityLoadingView{
    if (!_qualityLoadingView) {
        _qualityLoadingView = [[AlilyunViewLoadingView alloc] init];
    }
    return _qualityLoadingView;
}

- (AlivcLongVideoThumbnailView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[AlivcLongVideoThumbnailView alloc]init];
        _thumbnailView.hidden = YES;
    }
    return _thumbnailView;
}

- (AVPSeekMode)seekMode {
    if (self.playerConfig) {
        if (self.playerConfig.accurateSeek) {
            return AVP_SEEKMODE_ACCURATE;
        }else {
            return AVP_SEEKMODE_INACCURATE;
        }
    }else {
        if (self.aliPlayer.duration < 300000) {
            return AVP_SEEKMODE_ACCURATE;
        }else {
            return AVP_SEEKMODE_INACCURATE;
        }
    }
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont systemFontOfSize:15];
        _subTitleLabel.textColor = [UIColor whiteColor];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.numberOfLines = 0;
        _subTitleLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.layer.cornerRadius = 3;
        _subTitleLabel.hidden = YES;
    }
    return _subTitleLabel;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //指记录竖屏时界面尺寸
    if ([AliyunUtil isInterfaceOrientationPortrait]){
        if (!self.fixedPortrait) {
            self.saveFrame = frame;
        }
    }
}

- (void)setViewSkin:(AliyunVodPlayerViewSkin)viewSkin{
    _viewSkin = viewSkin;
    self.controlView.skin = viewSkin;
    self.guideView.skin = viewSkin;
}

- (void)setDotsArray:(NSArray *)dotsArray {
    _dotsArray = dotsArray;
    self.dotView.dotsArray = dotsArray;
}

- (AliyunLog *)playerViewLog{
    if (!_playerViewLog) {
        _playerViewLog = [[AliyunLog alloc] init];
        _playerViewLog.isPrintLog = NO;
    }
    return _playerViewLog;
}

- (void)setCoverUrl:(NSURL *)coverUrl{
    _coverUrl = coverUrl;
    if (coverUrl) {
        if (self.coverImageView) {
            self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.coverImageView.clipsToBounds = YES;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:coverUrl];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.coverImageView.image = [UIImage imageWithData:data];
                    if ([self isVideoAds]) {
                        self.coverImageView.hidden = YES;
                    }else{
                        self.coverImageView.hidden = NO;
                    }
                    NSLog(@"播放器:展示封面");
                });
            });
        }
    }
}

- (void)setAutoPlay:(BOOL)autoPlay {
    [self.aliPlayer setAutoPlay:autoPlay];
}

- (void)setCirclePlay:(BOOL)circlePlay{
    self.aliPlayer.loop = circlePlay;
}

- (BOOL)circlePlay{
    return self.aliPlayer.loop;
}

- (void)setFixedPortrait:(BOOL)fixedPortrait{
    _fixedPortrait = fixedPortrait;
    if(fixedPortrait){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }else{
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];
    }
}

- (BOOL)isAirPlay {
    if (self.nativePlayerView) {
        return YES;
    }else{
        return NO;
    }
    
}

- (BOOL)isPlayAds {
    if (self.adsPlayerView) {
        return  self.adsPlayerView.isPlay;
    }
    return NO;
}

- (NSTimeInterval)longVideoDuration {
    return self.aliPlayer.duration;
}

- (AVPStatus)playerViewState {
    return _currentPlayStatus;
}

- (AVPMediaInfo *)getAliyunMediaInfo{
    return  [self.aliPlayer getMediaInfo];
}

- (void)setTitle:(NSString *)title {
    self.currentMediaTitle = title;
}

#pragma mark - init

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andSkin:AliyunVodPlayerViewSkinBlue];
}

- (void)becomeActive {
    _isEnterBackground = NO;
    if (self.currentPlayStatus == AVPStatusPaused && [self isPresent] && [self isAirPlay] == NO) {
        [self  resume];
    }
}

- (void)resignActive {
    _isEnterBackground = YES;
    if (self.playerConfig.backPlay) {
        return;
    }
    if (self.currentPlayStatus == AVPStatusStarted|| self.currentPlayStatus == AVPStatusPrepared) {
        [self pause];
    }
}

- (void)clickHideDotView {
    self.dotView.hidden = YES;
}

//初始化view
- (void)initView{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clickHideDotView)
                                                 name:@"GestureViewSingleClick"
                                               object:nil];
  
    
    self.keyFrameTime = 0;
    [self addSubview:self.playerView];
    [self addSubview:self.coverImageView];
    [self addSubview:self.airPlayView];
    self.controlView.delegate = self;
    [self addSubview:self.controlView];
    self.moreView.delegate = self;
    [self addSubview:self.moreView];
    self.barrageSettingView.delegate = self;
    [self addSubview:self.barrageSettingView];
    self.popLayer.delegate = self;
    [self addSubview:self.popLayer];
    [self addSubview:self.previewView];
    [self addSubview:self.loadingView];
    [self addSubview:self.qualityLoadingView];
    [self addSubview:self.dotView];
    [self addSubview:self.thumbnailView];
    [self addSubview:self.subTitleLabel];
}

- (void)switchPlayer:(NSNotification *)noti {
    _allowFinsh = YES;
    NSString * type = noti.object;
    if ([type isEqualToString:@"1"]) {
        [self setPlayType];
        [self pause];
        if (self.imageAdsView) {
            [self.imageAdsView removeFromSuperview];
            self.imageAdsView = nil;
        }
        [self.moreView showSpeedViewPushInAnimate];
        if (!self.nativePlayerView) {
            self.nativePlayerView  = [[AVCNativePlayerView alloc]initWithFrame:self.bounds url:self.currentModel.videoUrl screenMirrorType:AirPlayType];
            [self insertSubview:self.nativePlayerView belowSubview:self.moreView];
            [self.nativePlayerView setCurrentTrackInfo:self.currentTrackInfo];
            NSArray *array = [self.aliPlayer getMediaInfo].tracks;
            [self.nativePlayerView setListViewTrack:array];
            self.nativePlayerView.firstSeekTime = self.saveCurrentTime;
            [self.nativePlayerView play];
            if (self.waterMarkView) {
                self.waterMarkView.hidden = YES;
            }
        }else {
            self.nativePlayerView.firstSeekTime = self.saveCurrentTime;
            self.nativePlayerView.videoUrl = self.currentModel.videoUrl;
            [self.nativePlayerView setCurrentTrackInfo:self.currentTrackInfo];
            NSArray *array = [self.aliPlayer getMediaInfo].tracks;
            [self.nativePlayerView setListViewTrack:array];
            [self.nativePlayerView play];
            if (self.waterMarkView) {
                self.waterMarkView.hidden = NO;
            }
        }
    }else if ([type isEqualToString:@"0"]){
        NSTimeInterval currentTime = self.nativePlayerView.currentPlayTime;
        if (currentTime >0) {
            self.mProgressCanUpdate = NO;
            [self seekTo:currentTime * 1000];
        }else {
            [self resume];
        }
        [self.nativePlayerView releasePlayer];
        [self.nativePlayerView removeFromSuperview];
        self.nativePlayerView = nil;
        [self setPlayType];
    }
}

- (void)startAirplay {
    [self.airPlayView showAirplayView];
}

- (void)startDLNA:(NSNotification *)noti {
    if (self.nativePlayerView) {
        [self.nativePlayerView removeFromSuperview];
        self.nativePlayerView = nil;
    }
    [self.aliPlayer pause];
    self.isPlay = NO;
    self.nativePlayerView  = [[AVCNativePlayerView alloc]initWithFrame:self.bounds url:self.currentTrackInfo.vodPlayUrl screenMirrorType:DLNAType];
    [self.nativePlayerView setCurrentTrackInfo:self.currentTrackInfo];
    NSArray *array = [self.aliPlayer getMediaInfo].tracks;
    [self.nativePlayerView setListViewTrack:array];
    self.nativePlayerView.firstSeekTime = self.saveCurrentTime;
    [self insertSubview:_nativePlayerView belowSubview:self.moreView];
}

- (void)playFinished:(NSNotification *)noti {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishWithAliyunVodPlayerView:)] && self.allowFinsh== YES ) {
        self.allowFinsh = NO;
        [self.delegate onFinishWithAliyunVodPlayerView:self];
    }
}

- (void)playFailFinished:(NSNotification *)noti {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishWithAliyunVodPlayerView:)] && self.allowFinsh== YES ) {
        self.allowFinsh = NO;
        [self.delegate onFinishWithAliyunVodPlayerView:self];
    }
}

#pragma mark - 指定初始化方法
- (instancetype)initWithFrame:(CGRect)frame andSkin:(AliyunVodPlayerViewSkin)skin {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(switchPlayer:) name:SwitchPlayer object:nil];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startAirplay) name:@"PlayerStartAirplayToPlay" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startDLNA:) name:@"PlayerStartDLNAToPlay" object:nil];
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFailFinished:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
        
        if ([AliyunUtil isInterfaceOrientationPortrait]){
            self.saveFrame = frame;
        }else{
            self.saveFrame = CGRectZero;
        }
        self.mProgressCanUpdate = YES;
        //设置view
        [self initView];
        //加载控件皮肤
        self.viewSkin = skin;
        //屏幕旋转通知
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        //网络状态判定
        self.reachability = [AliyunReachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged)
                                                     name:AliyunSVReachabilityChangedNotification
                                                   object:nil];
        //存储第一次触发saas
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"aliyunVodPlayerFirstOpen"];
        if (!str) {
            [[NSUserDefaults standardUserDefaults] setValue:@"aliyun_saas_first_open" forKey:@"aliyunVodPlayerFirstOpen"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return self;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    self.playerView.frame = self.bounds;
    
    AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
    if (width >500) {
        [progressView setDotsHidden:NO];
    }else {
        [progressView setDotsHidden:YES];
    }
    
    if (self.adsPlayerView && self.adsPlayerView.isPlay == YES) {
        self.adsPlayerView.frame = self.bounds;
    }
    
    self.previewLogoView.frame = CGRectMake(20, self.bounds.size.height - 60, 150, 40);
    
    if (self.nativePlayerView) {
        self.nativePlayerView.frame = self.bounds;
    }
    if (self.waterMarkView) {
        self.waterMarkView.frame = CGRectMake(self.bounds.size.width -60, 15, 40, 20);
    }
    self.coverImageView.frame= self.bounds;
    self.controlView.frame = self.bounds;
    self.moreView.frame = self.bounds;
    self.barrageSettingView.frame = self.bounds;
    self.guideView.frame =  self.bounds;
    self.popLayer.frame = self.bounds;
    self.previewView.frame = self.bounds;
    self.popLayer.center = CGPointMake(width/2, height/2);
    self.thumbnailView.frame = CGRectMake(width/2-80, height/2-60, 160, 120);
    
    float x = (self.bounds.size.width -  AlilyunViewLoadingViewWidth)/2;
    float y = (self.bounds.size.height - AlilyunViewLoadingViewHeight)/2;
    self.qualityLoadingView.frame = self.loadingView.frame = CGRectMake(x, y, AlilyunViewLoadingViewWidth, AlilyunViewLoadingViewHeight);
    self.danmuSendV.frame = self.bounds;
    self.subTitleLabel.center = self.center;
    if (self.imageAdsView) {
        [self.imageAdsView setFrame];
    }
}

#pragma mark - 网络状态改变
- (void)reachabilityChanged{
    if (self.playerViewState != AVPStatusIdle) {
        [self networkChangedToShowPopView];
    }
    _isNetChange = YES;
}

//网络状态判定
- (BOOL)networkChangedToShowPopView{
    BOOL ret = NO;
    switch ([self.reachability currentReachabilityStatus]) {
        case AliyunSVNetworkStatusNotReachable://由播放器底层判断是否有网络
            break;
        case AliyunSVNetworkStatusReachableViaWiFi:
            [self reloadWhenNetChange];
            break;
        case AliyunSVNetworkStatusReachableViaWWAN:
        {
            [self reloadWhenNetChange];
            if ([self.localSource isFileUrl]) {
                return NO;
            }
            if (self.aliPlayer.autoPlay) {
                self.aliPlayer.autoPlay = NO;
            }
                        
            
            [self stop];
            [self unlockScreen];
            [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeUseMobileNetwork popMsg:nil];
            [self.loadingView dismiss];
//            [self.qualityLoadingView dismiss];
            if (self.imageAdsView) {
                [self.imageAdsView removeFromSuperview];
                self.imageAdsView = nil;
            }
            NSLog(@"播放器展示4G提醒");
            ret = YES;
        }
            break;
        default:
            break;
    }
    return ret;
}

#pragma mark - 屏幕旋转
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
    
    //进后台不再旋转屏幕
    if (_isEnterBackground) {
        return;
    }
    
    UIDevice *device = [UIDevice currentDevice] ;
    if (self.isScreenLocked) {
        return;
    }
    
    if (ScreenHeight > ScreenWidth) {
        [self.danmuSendV removeFromSuperview];
    }
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            // 影响X变成全面屏的问题
            NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"aliyunVodPlayerFirstOpen"];
            if ([str isEqualToString:@"aliyun_saas_first_open"]) {
                [[NSUserDefaults standardUserDefaults] setValue:@"aliyun_saas_no_first_open" forKey:@"aliyunVodPlayerFirstOpen"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self addSubview:self.guideView];
            }
            
            if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:fullScreen:)]) {
                [self.delegate aliyunVodPlayerView:self fullScreen:YES];
            }
            if (self.isPlay) {
                self.controlView.bottomView.rateButton.hidden = NO;
            }else{
                self.controlView.bottomView.rateButton.hidden = YES;
            }
        }
            break;
        case UIDeviceOrientationPortrait:
        {
            if (self.saveFrame.origin.x == 0 && self.saveFrame.origin.y==0 && self.saveFrame.size.width == 0 && self.saveFrame.size.height == 0) {
                //开始时全屏展示，self.saveFrame = CGRectZero, 旋转竖屏时做以下默认处理
                CGRect tempFrame = self.frame ;
                tempFrame.size.width = self.frame.size.height;
                tempFrame.size.height = self.frame.size.height* 9/16;
                self.frame = tempFrame;
            }else{
                self.frame = self.saveFrame;
                
            }
            //2018-6-28 cai
            BOOL isFullScreen = NO;
            if (self.frame.size.width > self.frame.size.height) {
                isFullScreen = NO;
            }
            if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:fullScreen:)]) {
                [self.delegate aliyunVodPlayerView:self fullScreen:NO];
            }
            [self.guideView removeFromSuperview];
            
            self.controlView.bottomView.rateButton.hidden = YES;
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (self.aliPlayer) {
        [self releasePlayer];
    }
}

- (void)releasePlayer {
    
    [self.aliPlayer stop];
    self.isPlay = NO;
    [self.aliPlayer destroy];
    if (self.imageAdsView) {
        [self.imageAdsView releaseTimer];
        [self.imageAdsView removeFromSuperview];
        self.imageAdsView = nil;
    }
    
    if (self.adsPlayerView) {
        [self.adsPlayerView releaseAdsPlayer];
        [self.adsPlayerView removeFromSuperview];
         self.adsPlayerView = nil;
    }
}

- (void)playDataSourcePropertySetEmpty{
    //保证仅存其中一种播放参数
    self.localSource = nil;
    self.playAuthModel = nil;
    self.stsModel = nil;
    self.mpsModel = nil;
}

#pragma mark - 播放器开始播放入口
- (void)playViewPrepareWithURL:(NSURL *)url{
    
    void(^startPlayVideo)(void) = ^{
        [self playDataSourcePropertySetEmpty];
        self.localSource = [[AliyunLocalSource alloc] init];
        self.localSource.url = url;
        
        self.playMethod = ALYPVPlayMethodUrl;
        self.controlView.playMethod = ALYPVPlayMethodUrl;
        
        if ([self networkChangedToShowPopView]) {
            return;
        }
        
        self.urlSource = [[AVPUrlSource alloc]urlWithString:url.absoluteString];
        
        if (self.playerConfig.autoVideo) { self.urlSource.definitions = @"AUTO"; }
        
        [self.aliPlayer setUrlSource:self.urlSource];
        self.localSource.url =nil;
        [self.loadingView show];
        [self.aliPlayer prepare];
        
        NSLog(@"播放器prepareWithURL");
    };
    
    [self addAdditionalSettingWithBlock:startPlayVideo];
}

- (void)playViewPrepareWithLocalURL:(NSURL *)url{
    void(^startPlayVideo)(void) = ^{
        [self playDataSourcePropertySetEmpty];
        self.localSource = [[AliyunLocalSource alloc] init];
        self.localSource.url = url;
        
        self.playMethod = ALYPVPlayMethodUrl; //本界面本地url播放和url播放统一处理
        self.controlView.playMethod = ALYPVPlayMethodLocal;
        [self.loadingView show];
        self.urlSource =  [[AVPUrlSource alloc]urlWithString:url.absoluteString];
        [self.aliPlayer setUrlSource:self.urlSource];
        [self.aliPlayer prepare];
        
    };
    
    [self addAdditionalSettingWithBlock:startPlayVideo];
}

#pragma mark - vid+playauth
- (void)playViewPrepareWithVid:(NSString *)vid playAuth : (NSString *)playAuth{
    
    void(^startPlayVideo)(void) = ^{
        [self playDataSourcePropertySetEmpty];
        self.playAuthModel = [[AliyunPlayAuthModel alloc] init];
        self.playAuthModel.videoId = vid;
        self.playAuthModel.playAuth = playAuth;
        
        self.playMethod = ALYPVPlayMethodPlayAuth;
        self.controlView.playMethod = ALYPVPlayMethodPlayAuth;
        if ([self networkChangedToShowPopView]) {
            return;
        }
        
        [self.loadingView show];
        self.authSource = [[AVPVidAuthSource alloc]initWithVid:vid playAuth:playAuth region:@""];
        
        if (self.playerConfig.autoVideo) { self.authSource.definitions = @"AUTO"; }
        
        [self.aliPlayer setAuthSource:self.authSource];
        [self.aliPlayer prepare];
        
        VidPlayerConfigGenerator* vp = [[VidPlayerConfigGenerator alloc] init];
        [vp addVidPlayerConfigByStringValue:@"PlayDomain" value:@"alivc-demo-vod-player.aliyuncs.com"];
        [vp setPreviewTime:300];
        self.authSource.playConfig = [vp generatePlayerConfig];
        
        NSLog(@"播放器playAuth"); };
    
    [self addAdditionalSettingWithBlock:startPlayVideo];
    
}

- (void)addAdditionalSettingWithBlock:(void(^)(void))startPlayVideo {
    [self setPlayType];
    AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
    [progressView setAdsPart:@"0"]; // 设置都没有视频广告
    [self.controlView setButtonEnnable:YES];
    __weak typeof(self) weakSelf = self;
    
    // 初始化进度条,把上一条播放视频的进度条 设置为0
    [self.controlView updateProgressWithCurrentTime:0 durationTime:self.aliPlayer.duration];
    [progressView removeDots];
    
    if (self.imageAdsView) {
        [self.imageAdsView removeFromSuperview];
        self.imageAdsView = nil;
    }
    if (self.freeTrialView) {
        [self.freeTrialView removeFromSuperview];
        self.freeTrialView = nil;
    }
    if (self.waterMarkView) {
        [self.waterMarkView removeFromSuperview];
        self.waterMarkView = nil;
    }
    if (self.adsPlayerView && [self isVideoAds] == NO) {
        [self.adsPlayerView releaseAdsPlayer];
        [self.adsPlayerView removeFromSuperview];
        self.adsPlayerView = nil;
    }
    if ([self isWaterMark] == YES) {
        // 添加水印
        self.waterMarkView = [[AVCWaterMarkView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 60, 15, 40, 20) image:[UIImage imageNamed:@""]];
        [self addSubview:self.waterMarkView];
    }
    
    if ([self isImageAds]) {
        self.coverImageView.hidden = NO;
        self.coverImageView.image = nil;
        
        self.imageAdsView = [[AVCImageAdView alloc]initWithImage:[UIImage imageNamed:@""] status:StartStatus inView:self];
        self.imageAdsView.player = self.aliPlayer;
        self.imageAdsView.countNum = 5;
        self.imageAdsView.close = ^{
            if ([weakSelf isImageAds]) {
                startPlayVideo();
                [weakSelf.aliPlayer start];
                weakSelf.isPlay = YES;
            }
        };
        self.imageAdsView.goback = ^{
            if (![AliyunUtil isInterfaceOrientationPortrait]) {
                [AliyunUtil setFullOrHalfScreen];
            } else {
                UIViewController * controller =  [weakSelf findSuperViewController:weakSelf];
                [controller.navigationController popViewControllerAnimated:YES];
            }
        };
        
    }else  if (self.currentModel.authorityType == AlivcPlayVideoFreeTrialType) {
        self.freeTrialView = [[AVCFreeTrialView alloc]initWithFreeTime:self.currentModel.previewTime freeTrialType:FreeTrialStart inView:self];
        startPlayVideo();
        [self.aliPlayer start];
        self.isPlay = YES;
    }else if ([self isVideoAds]) {
        if (!self.adsPlayerView) {
            self.adsPlayerView = [[AliyunVodAdsPlayerView alloc]initWithFrame:self.bounds];
            self.adsPlayerView.controlView = self.controlView;
            self.adsPlayerView.videoPlayer = self.aliPlayer;
            self.adsPlayerView.adsDelegate = self;
            self.adsPlayerView.seconds = 19;
            [self addSubview:self.adsPlayerView];
            self.adsPlayerView.videoAdsUrl = @"https://alivc-demo-cms.alicdn.com/video/videoAD.mp4";
            if (self.coverImageView) {
                self.coverImageView.hidden = YES;
            }
            [self.adsPlayerView startPlay];
        }
        startPlayVideo();
        self.isPlay = YES;
    }else {
        if (self.freeTrialView) {
            [self.freeTrialView removeFromSuperview];
            self.freeTrialView = nil;
        }
        startPlayVideo();
        [self.aliPlayer start];
        self.isPlay = YES;
    }
}

- (UIViewController *)findSuperViewController:(UIView *)view {
    UIResponder *responder = view;
    // 循环获取下一个响应者,直到响应者是一个UIViewController类的一个对象为止,然后返回该对象.
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

// 设置播放器工具包功能 长视频专用
- (void)setPlayType {
    
    // 用户不是vip，播放免费资源的时候，带图片广告
    self.isLoopView = NO;
    
    if (self.noneAdvertisement) {
        self.currentLongVideoModel.authorityType = AlivcPlayVideoNoneAdsType;
        return;
    }
    
    if ( [[AlivcLongVideoCommonFunc getUDSetWithIndex:5]boolValue] == NO && self.currentLongVideoModel.isVip &&[self.currentLongVideoModel.isVip isEqualToString:@"true"]) {
        
        self.currentLongVideoModel.authorityType = AlivcPlayVideoVideoAdsType;
        
    }else if ([[AlivcLongVideoCommonFunc getUDSetWithIndex:5]boolValue] == NO && (!self.currentLongVideoModel.isVip ||![self.currentLongVideoModel.isVip isEqualToString:@"true"]) ) {
        self.currentLongVideoModel.authorityType = AlivcPlayVideoImageAdsType;
    }else if([[AlivcLongVideoCommonFunc getUDSetWithIndex:5]boolValue] == YES){
        self.currentLongVideoModel.authorityType = AlivcPlayVideoNoneAdsType;
    }
    
    if ([self.currentLongVideoModel.title containsString:@"阿里云演示"] && [self.currentLongVideoModel.title containsString:@"水印"]){
        self.currentLongVideoModel.waterMark = YES;
    }
    
    if ([self.currentLongVideoModel.title containsString:@"阿里云演示"] && [self.currentLongVideoModel.title containsString:@"跑马灯"]){
        self.isLoopView = YES;
    }
    
    if ([self isAirPlay] == YES) {
        self.currentLongVideoModel.authorityType = AlivcPlayVideoNoneAdsType; // 投屏状态下没有图片广告和视频广告
    }
}

#pragma mark - 临时ak
- (void)playViewPrepareWithVid:(NSString *)vid
                   accessKeyId:(NSString *)accessKeyId
               accessKeySecret:(NSString *)accessKeySecret
                 securityToken:(NSString *)securityToken {
    
    void(^startPlayVideo)(void) = ^{
        [self playDataSourcePropertySetEmpty];
        self.stsModel = [[AliyunSTSModel alloc] init];
        self.stsModel.videoId = vid;
        self.stsModel.accessKeyId = accessKeyId;
        self.stsModel.accessSecret = accessKeySecret;
        self.stsModel.ststoken = securityToken;
        self.playMethod = ALYPVPlayMethodSTS;
        self.controlView.playMethod = ALYPVPlayMethodSTS;
        if ([self networkChangedToShowPopView]) {
            return;
        }
        
        [self.loadingView show];
        
        self.stsSource = [[AVPVidStsSource alloc]initWithVid:vid accessKeyId:accessKeyId accessKeySecret:accessKeySecret securityToken:securityToken region:@"cn-shanghai"];
        BOOL isVip = [[AlivcLongVideoCommonFunc getUDSetWithIndex:5]boolValue];
        if (isVip == NO && self.currentLongVideoModel.isVip && [self.currentLongVideoModel.isVip isEqualToString:@"true"]) {
            VidPlayerConfigGenerator* vp = [[VidPlayerConfigGenerator alloc] init];
            [vp addVidPlayerConfigByStringValue:@"PlayDomain" value:@"alivc-demo-vod-player.aliyuncs.com"];
            [vp setPreviewTime:300];
            self.stsSource.playConfig = [vp generatePlayerConfig];
        }
        
        [self.aliPlayer setUrlSource:nil];
        
        if (self.playerConfig.autoVideo) { self.stsSource.definitions = @"AUTO"; }
        
        [self.aliPlayer setStsSource:self.stsSource];
        [self.aliPlayer prepare];
        
        NSLog(@"播放器securityToken");
    };
    if (self.adsPlayerView) {
        [self.adsPlayerView removeFromSuperview];
        self.adsPlayerView = nil;
    }
    [self addAdditionalSettingWithBlock:startPlayVideo];
}

#pragma mark - 媒体处理
- (void)playViewPrepareWithVid:(NSString *)vid
                     accessId : (NSString *)accessId
                 accessSecret : (NSString *)accessSecret
                     stsToken : (NSString *)stsToken
                     autoInfo : (NSString *)autoInfo
                       region : (NSString *)region
                   playDomain : (NSString *)playDomain
                mtsHlsUriToken:(NSString *)mtsHlsUriToken{
    void(^startPlayVideo)(void) = ^{
        self.playMethod = ALYPVPlayMethodMPS;
        self.controlView.playMethod = ALYPVPlayMethodMPS;
        [self playDataSourcePropertySetEmpty];
        self.mpsModel = [[AliyunMPSModel alloc] init];
        self.mpsModel.videoId = vid;
        self.mpsModel.accessKey = accessId;
        self.mpsModel.accessSecret = accessSecret;
        self.mpsModel.stsToken = stsToken;
        self.mpsModel.authInfo = autoInfo;
        self.mpsModel.region = region;
        self.mpsModel.playDomain = playDomain;
        self.mpsModel.hlsUriToken = mtsHlsUriToken;
        
        if ([self networkChangedToShowPopView]) {
            return;
        }
        
        [self.loadingView show];
        
        self.mpsSource = [[AVPVidMpsSource alloc]initWithVid:vid accId:accessId accSecret:accessSecret stsToken:stsToken authInfo:autoInfo region:region playDomain:playDomain mtsHlsUriToken:mtsHlsUriToken];
        
        if (self.playerConfig.autoVideo) { self.mpsSource.definitions = @"AUTO"; }
        
        [self.aliPlayer setMpsSource:self.mpsSource];
        [self.aliPlayer prepare];
        [self.aliPlayer start];
        self.isPlay = YES;
        NSLog(@"播放器mtsHlsUriToken");
    };
    
    [self addAdditionalSettingWithBlock:startPlayVideo];
}

#pragma mark - playManagerAction
- (void)start {
    if (self.imageAdsView) {
        [self.imageAdsView removeFromSuperview];
        self.imageAdsView = nil;
    }
    [self.aliPlayer start];
    self.isPlay = YES;
}

- (void)pause{
    
    if (self.imageAdsView) {
        [self.imageAdsView removeFromSuperview];
        self.imageAdsView = nil;
    }
    if ([self isImageAds]) {
        self.imageAdsView = [[AVCImageAdView alloc]initWithImage:[UIImage imageNamed:@""] status:PauseStatus inView:self];
        self.imageAdsView.player = self.aliPlayer;
    }else if (self.stsSource.playConfig){
        
        self.imageAdsView = [[AVCImageAdView alloc]initWithImage:[UIImage imageNamed:@""] status:PauseStatus inView:self];
    }
    
    [self.aliPlayer pause];
    self.isPlay = NO;
    self.currentPlayStatus = AVPStatusPaused; // 快速的前后台切换时，播放器状态的变化不能及时传过来
    
    NSLog(@"播放器pause");
}

- (void)resume{
    [self.aliPlayer start];
    self.isPlay = YES;
    self.currentPlayStatus = AVPStatusStarted;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.imageAdsView) {
            [self.imageAdsView removeFromSuperview];
            self.imageAdsView = nil;
        }
    });
    NSLog(@"播放器resume");
}

- (void)seekTo:(NSTimeInterval)seekTime {
    if (self.aliPlayer.duration>0) {
        [self.aliPlayer seekToTime:seekTime seekMode:self.seekMode];
        [self.loadingView show];
    }
}

- (void)stop {
    [self.aliPlayer stop];
    self.isPlay = NO;
    NSLog(@"播放器stop");
}

-(void)reloadWhenNetChange{
    if(_isNetChange){
        [self reload];
    }
}

- (void)reload {
    [self.aliPlayer reload];
    NSLog(@"播放器reload");
}

- (void)replay{
    [self.aliPlayer start];
    self.isPlay = YES;
    NSLog(@"播放器replay");
}

- (void)reset{
    [self.aliPlayer reset];
    NSLog(@"播放器reset");
}

- (void)destroyPlayer {
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AliyunSVReachabilityChangedNotification object:self.aliPlayer];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.aliPlayer) {
        [self.aliPlayer destroy];
        self.aliPlayer = nil;
    }
    //开启休眠
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - AVPDelegate

-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    
    switch (eventType) {
        case AVPEventPrepareDone: {
            
            [self.loadingView dismiss];
            self.popLayer.hidden = YES;
            AVPTrackInfo * info = [player getCurrentTrack:AVPTRACK_TYPE_SAAS_VOD];
            self.currentTrackInfo = info;
            self.videoTrackInfo = [player getMediaInfo].tracks;
            [self.controlView setBottomViewTrackInfo:info];
            
            if (self.playMethod == ALYPVPlayMethodUrl) {
                [self updateControlLayerDataWithMediaInfo:nil];
            }else{
                [self updateControlLayerDataWithMediaInfo:[player getMediaInfo]];
            }
            
            AVCAirPlayView *view = [[AVCAirPlayView alloc]init];
            NSString * outputName =  [view activeAirplayOutputRouteName];
            if ([outputName isEqualToString:AVAudioSessionPortAirPlay] &&  ![_currentTrackInfo.vodPlayUrl containsString:@"encrypt"]) {
                //检测到当前视频输出端口是 正在投屏中
                NSNotification *notification = [[NSNotification alloc]initWithName:SwitchPlayer object:@"1" userInfo:nil];
                [self switchPlayer:notification];
            }
            if ([AlivcLongVideoCommonFunc getDLNAStatus]) {
                [self startDLNA:nil];
            }
            
            // 加密视频不支持投屏 非mp4 mov视频不支持airplay
            AVPMediaInfo *mediaInfo = [self getAliyunMediaInfo];
            for (AVPTrackInfo *info in mediaInfo.tracks) {
                NSLog(@"url:::::::%@",info.vodPlayUrl);
            }
            
            // 添加打点view 在没有视频广告的情况下添加打点功能
            if ([self isVideoAds] == NO) {
                AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
                progressView.playSlider.isSupportDot = YES;
                progressView.duration = self.aliPlayer.duration;
                NSMutableArray *timeArray = [[NSMutableArray alloc]init];
                for (NSDictionary *dic in self.dotsArray) {
                    NSNumber *time = @([[dic objectForKey:@"time"]integerValue]);
                    if ([[dic objectForKey:@"time"]integerValue] < self.aliPlayer.duration/1000) {
                        [timeArray addObject:time];
                    }
                }
                [progressView setDotWithTimeArray:timeArray];
            }
        }
            break;
        case AVPEventFirstRenderedStart: {
            [self.loadingView dismiss];
            self.popLayer.hidden = YES;
            [self.controlView setEnableGesture:YES];
            //开启常亮状态
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            //隐藏封面
            if (self.coverImageView) {
                self.coverImageView.hidden = YES;
                NSLog(@"播放器:首帧加载完成封面隐藏");
            }
            self.subTitleLabel.hidden = YES;
            NSLog(@"AVPEventFirstRenderedStart--首帧回调");
        }
            break;
        case AVPEventCompletion: {
            
            if (self.stsSource.playConfig && self.saveCurrentTime>=300) {
                
                self.previewView.hidden = NO;
                
                if (self.adsPlayerView) {
                    [self.adsPlayerView releaseAdsPlayer];
                    [self.adsPlayerView removeFromSuperview];
                    self.adsPlayerView = nil;
                }
            }else if (self.playerConfig && (self.playerConfig.sourceType != SourceTypeNull)) {
                if ([self.playerConfig sourceHasPreview]) {
                    [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeUnreachableNetwork popMsg:[@"试看结束" localString]];
                }else {
                    [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeUnreachableNetwork popMsg:[@"播放结束" localString]];
                }
            }else if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishWithAliyunVodPlayerView:)]) {
                [self.delegate onFinishWithAliyunVodPlayerView:self];
            }
            
            [self unlockScreen];
            self.subTitleLabel.hidden = YES;
        }
            
            break;
        case AVPEventLoadingStart: {
            [self.loadingView show];
        }
            break;
        case AVPEventLoadingEnd: {
            [self.loadingView setHidden:YES];
        }
            break;
        case AVPEventSeekEnd:{
            self.mProgressCanUpdate = YES;
            [self.loadingView dismiss];
            if (!self.adsPlayerView.isPlay) {
                [self resume];
            }
            NSLog(@"seekDone");
        }
            break;
        case AVPEventLoopingStart:
            self.subTitleLabel.hidden = YES;
            break;
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:happen:)]) {
        [self.delegate aliyunVodPlayerView:self happen:eventType];
    }
}

/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventWithString 播放器事件类型
 @param description 播放器事件说明
 @see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description {
    [MBProgressHUD showMessage:description inView:self];
    if(eventWithString == EVENT_PLAYER_NETWORK_RETRY_SUCCESS){
        [self reload];
    }
}

- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    //取消屏幕锁定旋转状态
    [self unlockScreen];
    //关闭loading动画
    [self.loadingView dismiss];
    
    //根据播放器状态处理seek时thumb是否可以拖动
    // [self.controlView updateViewWithPlayerState:self.aliPlayer.playerState isScreenLocked:self.isScreenLocked fixedPortrait:self.isProtrait];
    //根据错误信息，展示popLayer界面
    [self showPopLayerWithErrorModel:errorModel];
    NSLog(@"errorCode:%lu errorMessage:%@",(unsigned long)errorModel.code,errorModel.message);
}

- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    
    NSTimeInterval currentTime = position;
    NSTimeInterval durationTime = self.aliPlayer.duration;
    if ([self.delegate respondsToSelector:@selector(onCurrentWatchProgressChangedWithVodPlayerView:progress:)]) {
        NSInteger watchProgress = ceilf((CGFloat)position*100/self.aliPlayer.duration);
        if (watchProgress > 100) { watchProgress = 100; }
        if (watchProgress > 0) {
            [self.delegate onCurrentWatchProgressChangedWithVodPlayerView:self progress:watchProgress];
        }
    }
    self.saveCurrentTime = currentTime/1000;
    
    if (self.controlView.danmuManager.danmuManagerState != DanmuManagerStateAnimationing  && SCREEN_WIDTH >SCREEN_HEIGHT) {
        [self.controlView.danmuManager initStart];
        [self.controlView setDanmuViewLevel];

    }
    if (SCREEN_WIDTH >SCREEN_HEIGHT) {
        [self.controlView.danmuManager rollDanmu:currentTime/1000];
    }
    if (self.currentModel.authorityType == AlivcPlayVideoFreeTrialType && position >= self.currentModel.previewTime *1000) {
        [self.controlView updateProgressWithCurrentTime:300 *1000 durationTime:self.aliPlayer.duration];
        [self.aliPlayer stop];
        self.isPlay = NO;
        if (self.freeTrialView) {
            [self.freeTrialView removeFromSuperview];
            self.freeTrialView = nil;
        }
        self.freeTrialView = [[AVCFreeTrialView alloc]initWithFreeTime:self.currentModel.previewTime freeTrialType:FreeTrialEnd inView:self];
        [self.controlView setButtonEnnable:NO];
    }
    
    if ([self isVideoAds]) {
        // 试看功能
        if (self.stsSource.playConfig && currentTime < 300000) {
            [_adsPlayerView isPlayAdsCurrentTime:currentTime duration:durationTime];
            durationTime = durationTime + 3 * _adsPlayerView.seconds *1000;
            currentTime = _adsPlayerView.adsIndex *_adsPlayerView.seconds*1000 + currentTime;
        }
    }
    
    if (!self.adsPlayerView.isPlay) {
        if(self.mProgressCanUpdate == YES){
            if (self.keyFrameTime >0 && position < self.keyFrameTime) {
                // 屏蔽关键帧问题
                return;
            }
            [self.controlView updateProgressWithCurrentTime:currentTime durationTime:durationTime];
            self.keyFrameTime = 0;
        }
    }
    
    if (!self.previewView.isVip && self.previewView.previewTime > 0) {
        // 处于试看模式，如果超出时间，那么就停止播放
        if (position / 1000 > self.previewView.previewTime) {
            [self stop];
            self.previewView.hidden = NO;
        }
    }
    
}

/**
 @brief 视频缓存位置回调
 @param player 播放器player指针
 @param position 视频当前缓存位置
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    self.controlView.loadTimeProgress = (float)position/player.duration;
}

/**
 @brief 获取track信息回调
 @param player 播放器player指针
 @param info track流信息数组
 @see AVPTrackInfo
 */
- (void)onTrackReady:(AliPlayer*)player info:(NSArray<AVPTrackInfo*>*)info {
    
    AVPMediaInfo* mediaInfo = [player getMediaInfo];
    if ((nil != mediaInfo.thumbnails) && (0 < [mediaInfo.thumbnails count])) {
        [player setThumbnailUrl:[mediaInfo.thumbnails objectAtIndex:0].URL];
        self.trackHasThumbnai = YES;
    }else {
        self.trackHasThumbnai = NO;
    }
    self.controlView.info = info;
}

/**
 @brief track切换完成回调
 @param player 播放器player指针
 @param info 切换后的信息 参考AVPTrackInfo
 @see AVPTrackInfo
 */
- (void)onTrackChanged:(AliPlayer*)player info:(AVPTrackInfo*)info {
    //选中切换
    NSLog(@"%@",info.trackDefinition);
    self.currentTrackInfo = info;
    [self.loadingView dismiss];
    [self.controlView setBottomViewTrackInfo:info];
    NSString *showString = [NSString stringWithFormat:@"%@%@",[@"已为你切换至" localString],[info.trackDefinition localString]];
    [MBProgressHUD showMessage:showString inView:[UIApplication sharedApplication].keyWindow];
}

/**
 @brief 字幕显示回调
 @param player 播放器player指针
 @param trackIndex 字幕流索引.
 @param subtitleID  字幕ID.
 @param subtitle 字幕显示的字符串
 */
- (void)onSubtitleShow:(AliPlayer*)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID subtitle:(NSString *)subtitle {
    CGSize subtitleSize = [self getSubTitleLabelFrameWithSubtitle:subtitle];
    self.subTitleLabel.frame = CGRectMake((self.frame.size.width-subtitleSize.width)/2, [AliyunUtil isInterfaceOrientationPortrait]?20:64, subtitleSize.width, subtitleSize.height);
    self.subTitleLabel.center = self.center;
    self.subTitleLabel.text = subtitle;
    self.subTitleLabel.hidden = NO;
}

- (CGSize)getSubTitleLabelFrameWithSubtitle:(NSString *)subtitle {
    NSArray *subsectionArray = [subtitle componentsSeparatedByString:@"\n"];
    CGFloat maxWidth = 0;
    for (NSString *subsectionTitle in subsectionArray) {
        NSDictionary *dic = @{NSFontAttributeName:self.subTitleLabel.font};
        CGRect rect = [subsectionTitle boundingRectWithSize:CGSizeMake(9999, 18) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dic context:nil];
        if (rect.size.width > maxWidth) { maxWidth = rect.size.width; }
    }
    return CGSizeMake(maxWidth + 10 , 18 * subsectionArray.count + 10 );
}

/**
 @brief 字幕隐藏回调
 @param player 播放器player指针
 @param trackIndex 字幕流索引.
 @param subtitleID  字幕ID.
 */
- (void)onSubtitleHide:(AliPlayer*)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID {
    self.subTitleLabel.hidden = YES;
}

/**
 @brief 播放器状态改变回调
 @param player 播放器player指针
 @param oldStatus 老的播放器状态 参考AVPStatus
 @param newStatus 新的播放器状态 参考AVPStatus
 @see AVPStatus
 */
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    
    self.currentPlayStatus = newStatus;
    NSLog(@"播放器状态更新：%lu",(unsigned long)newStatus);
    if(_isEnterBackground){
        if (self.currentPlayStatus == AVPStatusStarted|| self.currentPlayStatus == AVPStatusPrepared) {
            [self pause];
        }
    }
    if (self.playerStatusChangeBlock) {
        self.playerStatusChangeBlock(newStatus);
    }
    //更新UI状态
    [self.controlView updateViewWithPlayerState:self.currentPlayStatus isScreenLocked:self.isScreenLocked fixedPortrait:self.isProtrait];
}

- (void)onGetThumbnailSuc:(int64_t)positionMs fromPos:(int64_t)fromPos toPos:(int64_t)toPos image:(id)image {
    self.thumbnailView.time = positionMs;
    self.thumbnailView.thumbnailImage = (UIImage *)image;
    self.thumbnailView.hidden = NO;
}

/**
 @brief 获取缩略图失败回调
 @param positionMs 指定的缩略图位置
 */
- (void)onGetThumbnailFailed:(int64_t)positionMs {
    NSLog(@"缩略图获取失败");
}

/**
 @brief 获取截图回调
 @param player 播放器player指针
 @param image 图像
 @see AVPImage
 */
- (void)onCaptureScreen:(AliPlayer*)player image:(AVPImage*)image {
    if (!image) {
        [MBProgressHUD showMessage:[@"截图为空" localString]  inView:self];
        return;
    }
    [AlivcLongVideoCommonFunc saveImage:image inView:self];
}

/**
@brief SEI回调
@param type 类型
@param data 数据
@see AVPImage
*/
- (void)onSEIData:(AliPlayer*)player type:(int)type data:(NSData *)data {
    NSString *str = [NSString stringWithUTF8String:data.bytes];
    NSLog(@"SEI: %@ %@", data, str);
}

#pragma mark dotDelegate

- (void)alivcLongVideoDotViewClickToseek:(NSTimeInterval)time {
    [self seekTo:time];
    self.dotView.hidden = YES;
}

#pragma mark - popdelegate
- (void)showPopViewWithType:(ALYPVErrorType)type{
    self.popLayer.hidden = YES;
    switch (type) {
        case ALYPVErrorTypeReplay: {
            //重播
            [self seekTo:0];
            [self.aliPlayer prepare];
            [self.aliPlayer start];
            self.isPlay = YES;
        }
            break;
        case ALYPVErrorTypeRetry: {
            self.isPlay = NO;
            if ([self.delegate respondsToSelector:@selector(onRetryButtonClickWithAliyunVodPlayerView:)]) {
                [self.delegate onRetryButtonClickWithAliyunVodPlayerView:self];
            }else {
                [self retry];
            }
        }
            break;
        case ALYPVErrorTypePause: {
            self.isPlay = NO;
            [self updatePlayDataReplayWithPlayMethod:self.playMethod];
        }
            break;
        case ALYPVErrorTypeStsExpired: {
            self.isPlay = NO;
            if ([self.delegate respondsToSelector:@selector(onSecurityTokenExpiredWithAliyunVodPlayerView:)]) {
                [self.delegate onSecurityTokenExpiredWithAliyunVodPlayerView:self];
            }else {
                [self retry];
            }
        }
            break;
        default:
            break;
    }
}

- (void)retry {
    [self stop];
    self.isPlay = NO;
    //重试播放
    if ([self networkChangedToShowPopView]) {
        return;
    }
    [self.loadingView show];
    [self.aliPlayer prepare];
    if (self.saveCurrentTime > 0) {
        [self seekTo:self.saveCurrentTime*1000];
    }
    [self.aliPlayer start];
    self.isPlay = YES;
}

/*
 * 功能 ：播放器
 * 参数 ：playMethod 播放方式
 */
- (void)updatePlayDataReplayWithPlayMethod:(ALYPVPlayMethod) playMethod{
    if (self.playerConfig && (self.playerConfig.sourceType != SourceTypeNull)) {
        switch (self.playerConfig.sourceType) {
            case SourceTypeUrl: {
                //artc默认参数设置
                if ([self.playerConfig.urlSource.playerUrl.absoluteString containsString:@"artc"]) {
                    AVPConfig *defaultConfig = [[AVPConfig alloc] init];
                    if (self.playerConfig.config.startBufferDuration == defaultConfig.startBufferDuration) {
                        defaultConfig.startBufferDuration = 10;
                    }else {
                        defaultConfig.startBufferDuration = self.playerConfig.config.startBufferDuration;
                    }
                    if (self.playerConfig.config.highBufferDuration == defaultConfig.highBufferDuration) {
                        defaultConfig.highBufferDuration = 10;
                    }else {
                        defaultConfig.highBufferDuration = self.playerConfig.config.highBufferDuration;
                    }
//                    if (self.playerConfig.config.maxBufferDuration == defaultConfig.maxBufferDuration) {
//                        defaultConfig.maxBufferDuration = 150;
//                    }else {
//                        defaultConfig.maxBufferDuration = self.playerConfig.config.maxBufferDuration;
//                    }
                    if (self.playerConfig.config.maxDelayTime == defaultConfig.maxDelayTime) {
                        defaultConfig.maxDelayTime = 1000;
                    }else {
                        defaultConfig.maxDelayTime = self.playerConfig.config.maxDelayTime;
                    }
                    defaultConfig.networkTimeout = self.playerConfig.config.networkTimeout;
                    defaultConfig.networkRetryCount = self.playerConfig.config.networkRetryCount;
                    defaultConfig.maxProbeSize = self.playerConfig.config.maxProbeSize;
                    defaultConfig.referer = self.playerConfig.config.referer;
                    defaultConfig.userAgent = self.playerConfig.config.userAgent;
                    defaultConfig.httpProxy = self.playerConfig.config.httpProxy;
                    defaultConfig.clearShowWhenStop = self.playerConfig.config.clearShowWhenStop;
                    defaultConfig.httpHeaders = self.playerConfig.config.httpHeaders;
                    defaultConfig.enableSEI = self.playerConfig.config.enableSEI;
                    [self.aliPlayer setConfig:defaultConfig];
                }
                [self.aliPlayer setUrlSource:self.playerConfig.urlSource];
            }
                break;
            case SourceTypeSts: {
                [self.aliPlayer setStsSource:self.playerConfig.vidStsSource];
            }
                break;
            case SourceTypeMps: {
                [self.aliPlayer setMpsSource:self.playerConfig.vidMpsSource];
            }
                break;
            case SourceTypeAuth: {
                [self.aliPlayer setAuthSource:self.playerConfig.vidAuthSource];
            }
                break;
            case SourceTypeLiveSts: {
                [self.aliPlayer setLiveStsSource:self.playerConfig.liveStsSource];
                __weak typeof(self) weakSelf = self;
               [self.aliPlayer setVerifyStsCallback:^AVPStsStatus(AVPStsInfo info) {
                   NSDate *now = [NSDate new];
                   NSTimeInterval diff = weakSelf.playerConfig.liveStsExpireTime - now.timeIntervalSince1970;
                   if (diff>300) {
                       return Valid;
                   }
                   
                   if ([weakSelf.delegate respondsToSelector:@selector(onUpdateLiveStsWithAliyunVodPlayerView:)]) {
                       [weakSelf.delegate onUpdateLiveStsWithAliyunVodPlayerView:weakSelf];
                   }
                   return Pending;
               }];
            }
                break;
            default:
                break;
        }
        [self.loadingView show];
        [self.aliPlayer prepare];
        if (self.saveCurrentTime > 0) {
            [self seekTo:self.saveCurrentTime*1000];
        }
        [self.aliPlayer start];
        self.isPlay = YES;
    }else {
        self.urlSource = [[AVPUrlSource alloc]init];
        self.urlSource.playerUrl = self.localSource.url;
        
        self.stsSource = [[AVPVidStsSource alloc]initWithVid:self.stsModel.videoId accessKeyId:self.stsModel.accessKeyId accessKeySecret:self.stsModel.accessSecret securityToken:self.stsModel.ststoken region:@""];
        // 再次配置试看
        BOOL isVip = [[AlivcLongVideoCommonFunc getUDSetWithIndex:5]boolValue];
        if (isVip == NO && self.currentLongVideoModel.isVip && [self.currentLongVideoModel.isVip isEqualToString:@"true"]) {
            VidPlayerConfigGenerator* vp = [[VidPlayerConfigGenerator alloc] init];
            [vp addVidPlayerConfigByStringValue:@"PlayDomain" value:@"alivc-demo-vod-player.aliyuncs.com"];
            [vp setPreviewTime:300];
            self.stsSource.playConfig = [vp generatePlayerConfig];
        }
        
         [self.controlView updateProgressWithCurrentTime:0 durationTime:self.aliPlayer.duration];
        
        self.mpsSource = [[AVPVidMpsSource alloc]initWithVid:self.mpsModel.videoId accId:self.mpsModel.accessKey accSecret:self.mpsModel.accessSecret stsToken:self.mpsModel.stsToken authInfo:self.mpsModel.stsToken region:self.mpsModel.region playDomain:self.mpsModel.playDomain mtsHlsUriToken:self.mpsModel.hlsUriToken];
        
        self.authSource = [[AVPVidAuthSource alloc]initWithVid:self.playAuthModel.videoId playAuth:self.playAuthModel.playAuth region:@""];
        
        switch (playMethod) {
            case ALYPVPlayMethodUrl: {
                [self.aliPlayer setUrlSource:self.urlSource];
            }
                break;
            case ALYPVPlayMethodMPS: {
                [self.aliPlayer setMpsSource:self.mpsSource];
            }
                break;
            case ALYPVPlayMethodPlayAuth: {
                [self.aliPlayer setAuthSource:self.authSource];
            }
                break;
            case ALYPVPlayMethodSTS: {
                [self.aliPlayer setStsSource:self.stsSource];
            }
                break;
            default:
                break;
        }
        [self.loadingView show];
        [self.aliPlayer prepare];
        if (self.saveCurrentTime > 0) {
            [self seekTo:self.saveCurrentTime*1000];
        }
        [self.aliPlayer start];
        self.isPlay = YES;
    }
}

- (void)onBackClickedWithAlPVPopLayer:(AliyunPlayerViewPopLayer *)popLayer{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onBackViewClickWithAliyunVodPlayerView:)]){
        [self.delegate onBackViewClickWithAliyunVodPlayerView:self];
    }else{
        [self stop];
    }
}

#pragma mark - loading动画
- (void)loadAnimation {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [self.layer addAnimation:animation forKey:nil];
}

//取消屏幕锁定旋转状态
- (void)unlockScreen{
    //弹出错误窗口时 取消锁屏。
    if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:lockScreen:)]) {
        if (self.isScreenLocked == YES||self.fixedPortrait) {
            [self.delegate aliyunVodPlayerView:self lockScreen:NO];
            //弹出错误窗口时 取消锁屏。
            [self.controlView cancelLockScreenWithIsScreenLocked:self.isScreenLocked fixedPortrait:self.fixedPortrait];
            self.isScreenLocked = NO;
        }
    }
}

/**
 * 功能：声音调节
 */
- (void)setVolume:(float)volume{
    [self.aliPlayer setVolume:volume];
}

/// 播放速度 0.5-2.0之间，1为正常播放
/// @param rate 0.5-2.0之间，1为正常播放
- (void)setRate:(CGFloat)rate {
    self.aliPlayer.rate = rate;
}

#pragma mark - 设置提示语
- (void)setPlayFinishDescribe:(NSString *)des{
    [AliyunUtil setPlayFinishTips:des];
}

- (void)setNetTimeOutDescribe:(NSString *)des{
    [AliyunUtil setNetworkTimeoutTips:des];
}

- (void)setNoNetDescribe:(NSString *)des{
    [AliyunUtil setNetworkUnreachableTips:des];
}

- (void)setLoaddataErrorDescribe:(NSString *)des{
    [AliyunUtil setLoadingDataErrorTips:des];
}

- (void)setUseWanNetDescribe:(NSString *)des{
    [AliyunUtil setSwitchToMobileNetworkTips:des];
}

#pragma mark - public method

//更新封面图片
- (void)updateCoverWithCoverUrl:(NSString *)coverUrl{
    //以用户设置的为先，标题和封面,用户在控制台设置coverurl地址
    if (self.coverImageView) {
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImageView.clipsToBounds = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.coverImageView.image = [UIImage imageWithData:data];
                if (!self.coverImageView.hidden) {
                    if ([self isVideoAds]) {
                        self.coverImageView.hidden = YES;
                    }else {
                        self.coverImageView.hidden = NO;
                    }
                    NSLog(@"播放器:展示封面");
                }
            });
        });
    }
}

//更新controlLayer界面ui数据
- (void)updateControlLayerDataWithMediaInfo:(AVPMediaInfo *)mediaInfo{
    //以用户设置的为先，标题和封面,用户在控制台设置coverurl地址
    if (!self.coverUrl && mediaInfo.coverURL && mediaInfo.coverURL.length>0) {
        [self updateCoverWithCoverUrl:mediaInfo.coverURL];
    }
    //设置数据
    self.controlView.videoInfo = mediaInfo;
    //标题, 未播放URL 做备用判定
    if (!self.currentMediaTitle) {
        if (mediaInfo.title && mediaInfo.title.length>0) {
            self.controlView.title = mediaInfo.title;
        }else if(self.localSource.url){
            NSArray *ary = [[self.localSource.url absoluteString] componentsSeparatedByString:@"/"];
            self.controlView.title = ary.lastObject;
        }
    }else{
        self.controlView.title = self.currentMediaTitle;
    }
}

//根据错误信息，展示popLayer界面
- (void)showPopLayerWithErrorModel:(AVPErrorModel *)errorModel{
    NSString *errorShowMsg = [NSString stringWithFormat:@"%@\n errorCode:%d",errorModel.message,(int)errorModel.code];
    
    //老的逻辑
//    if (errorModel.code == ERROR_SERVER_POP_UNKNOWN) {
//        if ([self.delegate respondsToSelector:@selector(onSecurityTokenExpiredWithAliyunVodPlayerView:)]) {
//            [self.delegate onSecurityTokenExpiredWithAliyunVodPlayerView:self];
//        }else {
//            [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeSecurityTokenExpired popMsg:errorShowMsg];
//        }
//    }else {
//        [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeServerError popMsg:errorShowMsg];
//    }
    
    //新逻辑，点击重试后，重新获取信息
    if (self.playerConfig && (self.playerConfig.sourceType == SourceTypeNull) && errorModel.code == ERROR_SERVER_POP_UNKNOWN) {
        [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeSecurityTokenExpired popMsg:errorShowMsg];
    }else {
        [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeServerError popMsg:errorShowMsg];
    }
    [self unlockScreen];
}

#pragma mark - AliyunControlViewDelegate
- (void)onBackViewClickWithAliyunControlView:(AliyunPlayerViewControlView *)controlView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onBackViewClickWithAliyunVodPlayerView:)]){
        [self.delegate onBackViewClickWithAliyunVodPlayerView:self];
    } else {
        [self stop];
    }
}

- (void)onDownloadButtonClickWithAliyunControlView:(AliyunPlayerViewControlView *)controlViewP{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDownloadButtonClickWithAliyunVodPlayerView:)]) {
        [self.delegate onDownloadButtonClickWithAliyunVodPlayerView:self];
    }
}

- (void)onClickedPlayButtonWithAliyunControlView:(AliyunPlayerViewControlView *)controlView{
    AVPStatus state = [self playerViewState];
    if (state == AVPStatusStarted){
        [self pause];
        self.isPlay = NO;
    }else if (state == AVPStatusPrepared){
        [self.aliPlayer start];
        self.isPlay = YES;
    }else if(state == AVPStatusPaused){
        [self resume];
        self.isPlay = YES;
    }else if (state == AVPStatusStopped){
        if (self.playerConfig) {
            [self.aliPlayer prepare];
            self.isPlay = NO;
        }else {
            [self resume];
            self.isPlay = YES;
        }
    }
}

- (void)onClickedfullScreenButtonWithAliyunControlView:(AliyunPlayerViewControlView *)controlView{
    
    if(self.fixedPortrait){
        controlView.lockButton.hidden = self.isProtrait;
        if(!self.isProtrait){
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            self.isProtrait = YES;
        }else{
            self.frame = self.saveFrame;
            self.isProtrait = NO;
        }
        
        [AliyunUtil setFullOrHalfScreen];
    }else{
        if(self.isScreenLocked){
            return;
        }
        
        [AliyunUtil setFullOrHalfScreen];
    }
    controlView.isProtrait = self.isProtrait;
    [self setNeedsLayout];
}

- (void)aliyunControlView:(AliyunPlayerViewControlView *)controlView dragProgressSliderValue:(float)progressValue event:(UIControlEvents)event{
    
    NSInteger totalTime = 0;
    if ([self isVideoAds]) {
        totalTime = self.aliPlayer.duration + _adsPlayerView.seconds * 3 *1000;
    }else {
        totalTime = self.aliPlayer.duration;
    }
    AliyunPlayerViewProgressView  *progressView = [self.controlView viewWithTag:1076398];
    
    if(totalTime==0){
        [progressView.playSlider setEnabled:NO];
        return;
    }
    
    switch (event) {
        case UIControlEventTouchDown: {
            if ( progressView.playSlider.isSupportDot == YES) {
                NSInteger dotTime = [self.dotView checkIsTouchOntheDot:totalTime *progressValue inScope:totalTime * 0.05];
                if (dotTime >0) {
                    if (self.dotView.hidden == YES ) {
                        self.dotView.hidden = NO;
                        CGFloat x = progressView.frame.origin.x;
                        CGFloat progressWidth = progressView.frame.size.width;
                        self.dotView.frame = CGRectMake(x+progressWidth *progressValue, 280, 150, 30);
                        [self.dotView showViewWithTime:dotTime];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.dotView.hidden = YES;
                        });
                    }
                }
            }
        }
            break;
        case UIControlEventValueChanged: {
            self.mProgressCanUpdate = NO;
            //更新UI上的当前时间
            [self.controlView updateCurrentTime:progressValue*totalTime durationTime:totalTime];
            if (self.trackHasThumbnai == YES) {
                [self.aliPlayer getThumbnail:totalTime *progressValue];
            }
        }
            break;
//        case UIControlEventTouchCancel:
        case UIControlEventTouchUpOutside:
        case UIControlEventTouchUpInside: {
            self.thumbnailView.hidden = YES;
            if (self.stsSource.playConfig  && progressValue *self.aliPlayer.duration > 300*1000) {
                
                self.previewView.hidden = NO;
                [self.adsPlayerView releaseAdsPlayer];
                [self.adsPlayerView removeFromSuperview];
                self.adsPlayerView = nil;
                [self.aliPlayer stop];
                self.isPlay = NO;
            }else if ([self isVideoAds]) {
                CGFloat seek = [_adsPlayerView allowSeek:progressValue];
                if (seek == 0) {
                    //  在广告播放期间不能seek
                    return;
                }else if (seek == 1.0){
                    
                    // 正常seek
                    NSTimeInterval seekTime = [_adsPlayerView seekWithProgressValue:progressValue];
                    [self seekTo:seekTime];
                }else if (seek == 2){
                    // 跳跃广告的seek，直接播放广告
                    self.mProgressCanUpdate = YES;
                    return;
                }
            } else {
                // 先判断是否是试看
                if (self.currentModel.authorityType == AlivcPlayVideoFreeTrialType && self.currentModel.previewTime > 0 && self.currentModel.previewTime < progressValue*self.aliPlayer.duration) {
                    self.currentPlayStatus = AVPStatusPaused;
                    [self.aliPlayer stop];
                    self.isPlay = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        //在播放器回调的方法里，防止sdk异常不进行seekdone的回调，在3秒后增加处理，防止ui一直异常
                        self.mProgressCanUpdate = YES;
                    });
                    return;
                }else{
                    [self seekTo:progressValue*self.aliPlayer.duration];
                }
            }
            NSLog(@"t播放器测试：TouchUpInside 跳转到%.1f",progressValue*self.aliPlayer.duration);
            AVPStatus state = [self playerViewState];
            if (state == AVPStatusPaused) {
                [self.aliPlayer start];
                self.isPlay = YES;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //在播放器回调的方法里，防止sdk异常不进行seekdone的回调，在3秒后增加处理，防止ui一直异常
                self.mProgressCanUpdate = YES;
            });
        }
            break;
            //点击事件
        case UIControlEventTouchDownRepeat:{
            
            self.mProgressCanUpdate = NO;
            if ([self isVideoAds]) {
                NSTimeInterval seekTime = [_adsPlayerView seekWithProgressValue:progressValue];
                [self seekTo:seekTime];
            }else {
                NSLog(@"UIControlEventTouchDownRepeat::%f",progressValue);
                [self seekTo:progressValue*self.aliPlayer.duration];
            }
            NSLog(@"t播放器测试：DownRepeat跳转到%.1f",progressValue*self.aliPlayer.duration);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //在播放器回调的方法里，防止sdk异常不进行seekdone的回调，在3秒后增加处理，防止ui一直异常
                self.mProgressCanUpdate = YES;
            });
        }
            break;
            
//        case UIControlEventTouchCancel:
//            self.mProgressCanUpdate = YES;
//            self.thumbnailView.hidden = YES;
//            break;
            
        default:
            self.mProgressCanUpdate = YES;
            break;
    }
}

- (void)aliyunControlView:(AliyunPlayerViewControlView *)controlView qualityListViewOnItemClick:(int)index{
    
    //切换清晰度
    if ( self.currentTrackInfo.trackIndex == index) {
        
        NSString *showString = [NSString stringWithFormat:@"%@%@",[@"当前清晰度为" localString],[_currentTrackInfo.trackDefinition localString]];
        [MBProgressHUD showMessage:showString inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    [self.loadingView show];
    [self.aliPlayer selectTrack:index];
    if(self.currentPlayStatus == AVPStatusPaused){
        [self resume];
    }
}

#pragma mark - controlViewDelegate
- (void)onLockButtonClickedWithAliyunControlView:(AliyunPlayerViewControlView *)controlView{
    controlView.lockButton.selected = !controlView.lockButton.isSelected;
    self.isScreenLocked =controlView.lockButton.selected;
    //锁屏判定
    [controlView lockScreenWithIsScreenLocked:self.isScreenLocked fixedPortrait:self.fixedPortrait];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:lockScreen:)]) {
        BOOL lScreen = self.isScreenLocked;
        if (self.isProtrait) {
            lScreen = YES;
        }
        [self.delegate aliyunVodPlayerView:self lockScreen:lScreen];
    }
}

- (void)onSendTextButtonClickedWithAliyunControlView:(AliyunPlayerViewControlView*)controlView {
    self.danmuSendV = [[QHDanmuSendView alloc] initWithFrame:self.bounds];
//    [self addSubview:self.danmuSendV];
    self.danmuSendV.deleagte = self;
    [self.danmuSendV showAction:self];
    [self.aliPlayer pause];
    self.isPlay = NO;
    NSLog(@"发送弹幕");
}

- (void)onSnapshopButtonClickedWithAliyunControlView:(AliyunPlayerViewControlView*)controlView {
    NSLog(@"截图");
    
    [self.aliPlayer snapShot];
}

- (void)onSpeedViewClickedWithAliyunControlView:(AliyunPlayerViewControlView *)controlView {
    [self.moreView showSpeedViewMoveInAnimate];
}

- (void)onSpeedViewClickedWithAliyunControlView:(AliyunPlayerViewControlView *)controlView rateTitle:(NSString *)rateTitle {
    if ([rateTitle isEqualToString:@"0.75X"]) {
        [self setRate:0.75];
    }else if ([rateTitle isEqualToString:@"1.0X"]) {
        [self setRate:1];
    }else if ([rateTitle isEqualToString:@"1.25X"]) {
        [self setRate:1.25];
    }else if ([rateTitle isEqualToString:@"1.5X"]) {
        [self setRate:1.5];
    }else if ([rateTitle isEqualToString:@"2.0X"]) {
        [self setRate:2];
    }
}

- (void)aliyunControlView:(AliyunPlayerViewControlView*)controlView selectTrackIndex:(NSInteger)trackIndex {
    [self.aliPlayer selectTrack:(int)trackIndex];
}

#pragma mark AliyunViewMoreViewDelegate
- (void)aliyunViewMoreView:(AliyunViewMoreView *)moreView clickedDownloadBtn:(UIButton *)downloadBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDownloadButtonClickWithAliyunVodPlayerView:)]) {
        [self.delegate onDownloadButtonClickWithAliyunVodPlayerView:self];
    }
}

- (void)aliyunViewMoreView:(AliyunViewMoreView *)moreView clickedAirPlayBtn:(UIButton *)airPlayBtn{
  
    if (self.controlView.playMethod == ALYPVPlayMethodLocal) {
         [MBProgressHUD showMessage:[@"当前视频不支持投屏" localString]  inView:self];
        return;
    }
    AlivcVideoPlayScreenSelectViewController *vc = [[AlivcVideoPlayScreenSelectViewController alloc]init];
    vc.playUrl = _currentTrackInfo.vodPlayUrl;
    UIViewController * controller =  [self findSuperViewController:self];
    [controller.navigationController pushViewController:vc animated:YES];
}

- (void)aliyunViewMoreView:(AliyunViewMoreView *)moreView clickedBarrageBtn:(UIButton *)barrageBtn{
    [self.barrageSettingView showBarrageSettingViewInAnimate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedBarrageBtnWithVodPlayerView:)]) {
        [self.delegate onClickedBarrageBtnWithVodPlayerView:self];
    }
}

- (void)aliyunViewMoreView:(AliyunViewMoreView *)moreView speedChanged:(float)speedValue{
    [self.aliPlayer setRate:speedValue];
}

- (void)aliyunViewMoreView:(AliyunViewMoreView *)moreView scalingIndexChanged:(NSInteger)index {
    switch (index) {
        case 0:
            self.aliPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
            break;
        case 1:
            self.aliPlayer.scalingMode = AVP_SCALINGMODE_SCALETOFILL;
            break;
        case 2:
            self.aliPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFILL;
            break;
        default:
            break;
    }
    NSLog(@"选择了画面比例模式 %ld",(long)index);
}

- (void)aliyunViewMoreView:(AliyunViewMoreView *)moreView loopIndexChanged:(NSInteger)index {
    switch (index) {
        case 0:
            self.aliPlayer.loop = YES;
            break;
        case 1:
            self.aliPlayer.loop = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Custom

- (void)setUIStatusToReplay{
    [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeUseMobileNetwork  popMsg:[@"重播" localString]];
}

- (void)setUIStatusToRetryWithMessage:(NSString *)message {
    [self.popLayer showPopViewWithCode:ALYPVPlayerPopCodeServerError  popMsg:message];
}

#pragma mark aliyunVodAdsPlayer delegate

- (void)aliyunVodAdsPlayerViewCompletePlay:(NSTimeInterval)seekTime {
    
    if (self.adsPlayerView.adsIndex == 1) {
        [self addSubview:self.previewLogoView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.previewLogoView removeFromSuperview];
        });
    }
    
    self.adsPlayerView.frame = CGRectZero;
    self.mProgressCanUpdate = YES;
    if (![AliyunUtil isInterfaceOrientationPortrait]){
        [self.controlView loopViewStart];
    }
    
    if (self.adsPlayerView.adsIndex == 3) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishWithAliyunVodPlayerView:)]) {
            [self.delegate onFinishWithAliyunVodPlayerView:self];
        }
    }else {
        if (self.playerViewState == AVPStatusPaused) {
            [self resume];
            if (seekTime >0) {
                self.mProgressCanUpdate = NO;
                if (seekTime == [[_adsPlayerView.insertTimeArray objectAtIndex:1]floatValue]) {
                    self.keyFrameTime = seekTime;
                }
                [self seekTo:seekTime];
            }
        }else if(self.playerViewState == AVPStatusPrepared){
            [self.aliPlayer start];
            self.isPlay = YES;
        }
    }
}

- (void)aliyunVodAdsPlayerViewStartPlay {
    self.adsPlayerView.frame = self.bounds;
    [self bringSubviewToFront:_adsPlayerView];
    [self.controlView loopViewPause];
    [self pause];
    if (self.imageAdsView) {
        [self.imageAdsView removeFromSuperview];
        self.imageAdsView = nil;
    }
}

#pragma mark aliyunBarrageSettingViewDelegate

- (void)aliyunBarrageSettingViewClickedResetBtn:(AVCBarrageSettingView *)view {
    NSLog(@"点击恢复默认");
    self.controlView.danmuManager.alpha = 1;
    self.controlView.danmuManager.speed = 1;
    [self danmuManagerResetHeightWithVaule:1];
}

- (void)aliyunBarrageSettingView:(AVCBarrageSettingView *)moreView sliderVauleChanged:(float)vaule sliderIndex:(NSInteger)index {
    NSLog(@"%f  %ld",vaule,(long)index);
    if (index == 0) {
        self.controlView.danmuManager.alpha = 1 - vaule;
    }else if (index == 1) {
        [self danmuManagerResetHeightWithVaule:vaule];
    }else {
        self.controlView.danmuManager.speed = vaule;
    }
}

- (void)danmuManagerResetHeightWithVaule:(float)vaule {
    NSInteger loopWidth = ScreenHeight;
    NSInteger loopHeight = ScreenWidth;
    if (ScreenWidth > ScreenHeight) {
        loopWidth = ScreenWidth;
        loopHeight = ScreenHeight;
    }
    [self.controlView.danmuManager resetDanmuWithFrame:CGRectMake(0, 40, loopWidth, (loopHeight-140)*0.9*vaule+100)];
}

#pragma mark QHDanmuSendViewDelegate

- (void)sendDanmu:(QHDanmuSendView *)danmuSendV info:(NSString *)info {
    if (info && info.length>0) {
        [self.controlView.danmuManager insertDanmu:@{kDanmuContentKey:info, kDanmuTimeKey:@(self.saveCurrentTime+2)}];
    }
    [self resume];
}

- (void)closeSendDanmu:(QHDanmuSendView *)danmuSendV {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.adsPlayerView && self.adsPlayerView.isPlay == YES) {
        [self.adsPlayerView goAdsLink];
    }
}

- (BOOL)isImageAds {
    if (self.currentModel.authorityType == AlivcPlayVideoImageAdsType || self.currentLongVideoModel.authorityType == AlivcPlayVideoImageAdsType) {
        return YES;
    }
    return NO;
}

- (BOOL)isVideoAds {
    if (self.currentModel.authorityType == AlivcPlayVideoVideoAdsType || self.currentLongVideoModel.authorityType == AlivcPlayVideoVideoAdsType ) {
        return YES;
    }
    return NO;
}

- (BOOL)isWaterMark {
    if (self.currentModel.waterMark == YES || self.currentLongVideoModel.waterMark == YES ) {
        return YES;
    }
    return NO;
}

- (void)pauseAdsImage {
    if (self.imageAdsView) {
        [self.imageAdsView pauseAds];
    }
}

- (BOOL)reviveAdsImage{
    if (self.imageAdsView) {
        return   [self.imageAdsView reviveAds];
    }
    return NO;
}

- (void)pausePlayAds {
    if (self.adsPlayerView.isPlay) {
        [self.adsPlayerView pausePlay];
    }
}

- (void)resumePlayAds {
    [self.adsPlayerView startPlay];
}

- (void)loopViewStartAnimation {
    [self.controlView loopViewStartAnimation];
}

- (void)cleanLastFrame:(BOOL)show {
    AVPConfig *config = [self.aliPlayer getConfig];
    config.clearShowWhenStop = show;
    [self.aliPlayer setConfig:config];
}

- (void)hardwareDecoder:(BOOL)decoder {
    self.aliPlayer.enableHardwareDecoder = decoder;
}

- (void)controlViewEnable:(BOOL)enable {
    if (enable == NO) {
        [self.controlView showViewWithOutDelayHide];
    }else {
        [self.controlView showView];
    }
}

- (BOOL)isPresent {
    UIViewController *vc = [self findCurrentViewController];
    UIViewController *viewVc = [self findSuperViewController:self];
    if (vc == viewVc ) {
        if (self.adsPlayerView && self.adsPlayerView.isPlay == YES) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (UIViewController *)findCurrentViewController {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

- (void)setPlayerAllConfig:(AlivcVideoPlayPlayerConfig *)playerConfig {
    _playerConfig = playerConfig;
    self.aliPlayer.enableHardwareDecoder = playerConfig.enableHardwareDecoder;
    self.aliPlayer.mirrorMode = playerConfig.mirrorMode;
    self.aliPlayer.rotateMode = playerConfig.rotateMode;
    if (playerConfig.config) { [self.aliPlayer setConfig:playerConfig.config]; }
    if (playerConfig.cacheConfig) { [self.aliPlayer setCacheConfig:playerConfig.cacheConfig]; }
    self.noneAdvertisement = YES;
    self.currentLongVideoModel.authorityType = AlivcPlayVideoNoneAdsType;
}

- (void)playWithPlayerConfig:(AlivcVideoPlayPlayerConfig *)playerConfig {
    _playerConfig = playerConfig;
    if ([self networkChangedToShowPopView]) {
        return;
    }
    [self updatePlayDataReplayWithPlayMethod:self.playMethod];
}

- (void)playwithUpdateLiveSts:(AlivcVideoPlayPlayerConfig *)playerConfig{
    _playerConfig = playerConfig;
   if ([self networkChangedToShowPopView]) {
       return;
   }
    [self.aliPlayer updateLiveStsInfo:self.playerConfig.liveStsSource.accessKeyId accKey:self.playerConfig.liveStsSource.accessKeySecret token:self.playerConfig.liveStsSource.securityToken region:self.playerConfig.liveStsSource.region];
}

/// ===============================================================================

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    self.aliPlayer.muted = muted;
}


@end
