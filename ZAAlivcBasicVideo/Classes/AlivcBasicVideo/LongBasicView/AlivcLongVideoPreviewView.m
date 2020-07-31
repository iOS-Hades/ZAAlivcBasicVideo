//
//  AlivcLongVideoPreviewView.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/15.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoPreviewView.h"
#import "NSString+AlivcHelper.h"

@interface AlivcLongVideoPreviewView ()

@property (nonatomic, strong) UIButton * goVipButton;
@property (nonatomic, strong) UIButton * replayButton;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation AlivcLongVideoPreviewView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor =  [UIColor colorWithRed:0.12f green:0.13f blue:0.18f alpha:1.00f];
        [self addSubview:self.titleLabel];
        [self addSubview:self.replayButton];
        [self addSubview:self.goVipButton];
        [self addSubview:self.backButton];
    }
    
    return self;
    
}

- (UIButton *)goVipButton {
    if (!_goVipButton) {
        
        _goVipButton = [[UIButton alloc]init];
        _goVipButton.backgroundColor = [UIColor colorWithRed:0.91f green:0.25f blue:0.07f alpha:1.00f];
        [_goVipButton setTitle:[@"立即开通" localString] forState:UIControlStateNormal];
        _goVipButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_goVipButton addTarget:self action:@selector(goVipController) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _goVipButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        
        _backButton = [[UIButton alloc]init];
        [_backButton setImage:[AlivcImage imageInBasicVideoNamed:@"avcBackIcon"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    }
    
    return _backButton;
}


- (UIButton *)replayButton {
    if (!_replayButton) {
        
        _replayButton = [[UIButton alloc]init];
        [_replayButton setImage:[AlivcImage imageInBasicVideoNamed:@"reload"] forState:UIControlStateNormal];
        _replayButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_replayButton setTitle:[@"重新试看" localString] forState:UIControlStateNormal];
        [_replayButton addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _replayButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = [@"开通VIP会员后观看完整版" localString];
    }
    return _titleLabel;
}

- (void)replay {
    self.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoPreviewViewReplay)]) {
        [self.delegate alivcLongVideoPreviewViewReplay];
    }
    
}

- (void)goVipController {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoPreviewViewGoVipController)]) {
        [self.delegate alivcLongVideoPreviewViewGoVipController];
    }
    
}

- (void)goBack{
    
    if (self.delegate &&  [self.delegate respondsToSelector:@selector(alivcLongVideoPreviewViewGoBack)]) {
        
        [self.delegate alivcLongVideoPreviewViewGoBack];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.backButton.frame = CGRectMake(10,0, 50, 44);
    self.replayButton.frame = CGRectMake(20,height *0.8, 100, 30);
    
    self.titleLabel.frame = CGRectMake(0, height *0.25, width, 25);
    self.goVipButton.frame = CGRectMake((width - 120)/2,height *0.55, 120, 40);
    self.goVipButton.layer.masksToBounds = YES;
    self.goVipButton.layer.cornerRadius = 20;
}

@end
