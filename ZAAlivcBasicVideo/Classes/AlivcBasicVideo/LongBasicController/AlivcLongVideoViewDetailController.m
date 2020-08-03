//
//  AlivcLongVideoViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/25.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoViewDetailController.h"
#import "AlivcLongVideoPlayView.h"
#import "AlivcLongVideoSelectEpisodeView.h"
#import "AlivcLongVideoYourFavoritCell.h"
#import "AlivcLongVideoCommonFunc.h"
#import "AlivcLongVideoSTSConfig.h"
#import "AliyunUtil.h"
#import "NSString+AlivcHelper.h"
#import "AlivcLongVideoShareView.h"
#import "AlivcLongVideoDefinitionSelectView.h"
#import "AliyunReachability.h"
#import "AlivcLongVideoCacheListViewController.h"
#import "AlivcDefine.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "UIScrollView+NetworkLost.h"
#import "AVPTool.h"
#import "AlivcLongVideoDBManager.h"
//#import "AVPDemoServerManager.h"

#import "AlivcPlayVideoRequestManager.h"

#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})

@interface AlivcLongVideoViewDetailController ()<AliyunVodPlayerViewDelegate,AlivcLongVideoSelectEpisodeViewDelegate,UITableViewDelegate,UITableViewDataSource,AlivcLongVideoDefinitionSelectViewDelegate,AlivcLongVideoPreviewViewDelegate,AlivcLongVideoDownLoadProgressManagerDelegate>

@property (nonatomic, strong) AlivcLongVideoPlayView *playerView;// 包含了各种控件的播放页面
@property (nonatomic, strong) UIButton *downloadButton;           //下载按钮
@property (nonatomic, strong) UIButton *shareButton;           //下载按钮
@property (nonatomic, strong) UILabel *videoTitleLabel;               //视频标题
@property (nonatomic, strong) UITableView *bottomTableView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) AlivcLongVideoSelectEpisodeView * selectEpisodeView;
@property (nonatomic, assign) NSInteger playingIndex;
@property (nonatomic, strong) NSArray * favoriteListArray;
@property (nonatomic, strong) AlivcLongVideoTVModel *currentPlayModel;
@property (nonatomic, strong) AlivcLongVideoSTSConfig  *stsConfig;
@property (nonatomic, strong) AlivcLongVideoShareView *shareView;
@property (nonatomic, strong) AlivcLongVideoDefinitionSelectView * definitionSelectView;
@property (nonatomic, strong) AliyunReachability *reachability;
@property (nonatomic, strong) UILabel *vipLabel;
@property (nonatomic, strong) NSArray <AVPTrackInfo*> * trackInfoArray;
@property (nonatomic, strong) AlivcLongVideoDownloadSource *currentSource;//当前下载的单独长视频
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIButton *downloadListButton;

@end

@implementation AlivcLongVideoViewDetailController

#pragma mark 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"进入播放 controller %ld",[[UIApplication sharedApplication] applicationState]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changEpisode:) name:@"ChangePlayingEpisode" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    self.reachability = [AliyunReachability reachabilityForInternetConnection];
    
    self.stsConfig = [AlivcLongVideoSTSConfig sharedInstance];
    self.view.backgroundColor = [UIColor colorWithRed:0.12f green:0.13f blue:0.18f alpha:1.00f];
    [self.view addSubview:self.playerView];
    self.playerView.dotsArray = self.model.dotList;
    self.playerView.previewView.delegate = self;
    [self.view addSubview:self.bottomTableView];
    [self.view addSubview:self.shareView];
    [self.view addSubview:self.definitionSelectView];
    self.isLock = self.playerView.isScreenLocked||self.playerView.fixedPortrait?YES:NO;
    
    [self.view addSubview:self.downloadListButton];
    
    //url播放和mps播放不能下载，隐藏按钮
    if (self.playerConfig.sourceType == SourceTypeUrl || self.playerConfig.sourceType == SourceTypeMps) {
        self.downloadButton.hidden = YES;
    }
    //播放器设置传入的参数
    [self.playerView setPlayerAllConfig:self.playerConfig];
    
    if (self.playerConfig.sourceType == SourceTypeNull){
        //数据请求
        [self getNewPlayerPlayList];
    }else {
        //直接开始播放
        if (self.playerConfig.sourceType == SourceTypeSts) {
            self.currentPlayModel = [[AlivcLongVideoTVModel alloc]init];
            self.currentPlayModel.videoId = self.playerConfig.vidStsSource.vid;
        }else if (self.playerConfig.sourceType == SourceTypeAuth) {
            self.currentPlayModel = [[AlivcLongVideoTVModel alloc]init];
            self.currentPlayModel.videoId = self.playerConfig.vidAuthSource.vid;
        }
        [self.playerView playWithPlayerConfig:self.playerConfig];
    }
}

