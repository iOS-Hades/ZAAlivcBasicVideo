//
//  AlivcLongVideoPlayView.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/26.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import "AliyunVodPlayerViewDefine.h"
#import "AlivcVideoPlayListModel.h"
#import "AlivcLongVideoPreviewView.h"
#import "AlivcLongVideoTVModel.h"
#import "AlivcVideoPlayPlayerConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class AlivcLongVideoPlayView;

@protocol AliyunVodPlayerViewDelegate <NSObject>

//界面
/**
 * 功能：返回按钮事件
 * 参数：playerView ：AliyunVodPlayerView
 */
- (void)onBackViewClickWithAliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView;

/**
 * 功能：下载按钮事件
 * 参数：playerView ：AliyunVodPlayerView
 */
- (void)onDownloadButtonClickWithAliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView;

/// 功能：倍数播放时间
/// @param playerView 播放视图
- (void)onRatePlayButtonClickWithAliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView;

/**
 * 功能：所有事件发生的汇总
 * 参数：event ： 发生的事件
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView happen:(AVPEventType )event;

/**
 * 功能：暂停事件
 * 参数：currentPlayTime ： 暂停时播放时间
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView onPause:(NSTimeInterval)currentPlayTime;

/**
 * 功能：继续事件
 * 参数：currentPlayTime ： 继续播放时播放时间。
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView onResume:(NSTimeInterval)currentPlayTime;

/**
 * 功能：播放完成事件 ，请区别stop（停止播放）
 * 参数：playerView ： AliyunVodPlayerView
 */
- (void)onFinishWithAliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView;

/**
 * 功能：停止播放
 * 参数：currentPlayTime ： 播放停止时播放时间。
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView onStop:(NSTimeInterval)currentPlayTime;

/**
 * 功能：拖动进度条结束事件
 * 参数：seekDoneTime ： seekDone时播放时间。
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView onSeekDone:(NSTimeInterval)seekDoneTime;

/**
 * 功能：是否锁屏
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView lockScreen:(BOOL)isLockScreen;

/**
 * 功能：返回调用全屏
 * 参数：isFullScreen ： 点击全屏按钮后，返回当前是否全屏状态
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView fullScreen:(BOOL)isFullScreen;

/**
 * 功能：循环播放开始
 * 参数：playerView ：AliyunVodPlayerView
 */
- (void)onCircleStartWithVodPlayerView:(AlivcLongVideoPlayView *)playerView;

/**
 sts token过期回调
 
 @param playerView AliyunVodPlayerView
 */
- (void)onSecurityTokenExpiredWithAliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView;

- (void)onClickedAirPlayButtonWithVodPlayerView:(AlivcLongVideoPlayView *)playerView;

- (void)onClickedBarrageBtnWithVodPlayerView:(AlivcLongVideoPlayView *)playerView;

- (void)onCurrentWatchProgressChangedWithVodPlayerView:(AlivcLongVideoPlayView *)playerView progress:(NSInteger)Progress;

- (void)onRetryButtonClickWithAliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView;

- (void)onUpdateLiveStsWithAliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView;

@end

@interface AlivcLongVideoPlayView : UIView

/// 上部控制视图的返回按钮和标题是否隐藏
/// @param backBtnisShow 返回按钮是否隐藏
/// @param titleisShow 标题标签是否隐藏
- (void)setTopViewWithBackBtnisShow:(BOOL)backBtnisShow topViewWithTitleisShow:(BOOL)titleisShow;

/// 是否正在播放
@property (nonatomic, assign) BOOL isPlay;

@property (nonatomic, assign)NSTimeInterval longVideoDuration;
/**
 * 功能：当前播放视频的打点信息。
 */
@property (nonatomic, strong)NSArray *dotsArray;
/**
 * 功能：非VIP试看当前视频。
 */
@property (nonatomic, strong)AlivcLongVideoPreviewView *previewView;
/**
 * 功能：当前播放视频支持的清晰度信息。
 */
