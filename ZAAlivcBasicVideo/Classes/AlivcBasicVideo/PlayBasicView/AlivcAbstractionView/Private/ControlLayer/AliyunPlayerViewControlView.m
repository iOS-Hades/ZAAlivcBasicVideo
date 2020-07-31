//
//  AliyunControlView.m
//

#import "AliyunPlayerViewControlView.h"
#import "AVCLoopView.h"
#import "AlivcVideoPlayTrackButtonsView.h"
#import "AlivcUIConfig.h"

static const CGFloat ALYControlViewTopViewHeight    = 48;   //topView 高度
static const CGFloat ALYControlViewBottomViewHeight = 48;   //bottomView 高度
static const CGFloat ALYControlViewLockButtonLeft   = 20;   //lockButton 左侧距离父视图距离
static const CGFloat ALYControlViewLockButtonHeight = 40;   //lockButton 高度

@interface AliyunPlayerViewControlView()<AliyunPVTopViewDelegate,AliyunVodBottomViewDelegate,AliyunPVGestureViewDelegate,AliyunPVQualityListViewDelegate>

@property (nonatomic, strong) AVCLoopView *loopView;
@property (nonatomic, assign) BOOL hiddenLoopView;
@property (nonatomic, assign) BOOL hiddenDanmu;

@property (nonatomic, strong) AliyunPlayerViewGestureView *guestureView;    //手势view

@property (nonatomic, assign) BOOL isHiddenView;                    //是否需要隐藏topView、bottomView
@property (nonatomic, assign) CGRect selfFrame;
@property (nonatomic, assign) CGFloat bottomViewStartProgress; //水平手势记录开始时的progress

@property (nonatomic, assign) BOOL showLoopView;

//清晰度，码率，音轨 三个视图
@property (nonatomic,strong)AlivcVideoPlayTrackButtonsView *videoTrackView;
@property (nonatomic,strong)AlivcVideoPlayTrackButtonsView *audioTrackView;
@property (nonatomic,strong)AlivcVideoPlayTrackButtonsView *subtitleTrackView;

@end
@implementation AliyunPlayerViewControlView

- (AVCLoopView *)loopView {
    if (!_loopView) {
        NSInteger loopWidth = ScreenWidth > ScreenHeight ? ScreenWidth:ScreenHeight;
        _loopView = [[AVCLoopView alloc] initWithFrame:CGRectMake(0, 0,loopWidth, 40)];
        [_loopView setTickerArrs:@[@"跑马灯演示字幕"]];
        [_loopView setCountTime:5];
        [_loopView setBackColor:[UIColor colorWithRed:0.00f green:0.69f blue:0.82f alpha:0.90f]];
    }
    return _loopView;
}

- (QHDanmuManager *)danmuManager {
    if (!_danmuManager) {
        NSArray *infos = @[@{kDanmuContentKey:@"我是弹幕，您也可以点击画笔发布弹幕",kDanmuTimeKey:@"1"},
                  @{kDanmuContentKey:@"这个视频非常好看",kDanmuTimeKey:@"2"},
                  @{kDanmuContentKey:@"哈哈哈",kDanmuTimeKey:@"3"}];
        NSInteger loopWidth = ScreenHeight;
        NSInteger loopHeight = ScreenWidth;
        if (ScreenWidth > ScreenHeight) {
            loopWidth = ScreenWidth;
            loopHeight = ScreenHeight;
        }
        _danmuManager = [[QHDanmuManager alloc] initWithFrame:CGRectMake(0, 40, loopWidth, (loopHeight-40)*0.9) data:infos inView:self durationTime:1];
        _danmuManager.danmuView.userInteractionEnabled = NO;
    }
    return _danmuManager;
}

- (AliyunPlayerViewTopView *)topView{
    if (!_topView) {
        _topView = [[AliyunPlayerViewTopView alloc] init];
    }
    return _topView;
}

- (AliyunPlayerViewBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[AliyunPlayerViewBottomView alloc] init];
    }
    return _bottomView;
}

