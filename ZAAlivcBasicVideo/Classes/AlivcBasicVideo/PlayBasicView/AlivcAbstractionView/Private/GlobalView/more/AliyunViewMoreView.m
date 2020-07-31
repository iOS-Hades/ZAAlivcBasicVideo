//
//  AliyunViewMoreView.m
//  AliyunVideoClient_Entrance
//
//  Created by 王凯 on 2018/6/28.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunViewMoreView.h"
#import "AliyunUtil.h"
#import "AlivcUIConfig.h"
#import "AVCAirPlayView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD+AlivcHelper.h"
#import "AVCSlider.h"
#import "NSString+AlivcHelper.h"

@interface AliyunViewMoreView()
@property (nonatomic, strong) UIScrollView *containsView;
@property (nonatomic, strong) UIButton *downLoadBtn;
@property (nonatomic, strong) UIButton *airplayBtn;
@property (nonatomic, strong) UIButton *barrageBtn;

@property (nonatomic, strong) UIView *playLineView;
@property (nonatomic, strong) UILabel *speedLabel;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIImageView *leftVolumeIV;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UIImageView *rightVolumeIV;

@property (nonatomic, strong) UIImageView *leftBrightIV;
@property (nonatomic, strong) UISlider *brightSlider;
@property (nonatomic, strong) UIImageView *rightBrightIV;

@property (nonatomic, strong) AVCAirPlayView *airPlayView;
/*
 * 功能 ： 声音设置
 */
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

@property (nonatomic, strong) UILabel *tipLabel;        //提示信息
//填充模式
@property (nonatomic, strong) UIView *scalingLineView;
@property (nonatomic, strong) UILabel *scalingLabel;
@property (nonatomic, strong) UISegmentedControl *scalingSegmentedControl;
//循环播放
@property (nonatomic, strong) UIView *loopLineView;
@property (nonatomic, strong) UILabel *loopLabel;
@property (nonatomic, strong) UISegmentedControl *loopSegmentedControl;

@end
@implementation AliyunViewMoreView

- (UIScrollView *)containsView{
    if (!_containsView) {
        _containsView = [[UIScrollView alloc] init];
        _containsView.showsVerticalScrollIndicator = NO;
        _containsView.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:0.90];
    }
    return _containsView;
}

- (UIButton *)downLoadBtn{
    if (!_downLoadBtn) {
        _downLoadBtn = [[UIButton alloc]init];
    }
    return _downLoadBtn;
}

- (UIButton *)airplayBtn{
    if (!_airplayBtn) {
        _airplayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _airplayBtn;
}

- (UIButton *)barrageBtn{
    if (!_barrageBtn) {
        _barrageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _barrageBtn;
}

- (UIView *)playLineView{
    if (!_playLineView) {
        _playLineView = [[UIView alloc] init];
        _playLineView.backgroundColor = [UIColor grayColor];
    }
    return _playLineView;
}

- (UILabel *)speedLabel{
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] init];
        _speedLabel.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:0.90];
        _speedLabel.textAlignment = NSTextAlignmentCenter;
        _speedLabel.text = [@"倍速播放" localString];
        _speedLabel.textColor = [UIColor whiteColor];
        _speedLabel.font = [UIFont systemFontOfSize:12.0f];
        
    }
    return _speedLabel;
}


- (UISegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"1.0X",@"0.5X",@"1.5X",@"2.0X"]];
        _segmentedControl.backgroundColor = [UIColor clearColor];
//        [UIColor colorWithRed:28.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:0.90];
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.tintColor = [UIColor clearColor];
        NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],
                                                 
                                                 NSForegroundColorAttributeName: [AlivcUIConfig shared].kAVCThemeColor};
        
        [_segmentedControl setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];//设置文字属性
        
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],
                                                   
                                                   NSForegroundColorAttributeName: [UIColor whiteColor]};
        
        [_segmentedControl setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
        

        
        
    }
    return _segmentedControl;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor grayColor];
    }
    return _lineView;
}

