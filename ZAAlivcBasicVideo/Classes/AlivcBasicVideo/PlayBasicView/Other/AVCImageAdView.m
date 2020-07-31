//
//  AVCImageAdView.m
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AVCImageAdView.h"
#import "AVC_VP_AdsViewController.h"
#import "AliyunUtil.h"
#import "NSString+AlivcHelper.h"
@interface AVCImageAdView ()

/**
 广告
 */
@property (nonatomic, strong) UIButton * backButton;

/**
 close button
 */
@property (nonatomic, strong) UIButton *adButton;

/**
 计时器
 */
@property (nonatomic, strong) NSTimer * countTimer;
/**
 当前出现状态
 */
@property (nonatomic, assign) AdsStatus status;

@property (nonatomic, strong)UIView *superView;

@end

@implementation AVCImageAdView

- (instancetype)initWithImage:(UIImage *)image status:(AdsStatus) status inView:(UIView *)view{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handleDeviceOrientationDidChange:)
        name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(becomeActive)
        name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(resignActive)
        name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(willResignActive)
        name:UIApplicationWillResignActiveNotification object:nil];
        self.backgroundColor = [UIColor blueColor];
        _superView = view;
        _countNum = 6;
        if (image) {
             self.image = image;
        }else {
            self.image = [AlivcImage imageInBasicVideoNamed:@"adsPhoto"];
        }
       
        self.status = status;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAdsLink)];
        [self addGestureRecognizer:tapGesture];
        [self addSubview:self.backButton];
        [self addSubview:self.adButton];
        if (status == StartStatus) {
            self.adButton.hidden = NO;
            self.backButton.hidden = NO;
            [self.countTimer fire];
        }else if (status == PauseStatus){
            self.adButton.hidden = YES;
            self.backButton.hidden = YES;
            _countNum = 0;
        }
        [self setFrame];
       
        [view addSubview:self];
    }
    return self;
}

- (void)becomeActive {
    
    UIViewController *superVc = [self findSuperViewController:self];
    UIViewController *currentVc = [self findCurrentViewController];
    if ([_countTimer isValid] && superVc == currentVc) {
          [_countTimer setFireDate:[NSDate distantPast]];
    }
}

- (void)resignActive {
    if ([_countTimer isValid]) {
         [_countTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)willResignActive {
    
    if ([_countTimer isValid]) {
        [_countTimer setFireDate:[NSDate distantFuture]];
    }
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[AlivcImage imageInBasicVideoNamed:@"avcBackIcon"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)back {
    if (self.goback) {
        self.goback();
    }
}

- (NSTimer *)countTimer {
    if (!_countTimer) {
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _countTimer;
}

- (UIButton *)adButton{
    if (!_adButton) {
        _adButton = [[UIButton alloc] init];
        _adButton.frame = CGRectMake(ScreenWidth - 85, 5, 80, 30);
        _adButton.layer.masksToBounds = YES;
        _adButton.layer.cornerRadius = 15;
        _adButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _adButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_adButton addTarget:self action:@selector(closeAds) forControlEvents:UIControlEventTouchUpInside];
        _adButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    }
    return _adButton;
}

- (void)setCountNum:(NSInteger)countNum {
    _countNum = countNum;
    NSString * title = [NSString stringWithFormat:@"%ld %@",(long)_countNum,[@"关闭广告" localString]];
    
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:title];
    NSDictionary * firstAttributes = @{ NSFontAttributeName:[UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:0.00f green:0.76f blue:0.87f alpha:1.00f]};
     NSDictionary * secondAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor],};
    if (_countNum >= 10) {
        [text setAttributes:firstAttributes range:NSMakeRange(0,3)];
        [text setAttributes:secondAttributes range:NSMakeRange(3,4)];
    }else {
        [text setAttributes:firstAttributes range:NSMakeRange(0,2)];
        [text setAttributes:secondAttributes range:NSMakeRange(2,4)];
    }
    
    [_adButton setAttributedTitle:text forState:UIControlStateNormal];
}

- (void)closeAds {
    if (self.close) {
        self.close();
    }
    [self.countTimer invalidate];
    _countNum = 0;
    _countTimer = nil;
    [self removeFromSuperview];
}

- (void)countDown {
    self.countNum = self.countNum - 1;
    if (self.countNum < 0) {
        [self.countTimer invalidate];
        _countTimer = nil;
        if (self.close) {
            self.close();
        }
        [self removeFromSuperview];
    }
}

- (void)goAdsLink {
    
    // 跳到广告链接
    UIViewController * currentVC = [self findSuperViewController:self];
    AVC_VP_AdsViewController * adsVC = [[AVC_VP_AdsViewController alloc]init];
    if (!self.adsLink || self.adsLink.length == 0) {
        self.adsLink = @"https://www.aliyun.com/product/vod?spm=5176.10695662.782639.1.4ac218e2p7BEEf";
    }
    if (_countNum >0 || _countNum == 0) {
          [self.countTimer setFireDate:[NSDate distantFuture]];
    }
  
    adsVC.goBackBlock = ^{
        if (_countNum >0) {
            [self.countTimer setFireDate:[NSDate distantPast]];
        }else {
            [self.player start];
            [self removeFromSuperview];
        }
    };
    adsVC.urlLink = self.adsLink;
    [currentVC presentViewController:adsVC animated:YES completion:nil];
}

- (void)pauseAds{
    if (_countNum >0 || _countNum == 0) {
        [self.countTimer setFireDate:[NSDate distantFuture]];
    }
}

- (BOOL)reviveAds {
    if (_countNum >0 || _countNum == 0) {
        [self.countTimer setFireDate:[NSDate distantPast]];
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

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
    [self setFrame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = _superView.bounds.size.width;
    self.adButton.frame = CGRectMake(width - 85, 5, 80, 30);
    self.backButton.frame = CGRectMake(0, 0, 50,45);
    [self setFrame];
}

- (void)setFrame {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait ){
        
        if (self.status == StartStatus) {
            self.frame = _superView.bounds;
        }else if (self.status == PauseStatus){
            self.frame =  CGRectMake(ScreenWidth /4, ScreenWidth * 9 / 16.0/4, ScreenWidth/2, ScreenWidth * 9 / 16.0/2);
        }
    }else {
        if (self.status == StartStatus) {
            self.frame = _superView.bounds;
        }else if (self.status == PauseStatus){
            
            CGFloat adsWidth = _superView.bounds.size.width/2;
            self.frame =  CGRectMake(adsWidth/2, ScreenHeight/4, adsWidth, ScreenHeight/2);
        }
    }
}

- (void)releaseTimer {
    if (_countTimer) {
        [_countTimer invalidate];
        _countTimer = nil;
    }
    _close = ^{};
}

- (void)dealloc {
    [self releaseTimer];
}

@end
