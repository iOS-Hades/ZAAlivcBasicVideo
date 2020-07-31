//
//  QHDanmuOperateView.m
//  QHDanumuDemo
//
//  Created by chen on 15/7/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHDanmuOperateView.h"
#import "NSString+AlivcHelper.h"

@interface QHDanmuOperateView () {
    CGFloat _spaceY;
    CGFloat _spaceX;
}

@property (nonatomic, strong, readwrite) UITextField *editContentTF;

@property (nonatomic, strong, readwrite) UIButton *sendBtn;

@property (nonatomic, assign) NSInteger subLen;

@end

@implementation QHDanmuOperateView

- (void)dealloc {
   
    self.editContentTF = nil;
    self.sendBtn = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    
        [self setup];
    }
    return self;
}

#pragma mark - Private

- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:99/255.f green:99/255.f blue:99/255.f alpha:0.7];
    self.userInteractionEnabled = YES;
    [self p_setupData];
    [self p_addView];
}



- (void)p_setupData {
     CGFloat x = 0;
    if (@available(iOS 11.0, *)) {
       x = self.safeAreaInsets.left;
    }
    _spaceX = 15 + x;
    _spaceY = 5;
}

- (void)p_addView {
    CGFloat btnH = self.frame.size.height - 2*_spaceY;
    CGFloat btnW = 75;
    UIFont *font = [UIFont systemFontOfSize:15];
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBtn.frame = CGRectMake(self.frame.size.width - btnW - _spaceX, _spaceY, btnW, btnH);
    self.sendBtn.layer.cornerRadius = 3;
    self.sendBtn.backgroundColor = [UIColor colorWithRed:32/255.f green:193/255.f blue:220/255.f alpha:1];
    [self.sendBtn.titleLabel setFont:font];
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendBtn setTitle:[@"发送" localString] forState:UIControlStateNormal];
    [self addSubview:self.sendBtn];
    [self.sendBtn addTarget:self action:@selector(closeDanmuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.editContentTF = [[UITextField alloc] initWithFrame:CGRectMake(_spaceX, _spaceY, CGRectGetMinX(self.sendBtn.frame) - 2*_spaceX, btnH)];
    self.editContentTF.layer.cornerRadius = 5;
    self.editContentTF.backgroundColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
    self.editContentTF.font = font;
    self.editContentTF.returnKeyType = UIReturnKeySend;
    self.editContentTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.editContentTF.leftViewMode = UITextFieldViewModeAlways;
    self.editContentTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.editContentTF.textColor = [UIColor whiteColor];
    [self addSubview:self.editContentTF];
}

#pragma mark - Action

- (void)closeDanmuAction:(UIButton *)btn {
    if ([self.deleagte respondsToSelector:@selector(closeDanmu:)]) {
        [self.deleagte closeDanmu:btn];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat btnH = self.frame.size.height - 2*_spaceY;
    CGFloat btnW = 75;
    NSLog(@"%f %f",ScreenWidth,ScreenHeight);
   
    if (ScreenWidth >= 896) {
         _spaceX = 20;
        self.sendBtn.frame = CGRectMake(self.frame.size.width - btnW - _spaceX, _spaceY, btnW, btnH);
        self.editContentTF.frame = CGRectMake(_spaceX +SafeTop, _spaceY, CGRectGetMinX(self.sendBtn.frame) - 2*_spaceX - SafeTop, btnH);
    }
   
    
}


@end