- (UIImageView *)leftVolumeIV{
    if (!_leftVolumeIV) {
        _leftVolumeIV = [[UIImageView alloc] init];
        _leftVolumeIV.image = [AlivcImage imageInBasicVideoNamed:@"avcSmallSound"];
    }
    return _leftVolumeIV;
}

- (UISlider *)volumeSlider{
    if (!_volumeSlider) {
        _volumeSlider = [[AVCSlider alloc] init];
        [_volumeSlider setValue:self.musicPlayer.volume];
        [_volumeSlider setMinimumTrackTintColor:[AlivcUIConfig shared].kAVCThemeColor];
        
    }
    return _volumeSlider;
}

- (UIImageView *)rightVolumeIV{
    if (!_rightVolumeIV) {
        _rightVolumeIV = [[UIImageView alloc] init];
        _rightVolumeIV.image = [AlivcImage imageInBasicVideoNamed:@"avcBigSound"];
    }
    return _rightVolumeIV;
}

- (UIImageView *)leftBrightIV{
    if (!_leftBrightIV) {
        _leftBrightIV = [[UIImageView alloc] init];
        _leftBrightIV.image = [AlivcImage imageInBasicVideoNamed:@"smallBrightness"];
    }
    return _leftBrightIV;
}

- (UISlider *)brightSlider{
    if (!_brightSlider) {
        _brightSlider = [[AVCSlider alloc] init];
        [_brightSlider setValue:[UIScreen mainScreen].brightness];
        [_brightSlider setMinimumTrackTintColor:[AlivcUIConfig shared].kAVCThemeColor];
        
    }
    return _brightSlider;
}

- (UIImageView *)rightBrightIV{
    if (!_rightBrightIV) {
        _rightBrightIV = [[UIImageView alloc] init];
        _rightBrightIV.image = [AlivcImage imageInBasicVideoNamed:@"bigBrightness"];
    }
    return _rightBrightIV;
}


- (MPMusicPlayerController *)musicPlayer{
    if (!_musicPlayer) {
        _musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    return _musicPlayer;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14.0f];
        _tipLabel.backgroundColor = [UIColor blackColor];
        _tipLabel.textColor = [UIColor whiteColor];
    }
    return _tipLabel;
}

- (UIView *)scalingLineView {
    if (!_scalingLineView) {
        _scalingLineView = [[UIView alloc] init];
        _scalingLineView.backgroundColor = [UIColor grayColor];
    }
    return _scalingLineView;
}

- (UILabel *)scalingLabel {
    if (!_scalingLabel) {
        _scalingLabel = [[UILabel alloc] init];
        _scalingLabel.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:0.90];
        _scalingLabel.textAlignment = NSTextAlignmentCenter;
        _scalingLabel.text = [@"画面比例" localString];
        _scalingLabel.textColor = [UIColor whiteColor];
        _scalingLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _scalingLabel;
}

- (UISegmentedControl *)scalingSegmentedControl {
    if (!_scalingSegmentedControl) {
        _scalingSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[@"默认" localString],[@"平铺" localString],[@"拉伸" localString]]];
        _scalingSegmentedControl.backgroundColor = [UIColor clearColor];
        _scalingSegmentedControl.selectedSegmentIndex = 0;
        _scalingSegmentedControl.tintColor = [UIColor clearColor];
        NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName: [AlivcUIConfig shared].kAVCThemeColor};
        [_scalingSegmentedControl setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];//设置文字属性
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName: [UIColor whiteColor]};
        [_scalingSegmentedControl setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
    }
    return _scalingSegmentedControl;
}

- (UIView *)loopLineView {
    if (!_loopLineView) {
        _loopLineView = [[UIView alloc] init];
        _loopLineView.backgroundColor = [UIColor grayColor];
    }
    return _loopLineView;
}