- (AliyunPlayerViewGestureView *)guestureView{
    if (!_guestureView) {
        _guestureView = [[AliyunPlayerViewGestureView alloc] init];
    }
    return _guestureView;
}

//- (AliyunPlayerViewQualityListView *)listView{
//    if (!_listView) {
//        _listView = [[AliyunPlayerViewQualityListView alloc] init];
//    }
//    return _listView;
//}

- (UIButton *)lockButton{
    if (!_lockButton) {
        _lockButton = [[UIButton alloc] init];
    }
    return _lockButton;
}

- (UIButton *)sendTextButton {
    if (!_sendTextButton) {
        _sendTextButton = [[UIButton alloc] init];
    }
    return _sendTextButton;
}

- (UIButton *)snapshopButton {
    if (!_snapshopButton) {
        _snapshopButton = [[UIButton alloc] init];
    }
    return _snapshopButton;
}

- (AlivcVideoPlayTrackButtonsView *)videoTrackView {
    if (!_videoTrackView) {
        _videoTrackView = [[AlivcVideoPlayTrackButtonsView alloc]initWithFrame:CGRectZero isHorizontal:NO];
        _videoTrackView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        _videoTrackView.hidden = YES;
        __weak typeof(self)weakself = self;
        _videoTrackView.callBack = ^(NSInteger index, NSString *title) {
            [weakself trackButtonsViewSelectDefinition:title];
        };
    }
    return _videoTrackView;
}

- (AlivcVideoPlayTrackButtonsView *)audioTrackView {
    if (!_audioTrackView) {
        _audioTrackView = [[AlivcVideoPlayTrackButtonsView alloc]initWithFrame:CGRectZero isHorizontal:NO];
        _audioTrackView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        _audioTrackView.hidden = YES;
        __weak typeof(self)weakself = self;
        _audioTrackView.callBack = ^(NSInteger index, NSString *title) {
            [weakself trackButtonsViewSelectDefinition:title];
        };
    }
    return _audioTrackView;
}

- (AlivcVideoPlayTrackButtonsView *)subtitleTrackView {
    if (!_subtitleTrackView) {
        _subtitleTrackView = [[AlivcVideoPlayTrackButtonsView alloc]initWithFrame:CGRectZero isHorizontal:NO];
        _subtitleTrackView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        _subtitleTrackView.hidden = YES;
        __weak typeof(self)weakself = self;
        _subtitleTrackView.callBack = ^(NSInteger index, NSString *title) {
            [weakself trackButtonsViewSelectDefinition:title];
        };
    }
    return _subtitleTrackView;
}

- (void)trackButtonsViewSelectDefinition:(NSString *)definition {
    for (AVPTrackInfo* track in self.info) {
        if ([definition isEqualToString:track.trackDefinition]) {
            if ([self.delegate respondsToSelector:@selector(aliyunControlView:selectTrackIndex:)]) {
                [self.delegate aliyunControlView:self selectTrackIndex:track.trackIndex];
            }
            return;
        }
    }
}
    
