//
//  UIScrollView+NetworkLost.m
//  longVideo
//
//  Created by Aliyun on 2019/7/18.
//  Copyright © 2019 Aliyun. All rights reserved.
//

#import "UIScrollView+NetworkLost.h"
#import "NSString+AlivcHelper.h"
#import <objc/runtime.h>

@interface UIScrollView (_NetworkLost)

@property (nonatomic,strong)UIButton *retryButton;
@property (nonatomic,strong)retryCallBack callBack;
@property (nonatomic,strong)UILabel *middleLabel;

@end

@implementation UIScrollView (NetworkLost)

- (void)setRetryButton:(UIButton *)retryButton {
    objc_setAssociatedObject(self, @selector(retryButton), retryButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIButton *)retryButton {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCallBack:(retryCallBack)callBack {
    objc_setAssociatedObject(self, @selector(callBack), callBack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (retryCallBack)callBack {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMiddleLabel:(UILabel *)middleLabel {
    objc_setAssociatedObject(self, @selector(middleLabel), middleLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)middleLabel {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)showNetworkLostView {
    if (!self.retryButton) {
        UIButton *retryButton = [[UIButton alloc]initWithFrame:self.bounds];
        [retryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [retryButton setTitle:[@"当前无网络，点击重试" localString] forState:UIControlStateNormal];
        retryButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [retryButton setImage:[AlivcImage imageInBasicVideoNamed:@"network_lost"] forState:UIControlStateNormal];
        CGFloat imageWith = retryButton.imageView.frame.size.width;
        CGFloat imageHeight = retryButton.imageView.frame.size.height;
        CGFloat labelWidth = retryButton.titleLabel.intrinsicContentSize.width;
        CGFloat labelHeight = retryButton.titleLabel.intrinsicContentSize.height;
        retryButton.imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-10, 0, 0, -labelWidth);
        retryButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-10, 0);
        [retryButton addTarget:self action:@selector(retryButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:retryButton];
        self.retryButton = retryButton;
    }
    self.retryButton.hidden = NO;
}

- (void)retryButtonClick {
    if (self.callBack) { self.callBack(); }
}

- (void)dismissNetworkLostView {
    self.retryButton.hidden = YES;
}

- (void)networkLostRetryCallBack:(retryCallBack)callBack {
    self.callBack = callBack;
}

- (void)showMiddleLabelWithTitle:(NSString *)title {
    if (self.retryButton && self.retryButton.hidden == NO) {
        return;
    }
    if (!self.middleLabel) {
        UILabel *middleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        middleLabel.numberOfLines = 0;
        middleLabel.textColor = [UIColor lightGrayColor];
        middleLabel.font = [UIFont systemFontOfSize:15];
        middleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:middleLabel];
        self.middleLabel = middleLabel;
    }
    self.middleLabel.text = title;
    self.middleLabel.hidden = NO;
}

- (void)dismissMiddleLabel {
    self.middleLabel.hidden = YES;
}

@end