- (UILabel *)loopLabel {
    if (!_loopLabel) {
        _loopLabel = [[UILabel alloc] init];
        _loopLabel.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:0.90];
        _loopLabel.textAlignment = NSTextAlignmentCenter;
        _loopLabel.text = [@"循环播放" localString];
        _loopLabel.textColor = [UIColor whiteColor];
        _loopLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _loopLabel;
}

- (UISegmentedControl *)loopSegmentedControl {
    if (!_loopSegmentedControl) {
        _loopSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[[@"开启" localString],[@"关闭" localString]]];
        _loopSegmentedControl.backgroundColor = [UIColor clearColor];
        _loopSegmentedControl.selectedSegmentIndex = 1;
        _loopSegmentedControl.tintColor = [UIColor clearColor];
        NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName: [AlivcUIConfig shared].kAVCThemeColor};
        [_loopSegmentedControl setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];//设置文字属性
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName: [UIColor whiteColor]};
        [_loopSegmentedControl setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
    }
    return _loopSegmentedControl;
}


- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
       
        self.hidden = YES;
        [self addSubview:self.tipLabel];
        [self addSubview:self.containsView];
//        [self.containsView addSubview:self.downLoadBtn];
//        [self.containsView addSubview:self.airplayBtn];
//        [self.containsView addSubview:self.barrageBtn];
        [self.containsView addSubview:self.playLineView];
        [self.containsView addSubview:self.speedLabel];
        [self.containsView addSubview:self.segmentedControl];
        [self.containsView addSubview:self.lineView];
        [self.containsView addSubview:self.leftVolumeIV];
        [self.containsView addSubview:self.volumeSlider];
        [self.containsView addSubview:self.rightVolumeIV];
        [self.containsView addSubview:self.leftBrightIV];
        [self.containsView addSubview:self.brightSlider];
        [self.containsView addSubview:self.rightBrightIV];
        [self.containsView addSubview:self.scalingLineView];
        [self.containsView addSubview:self.scalingLabel];
        [self.containsView addSubview:self.scalingSegmentedControl];
        [self.containsView addSubview:self.loopLineView];
        [self.containsView addSubview:self.loopLabel];
        [self.containsView addSubview:self.loopSegmentedControl];
    }
    return self;
}