- (void)changEpisode:(NSNotification *) noti {
    
    NSInteger playingIndex = [noti.object integerValue];
    // 播放 新的视频
    self.selectEpisodeView.playingEpisodeIndex = playingIndex;
    [self.selectEpisodeView scrollToIndex:playingIndex];
    self.currentPlayModel = [self.selectEpisodeView.episodeArray objectAtIndex:playingIndex];
    [self.bottomTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self startPlayVideo];
}

- (void)becomeActive {
    self.isEnterBackground = NO;
}

- (void)resignActive {
    self.isEnterBackground = YES;
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
    [self viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    AlivcLongVideoDownLoadProgressManager * downLoadProgressManager = [AlivcLongVideoDownLoadProgressManager sharedInstance];
    downLoadProgressManager.delegate = self;
    if (self.playerView.playerViewState == AVPStatusPaused  && [self.playerView isPlayAds] == NO) {
        [self.playerView resume];
    }
    [self.playerView reviveAdsImage];
    [self.playerView loopViewStartAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.playerView.playerViewState == AVPStatusStarted ) {
        [self.playerView pause];
    }
    [self.playerView pauseAdsImage];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    BOOL isLiuhai = ScreenWidth >=812 || ScreenHeight >= 812;
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat topHeight = 0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ) {
        width = ScreenWidth;
        height = ScreenWidth * 9 / 16.0;
        topHeight = 20;
        if (isLiuhai) {
            topHeight = 44;
        }
        self.downloadListButton.hidden = NO;
    }else{
        width = ScreenWidth;
        height = ScreenHeight;
        topHeight = 0;
        self.downloadListButton.hidden = YES;
    }
    
    self.playerView.frame = CGRectMake(0, topHeight, width, height);
    self.bottomTableView.frame = CGRectMake(0, CGRectGetMaxY(self.playerView.frame), ScreenWidth, ScreenHeight - CGRectGetMaxY(self.playerView.frame));
    self.videoTitleLabel.frame = CGRectMake(15, 10, width - 50, 30);
    self.downloadButton.frame = CGRectMake(width - 100,  40, 50, 50);
    self.shareButton.frame = CGRectMake(width - 50, 40, 50, 50);
    if (self.model.tvId && self.model.tvId.length >0) {
        self.headView.frame = CGRectMake(0, 0, width, 200);
        self.selectEpisodeView.frame = CGRectMake(0, CGRectGetMaxY(self.shareButton.frame), width, 90);
        self.selectEpisodeView.hidden = NO;
    }else {
        self.selectEpisodeView.frame = CGRectZero;
        self.selectEpisodeView.hidden = YES;
        self.headView.frame = CGRectMake(0, 0, width, 90);
    }
    self.bottomTableView.tableHeaderView = self.headView;
    self.bottomTableView.showsVerticalScrollIndicator = YES;
    self.vipLabel.frame = CGRectMake(15, 55, 40, 20);
    if (_currentPlayModel.isVip && [_currentPlayModel.isVip isEqualToString:@"true"]) {
        
        self.vipLabel.hidden = NO;
        self.vipLabel.layer.masksToBounds = YES;
        self.vipLabel.layer.cornerRadius = 3;
    }else {
        self.vipLabel.hidden = YES;
    }
    
    self.shareView.frame = CGRectMake(0, SCREEN_HEIGHT,  SCREEN_WIDTH, SCREEN_HEIGHT);
    if (self.definitionSelectView.hidden == YES) {
        self.definitionSelectView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    }
    self.downloadListButton.frame = CGRectMake(self.view.frame.size.width-80, self.view.frame.size.height-80, 60, 60);
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.playerView releasePlayer];
    if (_playerView) {
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
    NSLog(@"~~~释放播放器");
}


#pragma mark 新播放器请求和播放

