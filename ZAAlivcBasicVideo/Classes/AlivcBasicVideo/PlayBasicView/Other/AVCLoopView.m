//
//  AVCLoopView
//  AVCLoopView
//
//  Created by Aliyun on 2019/3/9.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import "AVCLoopView.h"

static CGSize appScreenSize;
static UIInterfaceOrientation lastOrientation;

@implementation AVCLoopView{
    int currentIndex; //记录
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        self.layer.masksToBounds = YES;
    }
    return self;
}

/*  返回当前屏幕的size*/
-(CGSize)screenSize {
    UIInterfaceOrientation orientation =[UIApplication sharedApplication].statusBarOrientation;
    if(appScreenSize.width==0 || lastOrientation != orientation){
        appScreenSize = CGSizeMake(0, 0);
        CGSize screenSize = [[UIScreen mainScreen] bounds].size; // 这里如果去掉状态栏，只要用applicationFrame即可。
        if(orientation == UIDeviceOrientationLandscapeLeft ||orientation == UIDeviceOrientationLandscapeRight){
            // 横屏，那么，返回的宽度就应该是系统给的高度。注意这里，全屏应用和非全屏应用，应该注意自己增减状态栏的高度。
            appScreenSize.width = screenSize.height;
            appScreenSize.height = self.frame.size.width;
        }else{
            appScreenSize.width = screenSize.width;
            appScreenSize.height = screenSize.height;
        }
        lastOrientation = orientation;
    }
    return appScreenSize;
}

- (void)setupView {
    self.tickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.tickerLabel setBackgroundColor:[UIColor clearColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self.tickerLabel setNumberOfLines:1];
    self.tickerLabel.font=[UIFont boldSystemFontOfSize:15.f];
    self.tickerLabel.textColor=[UIColor whiteColor];
    [self addSubview:self.tickerLabel];
}

- (void)setBackColor:(UIColor *)color {
    [self setBackgroundColor:color];
}

- (void)setCountTime:(NSInteger)countTime {
    _countTime = countTime;
}

- (void)animateCurrentTickerString {
    NSString *currentString = [_tickerArrs objectAtIndex:currentIndex];
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15.f]};
    CGSize textSize=[currentString sizeWithAttributes:attrs];
    float startingX = self.frame.size.width;
    _Speed = (self.frame.size.width+textSize.width)/5;
    float endX = -textSize.width-_Speed*2;
    [self.tickerLabel setFrame:CGRectMake(startingX, self.tickerLabel.frame.origin.y, textSize.width, self.tickerLabel.frame.size.height)];
    [self.tickerLabel setText:currentString];
    float duration = (textSize.width + self.frame.size.width) / _Speed + 2;
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationRepeatCount:MAXFLOAT];
    CGRect tickerFrame = self.tickerLabel.frame;
    tickerFrame.origin.x = endX;
    [self.tickerLabel setFrame:tickerFrame];
    [UIView commitAnimations];
}

#pragma mark - Ticker Animation Handling
- (void)start {
    currentIndex = 0;
    [self animateCurrentTickerString];
}

#pragma mark - 通知屏幕状态返回View大小
- (void)statusBarOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation ==UIInterfaceOrientationLandscapeLeft) {
        //横屏
        self.frame = CGRectMake(0, self.frame.origin.y, [self screenSize].height, self.frame.size.height);
    }else if (orientation == UIInterfaceOrientationPortrait ||
              orientation == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
        self.frame = CGRectMake(0, self.frame.origin.y, [self screenSize].width, self.frame.size.height);
    }
}

@end







