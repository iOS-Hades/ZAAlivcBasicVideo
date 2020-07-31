//
//  AlyunVodProgressView.m
//

#import "AliyunPlayerViewProgressView.h"
#import "AlivcUIConfig.h"
#import "UIImage+AlivcHelper.h"

static const CGFloat AliyunPlayerViewProgressViewLoadtimeViewLeft      = 2 ;  //loadtimeView 左侧距离父视图距离
static const CGFloat AliyunPlayerViewProgressViewLoadtimeViewTop       = 23 ; //loadtimeView 顶部距离父视图距离
static const CGFloat AliyunPlayerViewProgressViewLoadtimeViewHeight    = 2 ;  //loadtimeView 高度
static const CGFloat AliyunPlayerViewProgressViewPlaySliderTop         = 12 ; //playSlider 顶部距离父视图距离
static const CGFloat AliyunPlayerViewProgressViewPlaySliderHeight      = 24 ; //playSlider 高度


@interface AliyunPlayerViewProgressView()<AliyunPlayerViewSliderDelegate>


@property (nonatomic, strong) UIProgressView *loadtimeView; //缓冲条，loadTime
@property (nonatomic, strong) NSMutableArray * adsViewArray;
@property (nonatomic, strong) NSMutableArray * dotsViewArray;
@property (nonatomic, strong) NSArray * dotsTimeArray;

@end

@implementation AliyunPlayerViewProgressView

- (UIProgressView *)loadtimeView{
    if (!_loadtimeView) {
        _loadtimeView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadtimeView.progress = 0.0;
        //设置它的风格，为默认的
        _loadtimeView.trackTintColor= [UIColor clearColor];
        //设置轨道的颜色
        _loadtimeView.progressTintColor= [UIColor whiteColor];
    }
    return _loadtimeView;
}