- (void)getNewPlayerPlayList {
    [AVPTool loadingHudToView:self.view];
    [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoList success:^(AVPDemoResponseModel *resultModel) {
        [AVPTool hideLoadingHudForView:self.view];
        NSMutableArray *tempArray = [NSMutableArray array];
        for (AVPDemoResponseVideoListModel *model in resultModel.data.videoList) {
            AlivcLongVideoTVModel *TVmodel = [[AlivcLongVideoTVModel alloc]init];
            TVmodel.videoId = model.videoId;
            TVmodel.coverUrl = model.coverUrl;
            TVmodel.title = model.title;
            TVmodel.descriptionStr = model.descriptionStr;
            [tempArray addObject:TVmodel];
        }
        self.favoriteListArray = tempArray.copy;
        [self.bottomTableView reloadData];
        if (self.playerConfig.sourceType == SourceTypeNull) {
            [self tableView:self.bottomTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        }
        [self.bottomTableView dismissNetworkLostView];;
    } failure:^(NSString *errorMsg) {
        [AVPTool hideLoadingHudForView:self.view];
        if ([errorMsg isEqualToString:[@"网络未连接，请检查网络" localString]]) {
            [self.bottomTableView showNetworkLostView];
            __weak typeof(self)weakSelf = self;
            [self.bottomTableView networkLostRetryCallBack:^{
                [weakSelf getNewPlayerPlayList];
            }];
        }
        [MBProgressHUD showMessage:errorMsg inView:self.view];
    }];
}

- (void)startPlayVideo {
    
    self.playerView.currentLongVideoModel = _currentPlayModel;
    self.playerView.dotsArray = _currentPlayModel.dotList;
    [self.playerView stop];
    if (!_stsConfig.stsAccessSecret) {
        
        [_stsConfig requestStsInfo:^{
            
            [self.playerView playViewPrepareWithVid:self.currentPlayModel.videoId
                                        accessKeyId:self.stsConfig.stsAccessKeyId
                                    accessKeySecret:self.stsConfig.stsAccessSecret
                                      securityToken:self.stsConfig.stsSecurityToken];
        }];
        
    }else{
        
        [self.playerView playViewPrepareWithVid:_currentPlayModel.videoId
                                    accessKeyId:self.stsConfig.stsAccessKeyId
                                accessKeySecret:self.stsConfig.stsAccessSecret
                                  securityToken:self.stsConfig.stsSecurityToken];
        
    }
}

#pragma mark getAndSet

- (AlivcLongVideoShareView *)shareView {
    if (!_shareView) {
        _shareView = [[AlivcLongVideoShareView alloc]init];
    }
    return _shareView;
}

- (UILabel *)vipLabel {
    if (!_vipLabel) {
        _vipLabel = [[UILabel alloc]init];
        _vipLabel.backgroundColor = [UIColor colorWithRed:0.88f green:0.16f blue:0.16f alpha:1.00f];
        _vipLabel.textAlignment = NSTextAlignmentCenter;
        _vipLabel.text = @"VIP";
        _vipLabel.textColor = [UIColor whiteColor];
        _vipLabel.font = [UIFont systemFontOfSize:13];
        _vipLabel.hidden = YES;
    }
    return _vipLabel;
}

- (AlivcLongVideoPlayView *)playerView {
    if (!_playerView) {
        _playerView = [[AlivcLongVideoPlayView alloc]init];
        _playerView.backgroundColor = [UIColor colorWithRed:0.12f green:0.13f blue:0.18f alpha:1.00f];
        _playerView.delegate = self;
    }
    
    return _playerView;
}

- (AlivcLongVideoDefinitionSelectView *)definitionSelectView {
    if (!_definitionSelectView) {
        _definitionSelectView = [[AlivcLongVideoDefinitionSelectView alloc]init];
        _definitionSelectView.delegate = self;
        _definitionSelectView.hidden = YES;
    }
    return _definitionSelectView;
}

- (UITableView *)bottomTableView {
    if (!_bottomTableView) {
        _bottomTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        //_bottomTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
        //_bottomTableView.scrollIndicatorInsets = UIEdgeInsetsMake(-35, 0, 0, 0);
        UIColor *color = [UIColor whiteColor];
        if (@available(iOS 13.0, *)) {
            color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return [UIColor blackColor];
                } else {
                    return color;
                }
            }];
        }
        _bottomTableView.backgroundColor = color;
        _bottomTableView.delegate = self;
        _bottomTableView.dataSource = self;
        _bottomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _bottomTableView.tableFooterView = [[UIView alloc]init];
        _bottomTableView.tableHeaderView = self.headView;
    }
    return _bottomTableView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc]init];
        [_headView addSubview:self.videoTitleLabel];
        [_headView addSubview:self.downloadButton];
        [_headView addSubview:self.shareButton];
        [_headView addSubview:self.vipLabel];
        [_headView addSubview:self.selectEpisodeView];
    }
    return _headView;
}