- (void)setInfo:(NSArray<AVPTrackInfo *> *)info {
    for (AVPTrackInfo *trackInfo in info) {
        if (trackInfo.trackType == AVPTRACK_TYPE_VIDEO) {
            AVPTrackInfo *autoInfo = [[AVPTrackInfo alloc]init];
            autoInfo.trackIndex = -1;
            autoInfo.trackDefinition = @"AUTO";
            autoInfo.trackType = AVPTRACK_TYPE_VIDEO;
            NSMutableArray *tempInfoArray = [NSMutableArray arrayWithArray:info];
            [tempInfoArray insertObject:autoInfo atIndex:0];
            info = [tempInfoArray copy];
            break;
        }
    }
    _info = info;
    
    NSMutableArray * videoTracksArray = [NSMutableArray array];
    NSMutableArray * audioTracksArray = [NSMutableArray array];
    NSMutableArray * subtitleTracksArray = [NSMutableArray array];
    NSMutableArray * vodTracksArray = [NSMutableArray array];
    for (int i=0; i<info.count; i++) {
        AVPTrackInfo* track = [info objectAtIndex:i];
        switch (track.trackType) {
            case AVPTRACK_TYPE_VIDEO: {
                [videoTracksArray addObject:track.trackDefinition];
            }
                break;
            case AVPTRACK_TYPE_AUDIO: {
                [audioTracksArray addObject:track.trackDefinition];
            }
                break;
            case AVPTRACK_TYPE_SUBTITLE: {
                [subtitleTracksArray addObject:track.trackDefinition];
                break;
            }
            case AVPTRACK_TYPE_SAAS_VOD: {
                [vodTracksArray addObject:track.trackDefinition];
            }
                break;
            default:
                break;
        }
    }
    self.audioTrackView.titleArray = audioTracksArray;
    self.subtitleTrackView.titleArray = subtitleTracksArray;
    if (vodTracksArray.count > 0) {
        self.videoTrackView.titleArray = vodTracksArray;
        [self.bottomView.videoButton setTitle:@"清晰度" forState:UIControlStateNormal];
        [self.bottomView.videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.bottomView.videoButton.userInteractionEnabled = YES;
    }else if (videoTracksArray.count > 0) {
        self.videoTrackView.titleArray = videoTracksArray;
        [self.bottomView.videoButton setTitle:@"码率" forState:UIControlStateNormal];
        [self.bottomView.videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.bottomView.videoButton.userInteractionEnabled = YES;
    }else {
        [self.bottomView.videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.bottomView.videoButton.userInteractionEnabled = NO;
    }
    if (audioTracksArray.count > 0) {
        [self.bottomView.audioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.bottomView.audioButton.userInteractionEnabled = YES;
    }else {
        [self.bottomView.audioButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.bottomView.audioButton.userInteractionEnabled = NO;
    }
    if (subtitleTracksArray.count > 0) {
        [self.bottomView.subtitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.bottomView.subtitleButton.userInteractionEnabled = YES;
    }else {
        [self.bottomView.subtitleButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.bottomView.subtitleButton.userInteractionEnabled = NO;
    }
}

#pragma mark - init
- (instancetype)init {
    return  [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
       // [self.danmuManager initStart];
        self.layer.masksToBounds = YES;
        self.isHiddenView = NO;
        self.showLoopView = NO;
        
        [self addSubview:self.loopView];
        
        self.guestureView.delegate = self;
        [self addSubview:self.guestureView];
        
        self.topView.delegate = self;
        [self addSubview:self.topView];
        
        self.bottomView.delegate = self;
        [self addSubview:self.bottomView];
        
        self.listView.delegate = self;
        
        [self.lockButton setImage:[AlivcImage imageInBasicVideoNamed:@"alivc_unlock"] forState:UIControlStateNormal];
        [self.lockButton setImage:[AlivcImage imageInBasicVideoNamed:@"alivc_lock"] forState:UIControlStateSelected];
        self.lockButton.selected = NO;
        [self.lockButton addTarget:self action:@selector(lockButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.lockButton];
        
        UIImage *image =   [AliyunUtil imageWithNameInBundle:@"icon_danmu_edit" skin:AliyunVodPlayerViewSkinBlue];
        [self.sendTextButton setImage:image forState:UIControlStateNormal];
        [self.sendTextButton setImage:image forState:UIControlStateSelected];
        [self.sendTextButton addTarget:self action:@selector(sendTextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendTextButton];
        
        [self.snapshopButton setImage:[AlivcImage imageInBasicVideoNamed:@"icon_snapshop"] forState:UIControlStateNormal];
        [self.snapshopButton addTarget:self action:@selector(snapshopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.snapshopButton];
        
        [self addSubview:self.videoTrackView];
        [self addSubview:self.audioTrackView];
        [self addSubview:self.subtitleTrackView];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;

    float topBarHeight = ALYControlViewTopViewHeight;
    float bottomBarHeight = ALYControlViewBottomViewHeight;
    float bottomBarY = height - bottomBarHeight;
    
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
        bottomBarHeight = 72;
    }
    
    self.bottomView.frame = CGRectMake(0, bottomBarY, width, bottomBarHeight);
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
        bottomBarY = height - bottomBarHeight - 20;
        self.bottomView.frame = CGRectMake(0, bottomBarY, width, bottomBarHeight+20);
    }
    
    self.guestureView.frame = self.bounds;
    self.topView.frame = CGRectMake(0, 0, width, topBarHeight);
   
       
    
    self.lockButton.frame = CGRectMake(ALYControlViewLockButtonLeft, (height-ALYControlViewLockButtonHeight)/2.0, 2*ALYControlViewLockButtonLeft, ALYControlViewLockButtonHeight);
    self.sendTextButton.frame = CGRectMake(width - ALYControlViewLockButtonLeft*3, (height-ALYControlViewLockButtonHeight)/2.0-ALYControlViewLockButtonHeight/2, 2*ALYControlViewLockButtonLeft, ALYControlViewLockButtonHeight);
    self.snapshopButton.frame = CGRectMake(width - ALYControlViewLockButtonLeft*3, (height-ALYControlViewLockButtonHeight)/2.0+ALYControlViewLockButtonHeight/2, 2*ALYControlViewLockButtonLeft, ALYControlViewLockButtonHeight);
    
    float tempX = width - (ALYPVBottomViewFullScreenButtonWidth + ALYPVBottomViewQualityButtonWidth);
    float tempW = ALYPVBottomViewQualityButtonWidth;
    
    if (self.isProtrait) {
        self.lockButton.hidden = NO;
        self.sendTextButton.hidden = NO;
        self.snapshopButton.hidden = NO;
        self.listView.frame = CGRectMake(tempX, height-[self.listView estimatedHeight]-bottomBarHeight, tempW, [self.listView estimatedHeight]);
        return;
    }
    
    if ([AliyunUtil isInterfaceOrientationPortrait]) {
        self.lockButton.hidden = YES;
        self.sendTextButton.hidden = YES;
        self.snapshopButton.hidden = YES;
        self.listView.hidden = YES;
        self.loopView.hidden = YES;
        self.danmuManager.danmuView.hidden = YES;
    }else{
        self.lockButton.hidden = NO;
        self.sendTextButton.hidden = NO;
        self.snapshopButton.hidden = NO;
        self.listView.hidden = !self.bottomView.qualityButton.selected;
        if (self.showLoopView == NO) {
            self.loopView.hidden = YES;
        }else {
        self.loopView.hidden = self.hiddenLoopView;
        }
        self.danmuManager.danmuView.hidden = self.hiddenDanmu;
        
        self.loopView.frame = CGRectMake(0, 0, self.bounds.size.width, 40);
        
        self.videoTrackView.frame = self.audioTrackView.frame = self.subtitleTrackView.frame = CGRectMake(self.frame.size.width-self.frame.size.height*9/16, 0, self.frame.size.height*9/16, self.frame.size.height);
       
    }
    self.listView.frame = CGRectMake(tempX, height-[self.listView estimatedHeight]-self.bottomView.frame.size.height, tempW, [self.listView estimatedHeight]);
    
//    if (self.danmuManager &&  !CGRectEqualToRect(_selfFrame, self.bounds) ) {
//        [_danmuManager stop];
//        [_danmuManager resetDanmuWithFrame:CGRectMake(0, 40, self.bounds.size.width, ScreenHeight/2)];
//    }
     _selfFrame = self.bounds;
}
- (void)setDanmuViewLevel {
    [self bringSubviewToFront:self.guestureView];
    [self bringSubviewToFront:self.topView];
    [self bringSubviewToFront:self.bottomView];
    [self bringSubviewToFront:self.sendTextButton];
    [self bringSubviewToFront:self.snapshopButton];
    [self bringSubviewToFront:self.lockButton];
    
}
#pragma mark - 锁屏按钮 action
- (void)lockButtonClicked:(UIButton *)sender{

    [self.guestureView setIsLock:!_lockButton.selected];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onLockButtonClickedWithAliyunControlView:)]) {
        [self.delegate onLockButtonClickedWithAliyunControlView:self];
    }
}

#pragma mark - 发送弹幕按钮 action
- (void)sendTextButtonClicked:(UIButton *)sender{
    [self hiddenView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSendTextButtonClickedWithAliyunControlView:)]) {
        [self.delegate onSendTextButtonClickedWithAliyunControlView:self];
    }
}

#pragma mark - 截图按钮 action
- (void)snapshopButtonClicked:(UIButton *)sender {
    [self hiddenView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSnapshopButtonClickedWithAliyunControlView:)]) {
        [self.delegate onSnapshopButtonClickedWithAliyunControlView:self];
    }
}

#pragma mark - 重写setter方法
- (void)setIsProtrait:(BOOL)isProtrait{
    _isProtrait = isProtrait;
    self.bottomView.isPortrait = isProtrait;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setSkin:(AliyunVodPlayerViewSkin)skin{
    
    _skin = skin;
    self.topView.skin = skin;
    self.bottomView.skin = skin;
    
}

- (void)setTitle:(NSString *)title{
    _title = title;
    [self.topView setTopTitle:title];
}

- (void)setBottomViewTrackInfo:(AVPTrackInfo *)trackInfo{
    [self.bottomView setCurrentTrackInfo:trackInfo];
}

- (void)setVideoInfo:(AVPMediaInfo *)videoInfo{
    _videoInfo = videoInfo;
     self.bottomView.videoInfo = videoInfo;
    [self.listView removeFromSuperview];
    self.listView = nil;
    self.listView = [[AliyunPlayerViewQualityListView alloc] init];
    NSArray *tracks = videoInfo.tracks;
    
    self.listView.allSupportQualities = tracks;
    self.listView.delegate = self;
    self.bottomView.qualityButton.selected = NO;
    [self setNeedsLayout];
}

- (void)setLoadTimeProgress:(float)loadTimeProgress{
    _loadTimeProgress = loadTimeProgress;
    self.bottomView.loadTimeProgress = loadTimeProgress;
}

- (void)setPlayMethod:(ALYPVPlayMethod)playMethod{
    _playMethod = playMethod;
    _topView.playMethod = playMethod;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - AliyunPVTopViewDelegate
- (void)onBackViewClickWithAliyunPVTopView:(AliyunPlayerViewTopView *)topView{
//    if (![AliyunUtil isInterfaceOrientationPortrait]) {
//        [AliyunUtil setFullOrHalfScreen];
//    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onBackViewClickWithAliyunControlView:)]) {
            [self.delegate onBackViewClickWithAliyunControlView:self];
        }
    
}

- (void)onDownloadButtonClickWithAliyunPVTopView:(AliyunPlayerViewTopView *)topView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDownloadButtonClickWithAliyunControlView:)]) {
        [self.delegate onDownloadButtonClickWithAliyunControlView:self];
    }
}

