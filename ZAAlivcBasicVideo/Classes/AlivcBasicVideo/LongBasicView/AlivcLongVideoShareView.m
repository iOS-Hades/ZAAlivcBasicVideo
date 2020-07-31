//
//  AlivcLongVideoShareView.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/15.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoShareView.h"
#import "NSString+AlivcHelper.h"

@interface AlivcLongVideoShareView ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UIButton *cancelButton;
@property (nonatomic, strong)UIView *lineView;
@property (nonatomic, strong)UIButton *weiboButton;
@property (nonatomic, strong)UIButton *weixinButton;


@end

@implementation AlivcLongVideoShareView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [self addSubview:self.bgView];
        
    }
    return self;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
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
        _bgView.backgroundColor = color;
        [_bgView addSubview:self.cancelButton];
        [_bgView addSubview:self.lineView];
        [_bgView addSubview:self.titleLabel];
        [_bgView addSubview:self.weiboButton];
        [_bgView addSubview:self.weixinButton];
        [_bgView addSubview:self.lineView];
    }
    
    return _bgView;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        
        _cancelButton = [[UIButton alloc]init];
        [_cancelButton setTitle:[@"取消" localString] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        UIColor *color = [UIColor blackColor];
        if (@available(iOS 13.0, *)) {
            color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return [UIColor whiteColor];
                } else {
                    return color;
                }
            }];
        }
        [_cancelButton setTitleColor:color forState:UIControlStateNormal];
    }
    
    return _cancelButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    }
    
    return _lineView;
}

- (UIButton *)weiboButton {
    if (!_weiboButton) {
        
        _weiboButton = [[UIButton alloc]init];
        [_weiboButton setImage:[AlivcImage imageInBasicVideoNamed:@"weibo"] forState:UIControlStateNormal];
        [_weiboButton addTarget:self action:@selector(weiboShare) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
    return _weiboButton;
}


- (UIButton *)weixinButton {
    if (!_weixinButton) {
        
        _weixinButton = [[UIButton alloc]init];
        [_weixinButton setImage:[AlivcImage imageInBasicVideoNamed:@"weixin"] forState:UIControlStateNormal];
        [_weixinButton addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _weixinButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = [@"分享" localString];
    }
    return _titleLabel;
}


- (void)cancel{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    }];
    
}

- (void)weixinShare {
 
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    }];
}

- (void)weiboShare {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    }];
}

- (void)layoutSubviews {
    [super  layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.bgView.frame = CGRectMake(0, height *0.65, width, height *0.35);
    self.titleLabel.frame = CGRectMake(0, 0, width, 50);
    
    CGFloat space = (width - 120)/3;
    self.weixinButton.frame = CGRectMake(space,50+ (height *0.35 - 180)/2, 60, 60);
   
    self.weiboButton.frame = CGRectMake(space *2 +60,50+ (height *0.35 - 180)/2, 60, 60);
    self.cancelButton.frame = CGRectMake(0,height *0.35 - 60, width, 60);
    self.lineView.frame = CGRectMake(0,height *0.35 - 70, width, 10);
   
    
    
    
}

- (void)showShareView {
   
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }];
}

@end
