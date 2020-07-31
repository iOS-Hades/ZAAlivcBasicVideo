//
//  AVCBarrageSettingView.h
//  AliyunVideoClient_Entrance
//
//  Created by Aliyun on 2019/3/18.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCBarrageSettingView;
@protocol AVCBarrageSettingViewDelegate <NSObject>

- (void)aliyunBarrageSettingViewClickedResetBtn:(AVCBarrageSettingView *)view;

- (void)aliyunBarrageSettingView:(AVCBarrageSettingView *)moreView sliderVauleChanged:(float)vaule sliderIndex:(NSInteger)index;

@end

@interface AVCBarrageSettingView : UIView

@property (nonatomic, weak) id<AVCBarrageSettingViewDelegate>delegate;
@property (nonatomic,strong)UISlider *alphaSlider;
@property (nonatomic,strong)UISlider *spaceSlider;
@property (nonatomic,strong)UISlider *speedSlider;

- (void)setSliderVaule:(float)vaule index:(NSInteger)index;

- (void)showBarrageSettingViewInAnimate;

@end






