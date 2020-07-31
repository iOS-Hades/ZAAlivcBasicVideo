//
//  AVCThrowScreenView.m
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/9.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AVCAirPlayView.h"
#define kTVMPVolumeViewTag  154768

@interface AVCAirPlayView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *airplayDeviceName;
@property (nonatomic, strong) UILabel *closeLabel;


@end

@implementation AVCAirPlayView

- (void)setText:(NSString *)text {
    [self addSubview:self.closeLabel];
    self.imageView.hidden = YES;
    self.closeLabel.text = text;
}

- (UILabel *)closeLabel {
    if (!_closeLabel) {
        _closeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
        _closeLabel.font = [UIFont systemFontOfSize:15];
        _closeLabel.textAlignment = NSTextAlignmentCenter;
        _closeLabel.textColor = [UIColor whiteColor];
        
    }
    
    return _closeLabel;
}

+(instancetype)airPlayViewWithFrame:(CGRect)rect image:(UIImage *)image{
    return [[self alloc] initWithFrame:rect image:image];
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [self initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor blackColor];
        self.imageView.image = image;
      
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _imageView.center = self.center;
    }
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setRouteButtonImage:nil forState:UIControlStateNormal];
        [self setShowsVolumeSlider:NO];
        self.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.imageView];
    
        self.backgroundColor = [UIColor clearColor];
        self.showsVolumeSlider = NO;
        self.tag = kTVMPVolumeViewTag;
       // [self initMPButton];
        
        [self registerNotification];
        
    }
    return self;
}

//这个的目的是在AirPlay没有任何设备时也能呼出Picker使用
- (void)initMPButton{
    
     UIButton *btnSender;
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
             btnSender = button;
            
        }
    }
    
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
 
//    if ([object isKindOfClass:[UIButton class]] ) {
//
//        if([[change valueForKey:NSKeyValueChangeNewKey] intValue] == 1){
//            [(UIButton *)object setBounds:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        }else{
//            self.hidden = NO;
//            [object setAlpha:1];
//        }
//    }
    
}

-(void)registerNotification{
    // routeChange
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteHasChangedNotification:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
   
    //注册中断通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLost:) name:AVAudioSessionMediaServicesWereLostNotification object:[AVAudioSession sharedInstance]];
    
}
- (void)audioRouteHasChangedNotification:(NSNotification *)noti{

    // 可以播放 切换播放器

    if (![self activeAirplayOutputRouteName]) {
         [[NSNotificationCenter defaultCenter]postNotificationName:SwitchPlayer object:@"0"];// 切回到原来的播放器
         NSLog(@"end airplay  结束投屏");
       
    }else {
         [[NSNotificationCenter defaultCenter]postNotificationName:SwitchPlayer object:@"1"];
         NSLog(@"start airplay  开始投屏");
    }
   
    
}

- (void)handleLost:(NSNotification *)notification {
    
    NSLog(@"lost");
    
}

- (void)handleInterruption:(NSNotification *)notification{
    NSDictionary * info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    //中断开始和中断结束
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //当被电话等中断的时候，调用这个方法，停止播放
        if (self.delegate &&[self.delegate respondsToSelector:@selector(airPlayViewPlayPauseWithInterrupt)]) {
            [self.delegate airPlayViewPlayPauseWithInterrupt];
        }
    } else {
        /**
         *  中断结束，userinfo中会有一个InterruptionOption属性，
         *  该属性如果为resume，则可以继续播放功能
         */
        AVAudioSessionInterruptionOptions option = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (option == AVAudioSessionInterruptionOptionShouldResume) {
           
            if (self.delegate &&[self.delegate respondsToSelector:@selector(airPlayViewPlayResume)]) {
                [self.delegate airPlayViewPlayResume];
            }
        }
    }
}


//遍历当前设备所有通道.返回isEqualToString:AVAudioSessionPortAirPlay通道的具体名称,如果名称不为nil则为当前连接到了AirPlay
- (AVAudioSessionPort)activeAirplayOutputRouteName
{
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    
    NSLog(@"airPlay%@",audioSession.currentRoute);
    NSLog(@"category::%@ mode:%@",audioSession.category,audioSession.mode);
    AVAudioSessionRouteDescription* currentRoute = audioSession.currentRoute;
    for (AVAudioSessionPortDescription* outputPort in currentRoute.outputs){
        NSLog(@"通道名称：%@ kk %lu",outputPort,(unsigned long)currentRoute.outputs.count);
        if ([outputPort.portType isEqualToString:AVAudioSessionPortAirPlay])
            return outputPort.portType;
    }
  
    return nil;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, 30, 30);
    self.imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    
    if (_closeLabel) {
        _closeLabel.frame = CGRectMake(0, 0, 100, 50);
        _closeLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
}

- (void)showAirplayView {

    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
     
        }
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
