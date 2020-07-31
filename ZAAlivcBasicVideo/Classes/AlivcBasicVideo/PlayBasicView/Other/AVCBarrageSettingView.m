//
//  AVCBarrageSettingView.m
//  AliyunVideoClient_Entrance
//
//  Created by Aliyun on 2019/3/18.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AVCBarrageSettingView.h"
#import "AliyunUtil.h"
#import "AlivcUIConfig.h"
#import "NSString+AlivcHelper.h"
#import "AVCSlider.h"
@interface AVCBarrageSettingView()

@property (nonatomic, strong) UIView *containsView;
@property (nonatomic, strong) UIView *titleLineView;
@property (nonatomic, strong) UIView *titleLineViewRight;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,strong)UILabel *alphaVauleLabel;
@property (nonatomic,strong)UILabel *spaceVauleLabel;
@property (nonatomic,strong)UILabel *speedVauleLabel;

@end

@implementation AVCBarrageSettingView

- (UIView *)containsView{
    if (!_containsView) {
        _containsView = [[UIView alloc] init];
        _containsView.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:0.9];
    }
    return _containsView;
}

- (UIView *)titleLineView {
    if (!_titleLineView) {
        _titleLineView = [[UIView alloc] init];
        _titleLineView.backgroundColor = [UIColor grayColor];
    }
    return _titleLineView;
}

- (UIView *)titleLineViewRight {
    if (!_titleLineViewRight) {
        _titleLineViewRight = [[UIView alloc] init];
        _titleLineViewRight.backgroundColor = [UIColor grayColor];
    }
    return _titleLineViewRight;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [self commonLabel];
        _titleLabel.text = [@"弹幕设置" localString];
    }
    return _titleLabel;
}

- (UILabel *)alphaVauleLabel {
    if (!_alphaVauleLabel) {
        _alphaVauleLabel = [self commonLabel];
    }
    return _alphaVauleLabel;
}

- (UILabel *)spaceVauleLabel {
    if (!_spaceVauleLabel) {
        _spaceVauleLabel = [self commonLabel];
    }
    return _spaceVauleLabel;
}

- (UILabel *)speedVauleLabel {
    if (!_speedVauleLabel) {
        _speedVauleLabel = [self commonLabel];
    }
    return _speedVauleLabel;
}

- (UILabel *)commonLabel {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.text = @"0%";
    return label;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        CGFloat containsViewWidth = 300;
        
        [self addSubview:self.containsView];
        [self.containsView addSubview:self.titleLineView];
        [self.containsView addSubview:self.titleLineViewRight];
        [self.containsView addSubview:self.titleLabel];
        _containsView.frame = CGRectMake(width-containsViewWidth, 0, containsViewWidth, height);
        _titleLineView.frame = CGRectMake(0, 28, 115, 1);
        _titleLineViewRight.frame = CGRectMake(185, 28, 115, 1);
        _titleLabel.frame = CGRectMake(0, 0, 70, 15);
        _titleLabel.center = CGPointMake(150, 28.5);
        
        NSArray *titleLeaderArray = @[[@"透明度" localString],[@"显示区域" localString],[@"同屏速度" localString]];
        for (int i = 0; i<titleLeaderArray.count; i++) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 54+i*60, 100, 16)];
            label.text = titleLeaderArray[i];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:12.0f];
            [self.containsView addSubview:label];
            
            AVCSlider *slider = [[AVCSlider alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label.frame)+8, containsViewWidth-75, 30)];
            slider.tag = i;
            slider.value = 1;
            [slider setMinimumTrackTintColor:[AlivcUIConfig shared].kAVCThemeColor];
            [slider addTarget:self action:@selector(sliderVauleChanging:) forControlEvents:UIControlEventValueChanged];
            [slider addTarget:self action:@selector(sliderVauleChanged:) forControlEvents:UIControlEventTouchUpInside];
            [slider addTarget:self action:@selector(sliderVauleChanged:) forControlEvents:UIControlEventTouchUpOutside];
            [self.containsView addSubview:slider];
            
            CGRect valueLabelFrame = CGRectMake(CGRectGetMaxX(slider.frame), CGRectGetMinY(slider.frame), 36, 30);
            if (i == 0) {
                slider.value = 0;
                self.alphaSlider = slider;
                self.alphaVauleLabel.frame = valueLabelFrame;
                [self.containsView addSubview:self.alphaVauleLabel];
            }else if (i == 1) {
                self.spaceSlider = slider;
                self.spaceVauleLabel.frame = valueLabelFrame;
                [self.containsView addSubview:self.spaceVauleLabel];
            }else {
                self.speedSlider = slider;
                self.speedVauleLabel.frame = valueLabelFrame;
                [self.containsView addSubview:self.speedVauleLabel];
            }
        }
        
        [self setSliderVaule:0 index:0];
        [self setSliderVaule:1 index:1];
        [self setSliderVaule:1 index:2];
        
        UIButton *resetButton = [[UIButton alloc]initWithFrame:CGRectMake(12, 250, 75, 30)];
        resetButton.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:0.90];
        [resetButton setTitle:[@"恢复默认" localString] forState:UIControlStateNormal];
        [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        resetButton.titleLabel.font = [UIFont systemFontOfSize:12];
        resetButton.layer.cornerRadius = 2;
        resetButton.layer.masksToBounds = YES;
        [resetButton addTarget:self action:@selector(resetButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.containsView addSubview:resetButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ([AliyunUtil isInterfaceOrientationPortrait]) {
        self.hidden = YES;
        return;
    }
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat containsViewWidth = 300;
    _containsView.frame = CGRectMake(width-containsViewWidth, 0, containsViewWidth, height);
}

- (void)sliderVauleChanging:(UISlider *)slider {
    NSLog(@"%ld",(long)slider.tag);
    [self setSliderVaule:slider.value index:slider.tag];
}

- (void)sliderVauleChanged:(UISlider *)slider {
    NSLog(@"%ld",(long)slider.tag);
    [self setSliderVaule:slider.value index:slider.tag];
    if ([self.delegate respondsToSelector:@selector(aliyunBarrageSettingView:sliderVauleChanged:sliderIndex:)]) {
        [self.delegate aliyunBarrageSettingView:self sliderVauleChanged:slider.value sliderIndex:slider.tag];
    }
}

- (void)resetButtonClick {
    self.alphaSlider.value = 0;
    self.spaceSlider.value = 1;
    self.speedSlider.value = 1;
    [self setSliderVaule:0 index:0];
    [self setSliderVaule:1 index:1];
    [self setSliderVaule:1 index:2];
    if ([self.delegate respondsToSelector:@selector(aliyunBarrageSettingViewClickedResetBtn:)]) {
        [self.delegate aliyunBarrageSettingViewClickedResetBtn:self];
    }
}

- (void)setSliderVaule:(float)vaule index:(NSInteger)index {
    int valueInt = vaule * 100;
    NSString *vauleTitle = [[NSString stringWithFormat:@"%d",valueInt] stringByAppendingString:@"%"];
    if (index == 0) {
        self.alphaVauleLabel.text = vauleTitle;
    }else if (index == 1) {
        self.spaceVauleLabel.text = vauleTitle;
    }else {
        self.speedVauleLabel.text = vauleTitle;
    }
}

- (void)showBarrageSettingViewInAnimate {
    
    if ([AliyunUtil isInterfaceOrientationPortrait]) {//竖屏
        self.hidden = YES;
    }else{//横屏
        self.hidden = NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch  = touches.anyObject;
    if ([touch.view isKindOfClass:[self class]]) {
        self.hidden = YES;
    }
}
         
@end