@property  (nonatomic, strong) NSArray <AVPTrackInfo *>* videoTrackInfo;
/**
 * 功能：当前播放视频的清晰度信息。
 */
@property (strong, nonatomic) AVPTrackInfo *currentTrackInfo;
/**
 * 功能：当前播放视频的model。
 */
@property (nonatomic, strong) AlivcVideoPlayListModel * currentModel;

/**
 * 功能：当前播放长视频视频的model。
 */
@property (nonatomic, strong)  AlivcLongVideoTVModel * currentLongVideoModel;
/*
 功能：设置AliyunVodPlayerViewDelegate代理
 */
@property (nonatomic, weak) id<AliyunVodPlayerViewDelegate> delegate;

/**
 * 功能：设置网络超时时间，单位毫秒
 * 备注：当播放网络流时，设置网络超时时间，默认15000毫秒
 */
@property(nonatomic, assign) int timeout;

/*
 *************************************************
 可参考UI播放器Demo中的使用！可参考UI播放器Demo中的使用！可参考UI播放器Demo中的使用！
 *************************************************
 
 isScreenLocked 会锁定，播放器界面尺寸。
 fixedPortrait yes：竖屏全屏；no：横屏全屏;
 isLockScreen对isLockPortrait无效。
 - (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView lockScreen:(BOOL)isLockScreen此方法在isLockPortrait==yes时，返回的islockscreen总是yes；
 isLockScreen和isLockPortrait，因为播放器时UIView，是否旋转需要配合UIViewController来控制物理旋转。
 假设：支持竖屏全屏
 self.playerView.fixedPortrait = YES;
 self.playerView.isScreenLocked = NO;
 self.isLock = self.playerView.isScreenLocked||self.playerView.fixedPortrait?YES:NO;
 
 支持横屏全屏
 self.playerView.fixedPortrait = NO;
 self.playerView.isScreenLocked = NO;
 self.isLock = self.playerView.isScreenLocked||self.playerView.fixedPortrait?YES:NO;
 
 锁定屏幕
 self.playerView.fixedPortrait = NO;
 self.playerView.isScreenLocked = YES;
 self.isLock = self.playerView.isScreenLocked||self.playerView.fixedPortrait?YES:NO;
 
 self.isLock时来判定UIViewController 是否支持物理旋转。如果viewcontroller在navigationcontroller中，需要添加子类重写navigationgController中的 以下方法，根据实际情况做判定 。
 */
@property (nonatomic, assign)BOOL isScreenLocked;
@property (nonatomic, assign)BOOL fixedPortrait;

/**
 * 参数：coverUrl 图片地址。
 * 功能：封面图片。
 */
@property (nonatomic, strong) NSURL *coverUrl;

/**
 功能：初始化界面皮肤
 备注：默认皮肤为蓝色
 */
@property (nonatomic, assign) AliyunVodPlayerViewSkin viewSkin;

/**
 功能：初始化窗口大小
 参数：frame:视图view大小
 备注：默认皮肤为蓝色
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 功能：初始化窗口大小，并且设置播放器窗口皮肤
 参数：
 frame:视图view大小
 skin: 皮肤样式，类型有：
 AliyunVodPlayerViewSkinBlue,
 AliyunVodPlayerViewSkinRed,
 AliyunVodPlayerViewSkinOrange,
 AliyunVodPlayerViewSkinGreen
 */
- (instancetype)initWithFrame:(CGRect)frame andSkin:(AliyunVodPlayerViewSkin)skin;

/**
 *功能：临时AccessKeyId、AccessKeySecret和SecurityToken：开启RAM授权，并通过STS授权系统提供的OpenAPI或SDK获取的AccessKeyId、AccessKeySecret和SecurityToken，用于播放和下载请求
 *备注：参数明细->https://help.aliyun.com/document_detail/28788.html?spm=5176.doc28787.6.706.2G5SLS
 *版本：3.2.0版本使用
 */