- (UIButton *)downloadButton {
    if (!_downloadButton) {
        _downloadButton = [[UIButton alloc]init];
        UIImage *downloadImage = [AlivcImage imageInBasicVideoNamed:@"downLoadButton"];
        [_downloadButton setImage:downloadImage forState:UIControlStateNormal];
        [_downloadButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        [_downloadButton addTarget:self action:@selector(tryToCache) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (void)tryToCache {
    switch ([self.reachability currentReachabilityStatus]) {
        case AliyunSVNetworkStatusNotReachable: {
            [MBProgressHUD showMessage:[@"当前无网络,请连网后重试!" localString] inView:self.view];
        }
            break;
        case AliyunSVNetworkStatusReachableViaWiFi: {
            [self goToCacheController];
        }
            break;
        case AliyunSVNetworkStatusReachableViaWWAN: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[@"当前为移动数据网络，是否继续下载？" localString] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[@"取消" localString] style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            __weak typeof(self)weakSelf = self;
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:[@"继续" localString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                [weakSelf goToCacheController];
            }];
            [alert addAction:sureAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}


- (void)goToCacheController {
    
    if ([[AlivcLongVideoCommonFunc getUDSetWithIndex:5]boolValue] == NO  && _currentPlayModel.isVip && [_currentPlayModel.isVip isEqualToString:@"true"]) {
        
        [MBProgressHUD showMessage:[@"非会员无法缓存VIP视频" localString] inView:self.view];
        return;
    }
    
    _currentSource = [[AlivcLongVideoDownloadSource alloc]init];
    _currentSource.longVideoModel = _currentPlayModel;
    _currentSource.trackIndex = -1;
    if (self.playerConfig) {
        if (self.playerConfig.sourceType == SourceTypeSts) {
            self.currentSource.stsSource = self.playerConfig.vidStsSource;
            self.currentSource.downloadSourceType = DownloadSourceTypeSts;
        }else if (self.playerConfig.sourceType == SourceTypeAuth) {
            self.currentSource.authSource = self.playerConfig.vidAuthSource;
            self.currentSource.downloadSourceType = DownloadSourceTypeAuth;
        }
    }
        
    
    // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud = [MBProgressHUD showMessage:[@"请求资源中..." localString] alwaysInView:self.view];
    //15秒超时
    [self.hud hideAnimated:true afterDelay:30];
    
    [self.downLoadManager clearAllPreparedSources];
    
    if (self.playerConfig.sourceType == SourceTypeNull) {
        __weak typeof(self)weakSelf = self;
        if (![AlivcLongVideoSTSConfig sharedInstance].stsSecurityToken) {
            [[AlivcLongVideoSTSConfig sharedInstance] requestStsInfo:^{
                AVPVidStsSource *vidSource = [[AVPVidStsSource alloc]init];
                vidSource.vid = weakSelf.currentSource.longVideoModel.videoId;
                vidSource.securityToken = weakSelf.stsConfig.stsSecurityToken;
                vidSource.accessKeySecret = weakSelf.stsConfig.stsAccessSecret;
                vidSource.accessKeyId = weakSelf.stsConfig.stsAccessKeyId;
                weakSelf.currentSource.stsSource = vidSource;
                [weakSelf.downLoadManager prepareDownloadSource:weakSelf.currentSource];// 提前prepare 获取下载视频的清晰度
            }];
        }else {
            AVPVidStsSource *vidSource = [[AVPVidStsSource alloc]init];
            vidSource.vid = self.currentSource.longVideoModel.videoId;
            vidSource.securityToken = self.stsConfig.stsSecurityToken;
            vidSource.accessKeySecret = self.stsConfig.stsAccessSecret;
            vidSource.accessKeyId = self.stsConfig.stsAccessKeyId;
            self.currentSource.stsSource = vidSource;
            [self.downLoadManager prepareDownloadSource:_currentSource];// 提前prepare 获取下载视频的清晰度
        }
    }else {
        [self.downLoadManager prepareDownloadSource:self.currentSource];
    }
}

- (UIButton *)shareButton {
    
    if (!_shareButton) {
        _shareButton = [[UIButton alloc]init];
        UIImage *downloadImage = [AlivcImage imageInBasicVideoNamed:@"shareButton"];
        [_shareButton setImageEdgeInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        [_shareButton setImage:downloadImage forState:UIControlStateNormal];
        [_shareButton setImage:downloadImage forState:UIControlStateSelected];
        [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

- (void)share{
    [self.shareView showShareView];
}

- (void)setModel:(AlivcLongVideoTVModel *)model {
    _model = model;
    _currentPlayModel = model;
}

- (void)setCurrentPlayModel:(AlivcLongVideoTVModel *)currentPlayModel {
    _currentPlayModel = currentPlayModel;
    if (_currentPlayModel.isVip && [_currentPlayModel.isVip isEqualToString:@"true"]) {
        self.vipLabel.hidden = NO;
    }else {
        self.vipLabel.hidden = YES;
    }
    self.videoTitleLabel.text = _currentPlayModel.title;
}

- (UILabel *)videoTitleLabel {
    if (!_videoTitleLabel) {
        _videoTitleLabel = [[UILabel alloc]init];
        _videoTitleLabel.text = _currentPlayModel.title;
        _videoTitleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _videoTitleLabel;
}

- (AlivcLongVideoSelectEpisodeView *)selectEpisodeView {
    if (!_selectEpisodeView ) {
        _selectEpisodeView = [[AlivcLongVideoSelectEpisodeView alloc]init];
        _selectEpisodeView.delegate = self;
    }
    return _selectEpisodeView;
}

- (UIButton *)downloadListButton {
    if (!_downloadListButton) {
        _downloadListButton = [[UIButton alloc]init];
        _downloadListButton.layer.cornerRadius = 30;
        _downloadListButton.layer.masksToBounds = YES;
        _downloadListButton.backgroundColor = [UIColor colorWithRed:52/255.0 green:55/255.0 blue:65/255.0 alpha:1];
        [_downloadListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _downloadListButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_downloadListButton setTitle:[@"下载列表" localString] forState:UIControlStateNormal];
        [_downloadListButton addTarget:self action:@selector(toDownloadListVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadListButton;
}

- (void)toDownloadListVC {
    NSLog(@"去下载页面");
    
    AlivcLongVideoCacheListViewController *vc = [[AlivcLongVideoCacheListViewController alloc]init];
    vc.videoListType = AllCacheVideoType;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 下载清晰度选择视图代理AlivcLongVideoDefinitionSelectViewDelegate

- (void)alivcLongVideoDefinitionSelectViewSelecTrack:(AVPTrackInfo *)info{
    
    // 开始下载
    if (info == nil) {
        [self.downLoadManager clearAllPreparedSources];
        return;
    }
    
    _currentSource.trackIndex = info.trackIndex;
    
    AlivcLongVideoDownloadSource *hasSource = [self.downLoadManager hasDownloadSource:_currentSource];
    if (hasSource.downloadStatus != LongVideoDownloadTypePrepared) {
        [MBProgressHUD showMessage:[@"已经加入下载列表" localString] inView:self.view];
        return;
    }
    
    CGFloat mSize =  info.vodFileSize /1024.0 /1024.0;
    NSString *mString = [NSString stringWithFormat:@"%.1fM",mSize];
    _currentSource.totalDataString = mString;
    _currentSource.longVideoModel = _currentPlayModel;
     
    [self.downLoadManager addDownloadSource:self.currentSource];
    [self.downLoadManager startDownloadSource:self.currentSource];
    
    [MBProgressHUD showMessage:[@"加入下载列表" localString] inView:self.view];
}

#pragma mark 下载代理 AlivcLongVideoDownLoadProgressManagerDelegate
- (void)alivcLongVideoDownLoadProgressManagerPrepared:(AlivcLongVideoDownloadSource *)source mediaInfo:(AVPMediaInfo *)mediaInfo {
    
    if (![self.hud isHidden]) {
        [self.hud hideAnimated:true];
    }
    
    self.definitionSelectView.trackInfoArray = mediaInfo.tracks;
    [UIView animateWithDuration:0.2 animations:^{
        self.definitionSelectView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.definitionSelectView.hidden = NO;
    }];
}

- (void)alivcLongVideoDownLoadProgressErrorModel:(AVPErrorModel *)errorModel source:(AlivcLongVideoDownloadSource *)source {
    if (![self.hud isHidden]) {
        [self.hud hideAnimated:true];
    }
    
    [MBProgressHUD showMessage:errorModel.message inView:self.view];
     
    if (errorModel.code == DOWNLOADER_ERROR_NOT_SUPPORT_FORMAT) {
        [self.downLoadManager clearMedia:self.currentSource];
    }else if (errorModel.code == ERROR_SERVER_POP_TOKEN_EXPIRED) {
        [AVPTool loadingHudToView:self.view];
        [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":self.playerConfig.vidStsSource.vid} urlType:AVPUrlTypePlayerVideoSts success:^(AVPDemoResponseModel *responseObject) {
            [AVPTool hideLoadingHudForView:self.view];
            AVPVidStsSource *vidStsSource = [[AVPVidStsSource alloc] initWithVid:responseObject.data.videoId accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai"];
            vidStsSource.playConfig = self.playerConfig.vidStsSource.playConfig;
            self.playerConfig.vidStsSource = vidStsSource;
            self.currentSource.stsSource = self.playerConfig.vidStsSource;
            [self.downLoadManager prepareDownloadSource:self.currentSource];
        } failure:^(NSString *errorMsg) {
            [AVPTool hideLoadingHudForView:self.view];
            [AVPTool hudWithText:errorMsg view:self.view];
        }];
    }else if (errorModel.code == ERROR_SERVER_VOD_INVALIDAUTHINFO_EXPIRETIME) {
        [AVPTool loadingHudToView:self.view];
        [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":self.playerConfig.vidAuthSource.vid} urlType:AVPUrlTypePlayerVideoPlayAuth success:^(AVPDemoResponseModel *responseObject) {
            [AVPTool hideLoadingHudForView:self.view];
            AVPVidAuthSource *vidAuthSource = [[AVPVidAuthSource alloc]initWithVid:responseObject.data.videoMeta.videoId playAuth:responseObject.data.playAuth region:@"cn-shanghai"];
            vidAuthSource.playConfig = self.playerConfig.vidAuthSource.playConfig;
            self.playerConfig.vidAuthSource = vidAuthSource;
            self.currentSource.authSource = self.playerConfig.vidAuthSource;
            [self.downLoadManager prepareDownloadSource:self.currentSource];
        } failure:^(NSString *errorMsg) {
            [AVPTool hideLoadingHudForView:self.view];
            [AVPTool hudWithText:errorMsg view:self.view];
        }];
    }
}

#pragma mark 选集代理AlivcLongVideoSelectEpisodeViewDelegate

- (void)alivcLongVideoSelectEpisodeViewClickEpisode:(NSInteger)episode {
    
    self.playingIndex = episode;
    self.currentPlayModel = [self.selectEpisodeView.episodeArray objectAtIndex:episode];
    [self.bottomTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self startPlayVideo];
    // 播放
}

// 剧情详情页
- (void)alivcLongVideoSelectEpisodeViewGetMoreEpisode {
}

#pragma mark 预览视图代理AlivcLongVideoPreviewViewDelegate

- (void)alivcLongVideoPreviewViewReplay {
    [self startPlayVideo];
}

- (void)alivcLongVideoPreviewViewGoVipController {
}

- (void)alivcLongVideoPreviewViewGoBack {
    // 返回
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
        [AliyunUtil setFullOrHalfScreen];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 列表视图代理tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.favoriteListArray.count >0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.playerConfig) {
            return 0;
        }else {
            return 1;
        }
    }
    return self.favoriteListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.playerConfig) {
        return 0;
    }
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor blackColor];
    label.frame = CGRectMake(15, 10, 100, 20);
    if (self.playerConfig) {
        label.frame = CGRectMake(15, 10, 100, 0);
    }
    label.font = [UIFont systemFontOfSize:20];
    if (section == 0) {
        label.text = [@"当前视频" localString];
    }else {
        label.text = [@"猜你喜欢" localString];
    }
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlivcLongVideoYourFavoritCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YourFavorite"];
    if (!cell) {
        cell  = [[AlivcLongVideoYourFavoritCell alloc]init];
    }
    AlivcLongVideoTVModel *model;
    if (indexPath.section == 0) {
        model = _currentPlayModel;
    }else {
        model = [self.favoriteListArray objectAtIndex:indexPath.row];
    }
    [cell configWithTitle:model.title subtitle:model.descriptionStr imageUrl:model.coverUrl];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 点击播放
    if (indexPath.section == 0) {
        //当前playmodel不变化
        [self startPlayVideo];
    }else {
        self.currentPlayModel =   [_favoriteListArray objectAtIndex:indexPath.row];
        if (_currentPlayModel.videoId && _currentPlayModel.videoId.length >0) {
            [self.bottomTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            [self startPlayVideo];
        }else {
        }
        self.downloadButton.hidden = NO;
    }
}

#pragma mark  播放视图代理AliyunVodPlayerViewDelegate

/**
 * 功能：返回按钮事件
 * 参数：playerView ：AliyunVodPlayerView
 */
- (void)onBackViewClickWithAliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView {
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
        [AliyunUtil setFullOrHalfScreen];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 * 功能：下载按钮事件
 * 参数：playerView ：AliyunVodPlayerView
 */
- (void)onDownloadButtonClickWithAliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView {
    
}

/**
 * 功能：所有事件发生的汇总
 * 参数：event ： 发生的事件
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView happen:(AVPEventType )event {
    
    if (event ==  AVPEventPrepareDone) {
        
        _trackInfoArray = playerView.videoTrackInfo;
        if (self.watchProgress >0 && self.watchProgress!= 100) {
            NSTimeInterval seekTime = playerView.longVideoDuration *self.watchProgress/100;
            [self.playerView seekTo: seekTime];
            self.watchProgress = 0;
        }
        
    }else if (event ==  AVPEventFirstRenderedStart){
        
        if (![self.playerView isPresent]) {
            [self.playerView pause];
        }
    }
}

/**
 * 功能：暂停事件
 * 参数：currentPlayTime ： 暂停时播放时间
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView onPause:(NSTimeInterval)currentPlayTime {
    
}

/**
 * 功能：继续事件
 * 参数：currentPlayTime ： 继续播放时播放时间。
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView onResume:(NSTimeInterval)currentPlayTime {
    
}

/**
 * 功能：播放完成事件 ，请区别stop（停止播放）
 * 参数：playerView ： AliyunVodPlayerView
 */
- (void)onFinishWithAliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView {
    
    NSLog(@"播放下一个");
    BOOL changeSource = NO;
    for (int i = 0; i<self.selectEpisodeView.episodeArray.count; ++i) {
        AlivcLongVideoTVModel *model = [self.selectEpisodeView.episodeArray objectAtIndex:i];
        if ([_currentPlayModel.videoId isEqualToString:model.videoId]) {
            
            if (i<self.selectEpisodeView.episodeArray.count -1) {
                self.currentPlayModel = [self.selectEpisodeView.episodeArray objectAtIndex:i+1];
                self.selectEpisodeView.playingEpisodeIndex = i+1;
                self.playingIndex = i;
            }else {
                self.currentPlayModel = [self.selectEpisodeView.episodeArray objectAtIndex:0];
                self.selectEpisodeView.playingEpisodeIndex = 0;
                self.playingIndex  = 0;
            }
            changeSource = YES;
            break;
        }
    }
    
    for (int i = 0; i<self.favoriteListArray.count; ++i) {
        AlivcLongVideoTVModel *model = [self.favoriteListArray objectAtIndex:i];
        if ([_currentPlayModel.videoId isEqualToString:model.videoId]) {
            
            if (i<self.favoriteListArray.count -1) {
                self.currentPlayModel = [self.favoriteListArray objectAtIndex:i+1];
            }else {
                self.currentPlayModel = [self.favoriteListArray objectAtIndex:0];
            }
            changeSource = YES;
            break;
        }
    }
    
    if (changeSource == NO && self.favoriteListArray.count >0) {
        self.currentPlayModel = [self.favoriteListArray objectAtIndex:0];
    }
    
    [self.bottomTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self startPlayVideo];
}

/**
 * 功能：停止播放
 * 参数：currentPlayTime ： 播放停止时播放时间。
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView onStop:(NSTimeInterval)currentPlayTime {
    
}

/**
 * 功能：拖动进度条结束事件
 * 参数：seekDoneTime ： seekDone时播放时间。
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView onSeekDone:(NSTimeInterval)seekDoneTime {
    
}

/**
 * 功能：是否锁屏
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView lockScreen:(BOOL)isLockScreen {
    self.isLock = isLockScreen;
}

/**
 * 功能：返回调用全屏
 * 参数：isFullScreen ： 点击全屏按钮后，返回当前是否全屏状态
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView fullScreen:(BOOL)isFullScreen {
    
}

/**
 * 功能：循环播放开始
 * 参数：playerView ：AliyunVodPlayerView
 */
- (void)onCircleStartWithVodPlayerView:(AlivcLongVideoPlayView *)playerView {
    
}

/**
 sts token过期回调
 
 @param playerView AliyunVodPlayerView
 */
- (void)onSecurityTokenExpiredWithAliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView {
    [self.playerView stop];
    [self.stsConfig requestStsInfo:^{
        [self.playerView playViewPrepareWithVid:self.currentPlayModel.videoId
                                    accessKeyId:self.stsConfig.stsAccessKeyId
                                accessKeySecret:self.stsConfig.stsAccessSecret
                                  securityToken:self.stsConfig.stsSecurityToken];
    }];
}

- (void)onClickedAirPlayButtonWithVodPlayerView:(AlivcLongVideoPlayView *)playerView {
    
}

- (void)onClickedBarrageBtnWithVodPlayerView:(AlivcLongVideoPlayView *)playerView {
    
}

- (void)onCurrentWatchProgressChangedWithVodPlayerView:(AlivcLongVideoPlayView *)playerView progress:(NSInteger)Progress {
    NSString *progressStr = [NSString stringWithFormat:@"%ld",(long)Progress];
    if ( ![progressStr isEqualToString:self.currentPlayModel.watchProgress]) {
        self.currentPlayModel.watchProgress = progressStr;
        [DEFAULT_DB addHistoryTVModel:self.currentPlayModel];
    }else {
        [DEFAULT_DB addHistoryTVModel:self.currentPlayModel];
    }
}

- (void)onUpdateLiveStsWithAliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView{
    [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoLiveSts success:^(AVPDemoResponseModel *responseObject) {
        self.playerConfig.liveStsSource.accessKeyId = responseObject.data.accessKeyId;
        self.playerConfig.liveStsSource.accessKeySecret = responseObject.data.accessKeySecret;
        self.playerConfig.liveStsSource.securityToken = responseObject.data.securityToken;
//        self.playerConfig.liveStsExpireTime = [AVPDemoServerManager getExpirTime:responseObject.data.expiration];
        
        [self.playerView playwithUpdateLiveSts:self.playerConfig];
    } failure:^(NSString *errorMsg) {
        [AVPTool hudWithText:errorMsg view:self.view];
        [self.playerView setUIStatusToRetryWithMessage:errorMsg];
    }];
}

- (void)onRetryButtonClickWithAliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView {
    switch (self.playerConfig.sourceType) {
        case SourceTypeSts: {
            if (self.playerConfig.vidStsSource.vid.length == 0) {
                [self.playerView retry];
            }else {
                [AVPTool loadingHudToView:self.view];
                [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":self.playerConfig.vidStsSource.vid} urlType:AVPUrlTypePlayerVideoSts success:^(AVPDemoResponseModel *responseObject) {
                    [AVPTool hideLoadingHudForView:self.view];
                    AVPVidStsSource *vidStsSource = [[AVPVidStsSource alloc] initWithVid:responseObject.data.videoId accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai"];
                    vidStsSource.playConfig = self.playerConfig.vidStsSource.playConfig;
                    self.playerConfig.vidStsSource = vidStsSource;
                    [AVPTool hudWithText:[@"刷新成功" localString] view:self.view];
                    [self.playerView playWithPlayerConfig:self.playerConfig];
                } failure:^(NSString *errorMsg) {
                    [AVPTool hideLoadingHudForView:self.view];
                    [AVPTool hudWithText:errorMsg view:self.view];
                    [self.playerView setUIStatusToRetryWithMessage:errorMsg];
                }];
            }
        }
            break;
        case SourceTypeLiveSts: {
               if (self.playerConfig.liveStsSource.url.length == 0) {
                   [self.playerView retry];
               }else {
                   [AVPTool loadingHudToView:self.view];
                   [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoLiveSts success:^(AVPDemoResponseModel *responseObject) {
                       [AVPTool hideLoadingHudForView:self.view];
                       self.playerConfig.liveStsSource.accessKeyId = responseObject.data.accessKeyId;
                       self.playerConfig.liveStsSource.accessKeySecret = responseObject.data.accessKeySecret;
                       self.playerConfig.liveStsSource.securityToken = responseObject.data.securityToken;
//                       self.playerConfig.liveStsExpireTime = [AVPDemoServerManager getExpirTime:responseObject.data.expiration];
                       
                       [self.playerView playWithPlayerConfig:self.playerConfig];
                   } failure:^(NSString *errorMsg) {
                       [AVPTool hideLoadingHudForView:self.view];
                       [AVPTool hudWithText:errorMsg view:self.view];
                       [self.playerView setUIStatusToRetryWithMessage:errorMsg];
                   }];
               }
           }
               break;
        case SourceTypeMps: {
            if (self.playerConfig.vidMpsSource.vid.length == 0) {
                [self.playerView retry];
            }else {
                [AVPTool loadingHudToView:self.view];
                [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":self.playerConfig.vidMpsSource.vid} urlType:AVPUrlTypePlayerVideoMps success:^(AVPDemoResponseModel *responseObject) {
                    [AVPTool hideLoadingHudForView:self.view];
                    self.playerConfig.vidMpsSource = [[AVPVidMpsSource alloc]initWithVid:responseObject.data.MediaId accId:responseObject.data.AkInfo.AccessKeyId accSecret:responseObject.data.AkInfo.AccessKeySecret stsToken:responseObject.data.AkInfo.SecurityToken authInfo:responseObject.data.authInfo region:responseObject.data.RegionId playDomain:@"" mtsHlsUriToken:responseObject.data.HlsUriToken];
                    [AVPTool hudWithText:[@"刷新成功" localString] view:self.view];
                    [self.playerView playWithPlayerConfig:self.playerConfig];
                } failure:^(NSString *errorMsg) {
                    [AVPTool hideLoadingHudForView:self.view];
                    [AVPTool hudWithText:errorMsg view:self.view];
                    [self.playerView setUIStatusToRetryWithMessage:errorMsg];
                }];
            }
        }
            break;
        case SourceTypeAuth: {
            if (self.playerConfig.vidAuthSource.vid.length == 0) {
                [self.playerView retry];
            }else {
                [AVPTool loadingHudToView:self.view];
                [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":self.playerConfig.vidAuthSource.vid} urlType:AVPUrlTypePlayerVideoPlayAuth success:^(AVPDemoResponseModel *responseObject) {
                    [AVPTool hideLoadingHudForView:self.view];
                    AVPVidAuthSource *vidAuthSource = [[AVPVidAuthSource alloc]initWithVid:responseObject.data.videoMeta.videoId playAuth:responseObject.data.playAuth region:@"cn-shanghai"];
                    vidAuthSource.playConfig = self.playerConfig.vidAuthSource.playConfig;
                    self.playerConfig.vidAuthSource = vidAuthSource;
                    [AVPTool hudWithText:[@"刷新成功" localString] view:self.view];
                    [self.playerView playWithPlayerConfig:self.playerConfig];
                } failure:^(NSString *errorMsg) {
                    [AVPTool hideLoadingHudForView:self.view];
                    [AVPTool hudWithText:errorMsg view:self.view];
                    [self.playerView setUIStatusToRetryWithMessage:errorMsg];
                }];
            }
        }
            break;
        default:
            [self.playerView retry];
            break;
    }
}

#pragma mark 旋转屏幕相关

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (self.isLock) {
        return toInterfaceOrientation = UIInterfaceOrientationPortrait;
        
    }else{
        return YES;
    }
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate{
    return !self.isLock;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (self.isLock || self.isEnterBackground) {
        
        return UIInterfaceOrientationMaskLandscapeRight;
    }else{
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }
}

@end