- (void)onSpeedViewClickedWithAliyunPVTopView:(AliyunPlayerViewTopView *)topView{
    [self checkDelayHideMethod];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSpeedViewClickedWithAliyunControlView:)]) {
        [self.delegate onSpeedViewClickedWithAliyunControlView:self];
    }
}

- (void)danmuViewClickedWithAliyunPVTopView:(AliyunPlayerViewTopView*)topView {
    NSLog(@"弹幕点击");
    self.danmuManager.danmuView.hidden = self.hiddenLoopView = !self.hiddenLoopView;
}

- (void)loopViewClickedWithAliyunPVTopView:(AliyunPlayerViewTopView*)topView {
    NSLog(@"跑马灯点击");
    self.loopView.hidden = self.hiddenLoopView = !self.hiddenLoopView;
}

#pragma mark - AliyunPVBottomViewDelegate
- (void)aliyunVodBottomView:(AliyunPlayerViewBottomView *)bottomView dragProgressSliderValue:(float)progressValue event:(UIControlEvents)event{
    switch (event) {
        case UIControlEventTouchDown:
        {
            //slider 手势按下时，不做隐藏操作
            self.isHiddenView = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideControlLayer) object:nil];
        }
            break;
        case UIControlEventValueChanged:
            {
                
            }
            break;
        case UIControlEventTouchUpInside:
            {
                //slider滑动结束后，
                self.isHiddenView = YES;
                [self performSelector:@selector(delayHideControlLayer) withObject:nil afterDelay:5];
            }
            break;
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunControlView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunControlView:self dragProgressSliderValue:progressValue event:event];
    }
}

