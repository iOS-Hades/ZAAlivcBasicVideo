//
//  AlivcLongVideoPreviewLogoView.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/16.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoPreviewLogoView.h"
#import "NSString+AlivcHelper.h"
@interface AlivcLongVideoPreviewLogoView ()

@end

@implementation AlivcLongVideoPreviewLogoView

- (instancetype)init {
    
    if (self = [super init]) {
      
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [self setImage:[AlivcImage imageInBasicVideoNamed:@"VIPLogo"] forState:UIControlStateNormal];
        [self setBackgroundImage:[AlivcImage imageInBasicVideoNamed:@"VIPbg"] forState:UIControlStateNormal];
        [self setTitle:[@"试看前5分钟" localString] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
       
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
   
    CGFloat height = self.frame.size.height;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:0.99f green:0.73f blue:0.01f alpha:1.00f].CGColor;
    self.layer.cornerRadius = height/2;
    
}

@end