- (void)layoutSubviews{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat containsViewWidth = 300;
    
    if ([AliyunUtil isInterfaceOrientationPortrait]) {
        self.hidden = YES;
    }
    
    if (_containsView.frame.origin.x == width) {
        return;
    }
    
    _containsView.frame = CGRectMake(width-containsViewWidth, 0, containsViewWidth, height);
    _downLoadBtn.frame = CGRectMake(30, 30, 60, 60);
    
    [_downLoadBtn setImage:[AlivcImage imageInBasicVideoNamed:@"avcDownload"] forState:UIControlStateNormal];
    [_downLoadBtn setTitle:[@"下载" localString] forState:UIControlStateNormal];
    _downLoadBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    CGFloat offset = 10.0f;
    _downLoadBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -_downLoadBtn.imageView.frame.size.width, -_downLoadBtn.imageView.frame.size.height-offset/2, 0);
    _downLoadBtn.imageEdgeInsets = UIEdgeInsetsMake(-_downLoadBtn.titleLabel.intrinsicContentSize.height-offset/2, 0, 0, -_downLoadBtn.titleLabel.intrinsicContentSize.width);
    [_downLoadBtn addTarget:self action:@selector(downLoadBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _airplayBtn.frame = CGRectMake(30, 30, 60, 60);// CGRectMake((containsViewWidth-60)/2.0, 30, 60, 60);
    [_airplayBtn setImage:[AlivcImage imageInBasicVideoNamed:@"avcTV"] forState:UIControlStateNormal];
    [_airplayBtn setTitle:[@"投屏" localString] forState:UIControlStateNormal];
    _airplayBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    _airplayBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -_airplayBtn.imageView.frame.size.width, -_airplayBtn.imageView.frame.size.height-offset/2, 0);
    _airplayBtn.imageEdgeInsets = UIEdgeInsetsMake(-_airplayBtn.titleLabel.intrinsicContentSize.height-offset/2, 0, 0, -_airplayBtn.titleLabel.intrinsicContentSize.width);
    [_airplayBtn addTarget:self action:@selector(airPlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
  
//    _barrageBtn.frame = CGRectMake(containsViewWidth - 30 - 60, 30, 60, 60);
//    _barrageBtn.center = CGPointMake(self.containsView.frame.size.width/2, _barrageBtn.center.y);
//    [_barrageBtn setImage:[AlivcImage imageInBasicVideoNamed:@"avcBarrage"] forState:UIControlStateNormal];
//    [_barrageBtn setTitle:[@"弹幕设置" localString]forState:UIControlStateNormal];
//    _barrageBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
//    _barrageBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -_barrageBtn.imageView.frame.size.width, -_barrageBtn.imageView.frame.size.height-offset/2, 0);
//    _barrageBtn.imageEdgeInsets = UIEdgeInsetsMake(-_barrageBtn.titleLabel.intrinsicContentSize.height-offset/2, 0, 0, -_barrageBtn.titleLabel.intrinsicContentSize.width);
//    [_barrageBtn addTarget:self action:@selector(barrageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _playLineView.frame = CGRectMake(0, 30, containsViewWidth, 1);
    _speedLabel.frame = CGRectMake(0, 0, 70, 15);
    _speedLabel.center = _playLineView.center;
    _segmentedControl.frame = CGRectMake(30, CGRectGetMaxY(_speedLabel.frame)+20, containsViewWidth-60, 30);
    [_segmentedControl addTarget:self action:@selector(segmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    _lineView.frame = CGRectMake(0, CGRectGetMaxY(_segmentedControl.frame)+20, containsViewWidth, 1);
    

    _leftVolumeIV.frame = CGRectMake(30, CGRectGetMaxY(_lineView.frame)+20, 30, 30);
    _volumeSlider.frame = CGRectMake(CGRectGetMaxX(_leftVolumeIV.frame)+10, CGRectGetMaxY(_lineView.frame)+20, containsViewWidth-2*30-2*10-2*30, 30);
    
    [_volumeSlider addTarget:self action:@selector(volumeSliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    _rightVolumeIV.frame = CGRectMake(containsViewWidth-30-30,CGRectGetMaxY(_lineView.frame)+20,30,30);
    
    
    _leftBrightIV.frame = CGRectMake(30, CGRectGetMaxY(_rightVolumeIV.frame)+20, 30, 30);
    _brightSlider.frame = CGRectMake(CGRectGetMaxX(_leftBrightIV.frame)+10, CGRectGetMaxY(_rightVolumeIV.frame)+20, containsViewWidth-2*30-2*10-2*30, 30);
    
    [_brightSlider addTarget:self action:@selector(brightSliderChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    _rightBrightIV.frame = CGRectMake(containsViewWidth-30-30,CGRectGetMaxY(_rightVolumeIV.frame)+20,30,30);
    
    //画面比例
    _scalingLineView.frame = CGRectMake(0, CGRectGetMaxY(_rightBrightIV.frame)+20, containsViewWidth, 1);
    _scalingLabel.frame = CGRectMake(0, 0, 70, 15);
    _scalingLabel.center = _scalingLineView.center;
    _scalingSegmentedControl.frame = CGRectMake(30, CGRectGetMaxY(_scalingLabel.frame)+20, containsViewWidth-60, 30);
    [_scalingSegmentedControl addTarget:self action:@selector(scalingSegmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    //循环播放
    _loopLineView.frame = CGRectMake(0, CGRectGetMaxY(_scalingSegmentedControl.frame)+20, containsViewWidth, 1);
    _loopLabel.frame = CGRectMake(0, 0, 70, 15);
    _loopLabel.center = _loopLineView.center;
    _loopSegmentedControl.frame = CGRectMake(30, CGRectGetMaxY(_loopLabel.frame)+20, containsViewWidth-60, 30);
    [_loopSegmentedControl addTarget:self action:@selector(loopSegmentedControlClicked:) forControlEvents:UIControlEventValueChanged];
    
    self.containsView.contentSize = CGSizeMake(self.containsView.frame.size.width, CGRectGetMaxY(_loopSegmentedControl.frame)+20);
}

- (void)downLoadBtnClicked:(UIButton *)sender{
    [self showSpeedViewPushInAnimate];
    if ([self.delegate respondsToSelector:@selector(aliyunViewMoreView:clickedDownloadBtn:)]) {
        [self.delegate aliyunViewMoreView:self clickedDownloadBtn:sender];
    }
}

- (void)airPlayBtnClicked:(UIButton *)sender{
    
//    if (_airPlayView == nil) {
//        UIWindow * window = [UIApplication sharedApplication].keyWindow;
//        [MBProgressHUD showMessage:NSLocalizedString(@"当前视频不支持投屏", nil)  inView:window];
//    }

    [self showSpeedViewPushInAnimate];
    
    if ([self.delegate respondsToSelector:@selector(aliyunViewMoreView:clickedAirPlayBtn:)]) {
        [self.delegate aliyunViewMoreView:self clickedAirPlayBtn:sender];
    }
}

- (void)barrageBtnClicked:(UIButton *)sender{
    
    if (!self.hidden) {
        if (![AliyunUtil isInterfaceOrientationPortrait]) {
            CGRect frame = self.containsView.frame;
            frame.origin.x = SCREEN_WIDTH;
            self.containsView.frame = frame;
        }
        self.hidden = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(aliyunViewMoreView:clickedBarrageBtn:)]) {
        [self.delegate aliyunViewMoreView:self clickedBarrageBtn:sender];
    }
}

- (void)segmentedControlClicked:(UISegmentedControl *)sender{
    CGFloat speed = 1;
    switch (sender.selectedSegmentIndex) {
        case 0:
            speed = 1;
            break;
        case 1:
            speed = 0.5;
            break;
        case 2:
            speed = 1.5;
            break;
        case 3:
           speed = 2;
            break;
        default:
            break;
    }
    [self showSpeedViewSelectedPushInAnimateWithPlaySpeed:speed];
    if ([self.delegate respondsToSelector:@selector(aliyunViewMoreView:speedChanged:)]) {
        [self.delegate aliyunViewMoreView:self speedChanged:speed];
    }
}

- (void)scalingSegmentedControlClicked:(UISegmentedControl *)sender {
    [self showScalingViewSelectedPushInAnimateWithIndex:sender.selectedSegmentIndex];
    if ([self.delegate respondsToSelector:@selector(aliyunViewMoreView:scalingIndexChanged:)]) {
        [self.delegate aliyunViewMoreView:self scalingIndexChanged:sender.selectedSegmentIndex];
    }
}

- (void)loopSegmentedControlClicked:(UISegmentedControl *)sender {
    [self showLoopViewSelectedPushInAnimateWithIndex:sender.selectedSegmentIndex];
    if ([self.delegate respondsToSelector:@selector(aliyunViewMoreView:loopIndexChanged:)]) {
        [self.delegate aliyunViewMoreView:self loopIndexChanged:sender.selectedSegmentIndex];
    }
}

- (void)volumeSliderChangeValue:(UISlider *)sender{
    self.musicPlayer.volume = sender.value;
}

- (void)brightSliderChangeValue:(UISlider *)sender{
    [UIScreen mainScreen].brightness = sender.value;
}


//倍速播放界面入场、退场动画
//倍速播放界面 入场动画
- (void)showSpeedViewMoveInAnimate{
    
    [UIView animateWithDuration:0.3 animations:^{
        if ([AliyunUtil isInterfaceOrientationPortrait]) {//竖屏
            self.hidden = YES;
        }else{//横屏
            self.hidden = NO;
            CGRect frame = self.containsView.frame;
            frame.origin.x = self.frame.size.width-300;
            self.containsView.frame = frame;
        }
    } completion:^(BOOL finished) {
    }];
}

//倍速播放界面  退场动画
- (void)showSpeedViewPushInAnimate{
    if (!self.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            if ([AliyunUtil isInterfaceOrientationPortrait]) {
                
            }else{
                CGRect frame = self.containsView.frame;
                frame.origin.x = SCREEN_WIDTH;
                self.containsView.frame = frame;
            }
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
}

//倍速播放界面  退场动画
- (void)showSpeedViewPushInAnimateWithShowText:(NSString *)text {
    [UIView animateWithDuration:0.3 animations:^{
        if ([AliyunUtil isInterfaceOrientationPortrait]) {
            self.hidden = YES;
        }else{
            self.containsView.alpha = 0;
            CGRect frame = self.containsView.frame;
            frame.origin.x = SCREEN_WIDTH;
            self.containsView.frame = frame;
        }
    } completion:^(BOOL finished) {
        self.tipLabel.hidden = NO;
        NSString *title = text;
        self.tipLabel.text = title;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],};
        CGSize textSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        self.tipLabel.frame = CGRectMake((self.frame.size.width-textSize.width-10)/2, self.frame.size.height-75, textSize.width+10, 40);
        [UIView animateWithDuration:2 animations:^{
            self.tipLabel.alpha = 0;
        } completion:^(BOOL finished) {
            self.tipLabel.hidden = YES;
            self.tipLabel.alpha = 1.0;
            self.hidden = YES;
            self.containsView.alpha = 1;
        }];
    }];
}

//倍速播放界面 选中选择倍速值后退出
- (void)showSpeedViewSelectedPushInAnimateWithPlaySpeed:(float)playSpeed{
    [self showSpeedViewPushInAnimateWithShowText:[self tipMessageWithSpeed:playSpeed]];
}

//画面比例播放界面 选中值后退出
- (void)showScalingViewSelectedPushInAnimateWithIndex:(NSInteger)index {
    [self showSpeedViewPushInAnimateWithShowText:[self tipMessageWithScalingIndex:index]];
}

//循环播放界面 选中值后退出
- (void)showLoopViewSelectedPushInAnimateWithIndex:(NSInteger)index {
    [self showSpeedViewPushInAnimateWithShowText:[self tipMessageWithloopIndex:index]];
}

- (NSString *)tipMessageWithSpeed:(float)speed{
    NSString *speedStr = @"";
    if (speed == 1) {
        speedStr = @"Nomal";
    }else if (speed == 0.5){
        speedStr = @"0.5X";
    }else if (speed == 1.5){
        speedStr = @"1.5X";
    }else if (speed == 2){
        speedStr = @"2X";
    }
    NSString *title = [NSString stringWithFormat:@"%@ %@ %@",
                       [@"the current video has swiched to" localString],
                       [speedStr localString],
                       [@"speed rate" localString]];
    return title;
}

- (NSString *)tipMessageWithScalingIndex:(NSInteger)index {
    NSString *scalingStr = @"";
    switch (index) {
        case 0:
            scalingStr = [@"默认" localString];
            break;
        case 1:
            scalingStr = [@"平铺" localString];
            break;
        case 2:
            scalingStr = [@"拉伸" localString];
            break;
        default:
            break;
    }
    NSString *title = [NSString stringWithFormat:@"%@ %@",
                       [@"画面比例切换至" localString],scalingStr];
    return title;
}

- (NSString *)tipMessageWithloopIndex:(NSInteger)index {
    NSString *scalingStr = @"";
    switch (index) {
        case 0:
            scalingStr = [@"开启" localString];
            break;
        case 1:
            scalingStr = [@"关闭" localString];
            break;
        default:
            break;
    }
    NSString *title = [NSString stringWithFormat:@"%@ %@",[@"循环播放" localString],scalingStr];
    return title;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch  = touches.anyObject;
    if ([touch.view isKindOfClass:[AliyunViewMoreView class]]) {
        self.hidden = YES;
    }
}

@end