- (void)onClickedPlayButtonWithAliyunPVBottomView:(AliyunPlayerViewBottomView *)bottomView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideControlLayer) object:nil];
    [self performSelector:@selector(delayHideControlLayer) withObject:nil afterDelay:5];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedPlayButtonWithAliyunControlView:)]) {
        [self.delegate onClickedPlayButtonWithAliyunControlView:self];
    }
}

- (void)aliyunPVBottomView:(AliyunPlayerViewBottomView *)bottomView qulityButton:(UIButton *)qulityButton{
    if (!qulityButton.selected) {
        self.listView.hidden = NO;
        [self addSubview:self.listView];
    } else {
        [self.listView removeFromSuperview];
    }
}

- (void)onClickedfullScreenButtonWithAliyunPVBottomView:(AliyunPlayerViewBottomView *)bottomView {
    [self.listView removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedfullScreenButtonWithAliyunControlView:)]) {
        [self.delegate onClickedfullScreenButtonWithAliyunControlView:self];
    }
}

- (void)onClickedVideoButtonWithAliyunPVBottomView:(AliyunPlayerViewBottomView *)bottomView {
    self.videoTrackView.hidden = NO;
    [self bringSubviewToFront:self.videoTrackView];
    [self hiddenView];
}

- (void)onClickedAudioButtonWithAliyunPVBottomView:(AliyunPlayerViewBottomView *)bottomView {
    self.audioTrackView.hidden = NO;
    [self bringSubviewToFront:self.audioTrackView];
    [self hiddenView];
}