- (UISlider *)playSlider{
    if (!_playSlider) {
        _playSlider = [[AliyunPlayerViewSlider alloc] init];
        _playSlider.value = 0.0;
        //thumb左侧条的颜色
        _playSlider.minimumTrackTintColor = [AlivcUIConfig shared].kAVCThemeColor;
        _playSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        //thumb图片
        [_playSlider setThumbImage:[AliyunUtil imageWithNameInBundle:@"al_play_settings_radiobtn_normal" skin:AliyunVodPlayerViewSkinBlue] forState:UIControlStateNormal];
        //手指落下
        [_playSlider addTarget:self action:@selector(progressSliderDownAction:) forControlEvents:UIControlEventTouchDown];
        //手指抬起
        [_playSlider addTarget:self action:@selector(progressSliderUpAction:) forControlEvents:UIControlEventTouchUpInside];
        //value发生变化
        [_playSlider addTarget:self action:@selector(updateProgressSliderAction:) forControlEvents:UIControlEventValueChanged];
        
        [_playSlider addTarget:self action:@selector(cancelProgressSliderAction:) forControlEvents:UIControlEventTouchCancel];
         _playSlider.userInteractionEnabled = YES;
        //手指在外面抬起
        [_playSlider addTarget:self action:@selector(updateProgressUpOUtsideSliderAction:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _playSlider;
}

#pragma mark - init
- (instancetype)init{
    return  [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.loadtimeView];
        self.playSlider.sliderDelegate = self;
        [self addSubview:self.playSlider];
        _adsViewArray = [[NSMutableArray alloc]initWithCapacity:3];
        for (int i =0; i<3; ++i) {
            UIView *view = [[UIView alloc]init];
            view.backgroundColor = [UIColor blueColor];
            [_adsViewArray addObject:view];
            [self addSubview:view];
            
        }
     
    }
    return self;
}


- (void)setAdsPart:(NSString *)noti {
    //  广告部分进度条
    if ([noti isEqualToString:@"0"]) {
        self.duration = 0;
        self.insertTimeArray = nil;
        for (UIView *view in _adsViewArray) {
            view.hidden = YES;
        }
        
        return;
    }
    
    NSInteger totaltime = self.milliSeconds *3 + self.duration;
    CGFloat adsWidth = self.bounds.size.width *self.milliSeconds/totaltime;
    
    CGFloat alreadyInsertTime = 0;
    for (int i = 0;i<3 ;++i) {
        
        if (!self.insertTimeArray || self.insertTimeArray.count <3) {
            return;
        }
        
        NSNumber * num  = [self.insertTimeArray objectAtIndex:i];
        NSInteger insetTime = [num integerValue];
        CGFloat x= (insetTime + alreadyInsertTime)/ totaltime * (self.bounds.size.width - 2 *AliyunPlayerViewProgressViewLoadtimeViewLeft);
        x = x+AliyunPlayerViewProgressViewLoadtimeViewLeft;
        alreadyInsertTime = alreadyInsertTime + self.milliSeconds;
        
        UIView *view = [_adsViewArray objectAtIndex:i];
        view.hidden = NO;
        //view.frame = CGRectMake(x, AliyunPlayerViewProgressViewPlaySliderHeight -2, adsWidth, 2);
        view.frame = CGRectMake(x, AliyunPlayerViewProgressViewLoadtimeViewTop, adsWidth, 2);
        
        
    }
    
}

- (void)setDotWithTimeArray:(NSArray *)timeArray {
    self.dotsTimeArray = [[NSArray alloc]init];
    self.dotsTimeArray = timeArray;
    self.dotsViewArray = [[NSMutableArray alloc]init];
    for (int i = 0;i<timeArray.count; ++i) {
        UIView *dotView = [[UIView alloc]init];
        dotView.hidden = YES;
        [self.dotsViewArray addObject:dotView];
        [self addSubview:dotView];
        dotView.backgroundColor = [UIColor redColor];
        
    }
    
    
}

- (void)setDotsHidden:(BOOL)hidden {
    for (UIView *view in self.dotsViewArray) {
        view.hidden = hidden;
    }
    
}

- (void)removeDots {
    
    for (UIView *view in self.dotsViewArray) {
        [view removeFromSuperview];
    }
    self.dotsViewArray = [[NSMutableArray alloc]init];
}

- (void)layoutSubviews{
    self.loadtimeView.frame = CGRectMake(AliyunPlayerViewProgressViewLoadtimeViewLeft,AliyunPlayerViewProgressViewLoadtimeViewTop, self.bounds.size.width-2*AliyunPlayerViewProgressViewLoadtimeViewLeft, AliyunPlayerViewProgressViewLoadtimeViewHeight);
    self.playSlider.frame = CGRectMake(0,AliyunPlayerViewProgressViewPlaySliderTop, self.bounds.size.width, AliyunPlayerViewProgressViewPlaySliderHeight);
    if (self.insertTimeArray.count >0) {
        [self setAdsPart:@"1"];
    }
    
    if (self.dotsViewArray.count >0) {
        
        for (int  i =0; i< self.dotsTimeArray.count; ++i) {
            UIView *dotView = [self.dotsViewArray objectAtIndex:i];
            NSInteger time = [[self.dotsTimeArray objectAtIndex:i]integerValue];
            CGFloat second = self.duration/1000;
            CGFloat x= time/ second * (self.bounds.size.width - 2 *AliyunPlayerViewProgressViewLoadtimeViewLeft);
            x = x+AliyunPlayerViewProgressViewLoadtimeViewLeft;
           // dotView.frame = CGRectMake(x, AliyunPlayerViewProgressViewLoadtimeViewTop, 1, 2);
            dotView.frame = CGRectMake(x, AliyunPlayerViewProgressViewLoadtimeViewTop, 3, 2);
        }
        
    }
    
}



#pragma mark - 重写setter方法
- (void)setSkin:(AliyunVodPlayerViewSkin)skin{
   
    _skin = skin;
//    self.playSlider.minimumTrackTintColor = [AliyunUtil textColor:skin];
//    [self.playSlider setThumbImage:[AliyunUtil imageWithNameInBundle:@"al_play_settings_radiobtn_normal" skin:skin] forState:UIControlStateNormal];
    
    [self.playSlider setThumbImage:[AlivcImage imageInBasicVideoNamed:@"alivcPlayThumb"] forState:UIControlStateNormal];
    
    self.playSlider.minimumTrackTintColor = [AlivcUIConfig shared].kAVCThemeColor;
         

}

- (void)setProgress:(float)progress{
    [self.playSlider setValue:progress animated:YES];
}

- (float)progress {
    return self.playSlider.value;
}

- (float)getSliderValue {
    return _playSlider.beginPressValue;
}

- (void)setLoadTimeProgress:(float)loadTimeProgress{
    _loadTimeProgress = loadTimeProgress;
    [self.loadtimeView setProgress:loadTimeProgress];
}


#pragma mark - public method
/*
 * 功能 ：更新进度条
 * 参数 ：currentTime 当前播放时间
         durationTime 播放总时长
 */
- (void)updateProgressWithCurrentTime:(float)currentTime durationTime:(float)durationTime {
    if (durationTime == 0) {
        [self.playSlider setValue:0 animated:NO];
        self.playSlider.userInteractionEnabled = NO;
    }else {
        [self.playSlider setValue:currentTime/durationTime animated:YES];
        self.playSlider.userInteractionEnabled = YES;
    }
}

#pragma mark - slider action
- (void)progressSliderDownAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunVodProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchDown];
    }
}

- (void)updateProgressSliderAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunVodProgressView:self dragProgressSliderValue:sender.value event:UIControlEventValueChanged];
    }
}

- (void)progressSliderUpAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunVodProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchUpInside];
    }
}

- (void)updateProgressUpOUtsideSliderAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunVodProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchUpOutside];
    }
}

- (void)cancelProgressSliderAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate aliyunVodProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchCancel];
    }
}


- (void)aliyunPlayerViewSlider:(AliyunPlayerViewSlider *)slider event:(UIControlEvents)event clickedSlider:(float)sliderValue {
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:event:)]) {
        if (event ==  UIControlEventValueChanged) {
            [self.playSlider setValue:sliderValue animated:YES];
        }
        
        if (event == UIControlEventTouchDown  && self.playSlider.isSupportDot == NO) {
            [self.playSlider setValue:sliderValue animated:YES];
        }
        
        
        [self.delegate aliyunVodProgressView:self dragProgressSliderValue:sliderValue event:event]; //实际是点击事件
    }
    
}




@end