- (void)playViewPrepareWithVid:(NSString *)vid
                   accessKeyId:(NSString*)accessKeyId
               accessKeySecret:(NSString*)accessKeySecret
                 securityToken:(NSString *)securityToken;

/**
 *功能：使用vid+playauth方式播放。
 *参数：playKey 播放凭证
 vid 视频id
 *备注：本地视频播放，AliyunVodPlayerManagerDelegate在AliyunVodPlayerEventPrepareDone 状态下，某些参数无法获取（如：视频标题、清晰度）
 userPlayKey :1.2.0之前版本参数名称 apikey。
 
 *playauth获取方法：https://help.aliyun.com/document_detail/52881.html?spm=5176.doc52879.6.650.aQZsBR
 
 客户端开发也可以通过python脚本获取播放凭证进行调试，具体流程如下：
 安装python2.7+pip环境（Mac环境下自带，Windows环境自行安装）
 使用终端安装SDK，运行以下命令：
 pip install aliyun-python-sdk-core
 pip install aliyun-python-sdk-vod
 下载Python脚本，从阿里云控制台获取accessKeyId和accessKeySecret并替换脚本里面的字段内容，从点播控制台获取已经上传视频的videoID并替换脚本里面的字段内容。
 在python脚本所在目录下通过终端执行以下命令：
 python playAuth.py
 在终端中查看获取的PlayAuth和VideoId。
 在播放器SDK中使用获取的PlayAuth和VideoId进行播放，注意PlayAuth的时效为100秒，如果过期请重新获取。
 */
- (void)playViewPrepareWithVid:(NSString *)vid
                      playAuth:(NSString *)playAuth;

/**
 *功能：播放器初始化视频，主要目的是分析视频内容，读取视频头信息，解析视频流中的视频和音频信息，并根据视频和音频信息去寻找解码器，创建播放线程等
 *参数：url，输入的url，包括本地地址和网络视频地址
 *备注：调用该函数完成后立即返回，需要等待准备完成通知，收到该通知后代表视频初始化完成，视频准备完成后可以获取到视频的相关信息。
 使用本地地址播放，注意用户需要传 NSURL 类型数据，不是NSSting 类型数据。
 本地视频播放，AliyunVodPlayerManagerDelegate在AliyunVodPlayerEventPrepareDone 状态下，某些参数无法获取（如：视频标题、清晰度）
 */
- (void)playViewPrepareWithURL:(NSURL *)url;

/**
 与playViewPrepareWithURL功能相同，但是不进行网略判断
 
 @param url 本地的url
 */
- (void)playViewPrepareWithLocalURL:(NSURL *)url;

/**
 *功能：视频转码服务用户使用播放方式
 *参数：部分参数参考:https://help.aliyun.com/document_detail/53522.html?spm=5176.doc53534.2.5.mhSfOh
 HLS标准加密:https://help.aliyun.com/document_detail/59885.html?spm=5176.product29194.6.607.2bynDX
 *备注：
 */
- (void)playViewPrepareWithVid:(NSString *)vid
                      accessId:(NSString *)accessId
                  accessSecret:(NSString *)accessSecret
                      stsToken:(NSString *)stsToken
                      autoInfo:(NSString *)autoInfo
                        region:(NSString *)region
                    playDomain:(NSString *)playDomain
                mtsHlsUriToken:(NSString *)mtsHlsUriToken;

/**
 功能：设置是否自动播放
 参数：
 autoPlay：YES为自动播放
 */
- (void)setAutoPlay:(BOOL)autoPlay;

/**
 功能：开始播放视频
 备注：在prepareWithVid之后可以调用start进行播放。
 */
- (void)start;

/**
 功能：停止播放视频
 */
- (void)stop;

/**
 功能：重载播放
 */
- (void)reload;

/**
 功能：暂停播放视频
 */
- (void)pause;

/**
 功能：继续播放视频，此功能应用于pause之后，与pause功能匹配使用
 */
- (void)resume;
/**
 功能：seek到某个时间播放视频
 */
- (void)seekTo:(NSTimeInterval)seekTime;
/**
 功能：重播
 */