- (void)onClickedSubtitleButtonWithAliyunPVBottomView:(AliyunPlayerViewBottomView *)bottomView {
    self.subtitleTrackView.hidden = NO;
    [self bringSubviewToFront:self.subtitleTrackView];
    [self hiddenView];
}

#pragma mark - AliyunPVGestureViewDelegate
- (void)onSingleClickedWithAliyunPVGestureView:(AliyunPlayerViewGestureView *)gestureView {
    //单击界面 显示时，快速隐藏；隐藏时，快速展示，并延迟5秒后隐藏
    if (self.self.videoTrackView.hidden == NO) {
        self.self.videoTrackView.hidden = YES;
    }else if (self.self.audioTrackView.hidden == NO) {
        self.self.audioTrackView.hidden = YES;
    }else if (self.self.subtitleTrackView.hidden == NO) {
        self.self.subtitleTrackView.hidden = YES;
    }else {
        [self checkDelayHideMethod];
    }
}

- (void)onDoubleClickedWithAliyunPVGestureView:(AliyunPlayerViewGestureView *)gestureView {
    [self.bottomView playButtonClicked:nil];
}

- (void)horizontalOrientationMoveOffset:(float)moveOffset{
    
//    UISwipeGestureRecognizerDirection direction = UISwipeGestureRecognizerDirectionLeft;
//    if (moveOffset >= 0) {
//        direction = UISwipeGestureRecognizerDirectionRight;
//    }
//    float x =  moveOffset;
//    double duration = self.duration;
//    float width = self.bounds.size.width;
//    double seekTime = self.currentTime;
//
//    if (duration > 3600) {
//        seekTime += x / width * duration * 0.1;
//    } else if (1800 < duration && duration <= 3600) {
//        seekTime += x / width * duration * 0.2;
//    } else if (600 < duration && duration <= 1800) {
//        seekTime += x / width * duration * 0.34;
//    } else if (240 < duration && duration <= 600) {
//        seekTime += x / width * duration * 0.5;
//    } else {
//        seekTime += x / width * duration;
//    }
//    if (seekTime < 0) {
//        seekTime = 0;
//    } else if (seekTime > duration) {
//        seekTime = duration;
//    }

    //    seek逻辑老代码，保存不删
    //    [self.guestureView setSeekTime:seekTime direction:direction];
    //    self.bottomView.progress = seekTime/duration;
    
    if (self.isHiddenView) { [self showView]; }
    
    CGFloat moveValue = self.bottomViewStartProgress + moveOffset/self.frame.size.width;
    if (moveValue > 1) { moveValue = 1; }
    if (moveValue < 0) { moveValue = 0; }
    self.bottomView.progress = moveValue;

    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunControlView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunControlView:self dragProgressSliderValue:self.bottomView.progress event:UIControlEventValueChanged];
    }
}

//手势开始
- (void)UIGestureRecognizerStateBeganWithAliyunPVGestureView:(AliyunPlayerViewGestureView *)gestureView {
    self.bottomViewStartProgress = self.bottomView.progress;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunControlView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunControlView:self dragProgressSliderValue:self.bottomView.progress event:UIControlEventTouchDown];
    }
}

//手势结束
- (void)UIGestureRecognizerStateHorizontalEndedWithAliyunPVGestureView:(AliyunPlayerViewGestureView *)gestureView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunControlView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunControlView:self dragProgressSliderValue:self.bottomView.progress event:UIControlEventTouchUpInside];
    }
}

#pragma mark - AliyunPVQualityListViewDelegate
- (void)qualityListViewOnItemClick:(int)index {
//    self.bottomView.qualityButton.selected = !self.bottomView.qualityButton.isSelected;
//    NSArray *ary = [AliyunUtil allQualities];
//    [self.bottomView.qualityButton setTitle:ary[index] forState:UIControlStateNormal];
//
    self.bottomView.qualityButton.selected = NO;
    if ([self.delegate respondsToSelector:@selector(aliyunControlView:qualityListViewOnItemClick:)]) {
        [self.delegate aliyunControlView:self qualityListViewOnItemClick:index];
    }
}

- (void)setQualityButtonTitle:(NSString *)title{
//    self.bottomView.qualityButton.selected = !self.bottomView.qualityButton.isSelected;
    [self.bottomView.qualityButton setTitle:title forState:UIControlStateNormal];
    self.bottomView.qualityButton.selected = NO;
}


- (void)qualityListViewOnDefinitionClick:(NSString*)videoDefinition {
    self.bottomView.qualityButton.selected = !self.bottomView.qualityButton.isSelected;
    [self.bottomView.qualityButton setTitle:videoDefinition forState:UIControlStateNormal];
}

#pragma mark - public method

- (void)updateViewWithPlayerState:(AVPStatus)state isScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait{
    
    //  || state == AliyunVodPlayerStateLoading
    if (state ==  AVPStatusIdle) {
        [self.guestureView setEnableGesture:NO];
    }else{
        [self.guestureView setEnableGesture:YES];
    }
    
    if (isScreenLocked || fixedPortrait) {
        [self.guestureView setEnableGesture:NO];
    }

    [self.bottomView updateViewWithPlayerState: state];
    
}

/*
 * 功能 ：更新进度条
 */
- (void)updateProgressWithCurrentTime:(NSTimeInterval)currentTime durationTime : (NSTimeInterval)durationTime{
    self.currentTime = currentTime;
    self.duration = durationTime;
    [self.bottomView updateProgressWithCurrentTime:currentTime durationTime:durationTime];
}

- (void)updateCurrentTime:(NSTimeInterval)currentTime durationTime:(NSTimeInterval)durationTime{
    self.currentTime = currentTime;
    self.duration = durationTime;
    [self.bottomView updateCurrentTime:currentTime durationTime:durationTime];
}

/*
 * 功能 ：清晰度按钮颜色改变
 */
- (void)setCurrentQuality:(int)quality{
    [self.listView setCurrentQuality:quality];
}

/*
 * 功能 ：清晰度按钮颜色改变
 */
- (void)setCurrentDefinition:(NSString*)videoDefinition{
    [self.listView setCurrentDefinition:videoDefinition];
}

/*
 * 功能 ：是否禁用手势（双击、滑动)
 */
- (void)setEnableGesture:(BOOL)enableGesture{
   // [self.guestureView setEnableGesture:enableGesture];
}

/*
 * 功能 ：隐藏topView、bottomView
 */