- (void)replay;

/**
 功能：停止播放销毁图层
 */
- (void)reset;

/**
功能：重试
*/
- (void)retry;

/**
 功能：释放播放器
 */
- (void)releasePlayer;

- (AVPStatus)playerViewState;

/**
 * 功能：声音调节
 */
- (void)setVolume:(float)volume;

/**
 * 功能：循环播放控制
 */
@property(nonatomic, readwrite)  BOOL circlePlay;

/**
 功能：设置标题
 */
- (void)setTitle:(NSString *)title ;

/**
 * 功能：获取媒体信息, 当PrepareDone时，才能获取到该参数对象
 */
- (AVPMediaInfo *)getAliyunMediaInfo;

/**
 * 功能：播放器播放结束，文字描述；
 * 参数：默认文案：@"再次观看，请点击重新播放";
 */
- (void)setPlayFinishDescribe:(NSString *)des;

/**
 * 功能：播放器网络状态不好，文字描述；
 * 参数：默认文案：@"当前网络不佳，请稍后点击重新播放";
 */
- (void)setNetTimeOutDescribe:(NSString *)des;

/**
 * 功能：播放器无网络，文字描述；
 * 参数：默认文案：@"无网络连接，检查网络后点击重新播放";
 */
- (void)setNoNetDescribe:(NSString *)des;

/**
 * 功能：播放器加载出错，文字描述；
 * 参数：默认文案：@"视频加载出错，请点击重新播放";
 */
- (void)setLoaddataErrorDescribe:(NSString *)des;

/**
 * 功能：播放器4G网络状态，文字描述；
 * 参数：默认文案：@"当前为移动网络，请点击播放";
 */
- (void)setUseWanNetDescribe:(NSString *)des;

/**
 让ui状态进入重播状态
 */
- (void)setUIStatusToReplay;

/**
让ui状态进入重试状态
*/
- (void)setUIStatusToRetryWithMessage:(NSString *)message;

/**
 URLSource播放源
 */
@property (nonatomic,strong)AVPUrlSource *urlSource;

/**
 STSSource播放源
 */
@property (nonatomic,strong)AVPVidStsSource *stsSource;

/**
 STSSource播放源
 */
@property (nonatomic,strong)AVPVidMpsSource *mpsSource;

/**
 STSSource播放源
 */
@property (nonatomic,strong)AVPVidAuthSource *authSource;

/**
 投屏状态判断
 */
@property (nonatomic, assign, readonly) BOOL isAirPlay;

@property (nonatomic, assign, readonly) BOOL isPlayAds;

/**
 是否展示loopView
 */
@property (nonatomic, assign) BOOL isLoopView;

- (void)controlViewEnable:(BOOL)enable;
- (BOOL)isAirPlay;
- (BOOL)isPlayAds;
- (void)pauseAdsImage;
- (BOOL)reviveAdsImage;
- (void)pausePlayAds;
- (void)resumePlayAds;
- (void)loopViewStartAnimation;
- (void)cleanLastFrame:(BOOL)show; // 视频播放结束是否移除最后一桢
- (void)hardwareDecoder:(BOOL)decoder ; // 设置是否支持硬解码
- (UIViewController *)findCurrentViewController;
- (BOOL)isPresent;
- (void)setPlayerAllConfig:(AlivcVideoPlayPlayerConfig *)playerConfig;
- (void)playWithPlayerConfig:(AlivcVideoPlayPlayerConfig *)playerConfig;
- (void)playwithUpdateLiveSts:(AlivcVideoPlayPlayerConfig *)playerConfig;

/// 状态有变化
@property (nonatomic, copy) void(^playerStatusChangeBlock)(AVPStatus status);

/// 是否设置成静音
@property (nonatomic, assign) BOOL muted;

/// 播放速度 0.5-2.0之间，1为正常播放
/// @param rate 0.5-2.0之间，1为正常播放
- (void)setRate:(CGFloat)rate;

@end

NS_ASSUME_NONNULL_END