- (void)hiddenView{
    self.isHiddenView = YES;
    self.topView.hidden = YES;
    self.bottomView.hidden = YES;
    self.sendTextButton.hidden = YES;
    self.snapshopButton.hidden = YES;
    self.lockButton.hidden = YES;
    self.listView.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideControlLayer) object:nil];
}

/*
 * 功能 ：展示topView、bottomView
 */
- (void)showView{
    if (self.guestureView.delegate == nil) {
        self.guestureView.delegate = self;
    }
     self.isHiddenView = NO;
     [self performSelector:@selector(delayHideControlLayer) withObject:nil afterDelay:5];
    if (_lockButton.selected == YES) {
        _lockButton.hidden = NO;
        return;
    }
    
   
    self.topView.hidden = NO;
   
    self.bottomView.hidden = NO;
    if (![AliyunUtil isInterfaceOrientationPortrait]) {
        self.sendTextButton.hidden = NO;
        self.snapshopButton.hidden = NO;
        self.lockButton.hidden = NO;
    }
    
    if ([AliyunUtil isInterfaceOrientationPortrait]) {
        self.listView.hidden = YES;
    }else{
        self.listView.hidden = !self.bottomView.qualityButton.selected;
    }
    
   
}
- (void)showViewWithOutDelayHide {
    [self showView];
    self.guestureView.delegate = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideControlLayer) object:nil];
}

- (void)delayHideControlLayer{
    [self hiddenView];
}

- (void)checkDelayHideMethod{
    if (self.isHiddenView) {
        [self showView];
    }else{
        [self hiddenView];
    }
}

/*
 * 功能 ：锁屏
 */
- (void)lockScreenWithIsScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait{
    [self.bottomView lockScreenWithIsScreenLocked:isScreenLocked fixedPortrait:fixedPortrait];
    if (!isScreenLocked) {
//        [self.lockButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"al_left_unlock"] forState:UIControlStateNormal];
       // [self.lockButton setImage:[AlivcImage imageInBasicVideoNamed:@"alivc_unlock"] forState:UIControlStateNormal];
        self.topView.hidden = NO;
        self.bottomView.hidden = NO;
        self.sendTextButton.hidden = NO;
        self.snapshopButton.hidden = NO;
        self.listView.hidden= NO;
       // [self setEnableGesture:YES];
    }else{
//        [self.lockButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"al_left_lock"] forState:UIControlStateNormal];
       // [self.lockButton setImage:[AlivcImage imageInBasicVideoNamed:@"alivc_lock"] forState:UIControlStateNormal];
        self.topView.hidden = YES;
        self.bottomView.hidden = YES;
        self.sendTextButton.hidden = YES;
        self.snapshopButton.hidden = YES;
        self.listView.hidden= YES;
      //  [self setEnableGesture:NO];
    }
}

/*
 * 功能 ：取消锁屏
 */
- (void)cancelLockScreenWithIsScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait {
    if (isScreenLocked||fixedPortrait) {
        [self.bottomView cancelLockScreenWithIsScreenLocked:isScreenLocked fixedPortrait:fixedPortrait];
      //  [self.lockButton setImage:[AlivcImage imageInBasicVideoNamed:@"alivc_unlock"] forState:UIControlStateNormal];
        self.lockButton.selected = NO;
        self.topView.hidden = NO;
        self.sendTextButton.hidden = NO;
        self.snapshopButton.hidden = NO;
        self.listView.hidden= NO;
        [self setEnableGesture:YES];
    }
}


- (void)setButtonEnnable:(BOOL)enable {
    
    self.sendTextButton.enabled = enable;
    self.snapshopButton.enabled = enable;
    self.lockButton.enabled = enable;
    self.topView.speedButton.enabled = enable;
    
}

- (void)loopViewPause {
    _loopView.hidden = YES;
}
- (void)loopViewStart {
    _loopView.hidden =NO;
}

- (void)loopViewStartAnimation {
    [_loopView start];
}

- (void)isShowLoopView:(BOOL)show {
    _showLoopView = show;
}

@end
