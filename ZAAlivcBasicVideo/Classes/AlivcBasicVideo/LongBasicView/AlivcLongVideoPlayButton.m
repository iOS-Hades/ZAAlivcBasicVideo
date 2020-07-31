//
//  AlivcLongVideoPlayButton.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/28.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoPlayButton.h"
@interface AlivcLongVideoPlayButton ()

@property (nonatomic, strong)UIImageView *playingImageView;
@property (nonatomic, strong)UIImageView *tagImageView;

@end


@implementation AlivcLongVideoPlayButton

- (instancetype)init {
    
    if (self = [super init]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2;
        self.backgroundColor = [UIColor colorWithRed:236/255.0 green:239/255.0 blue:241/255.0 alpha:1/1.0];
        [self setTitleColor: [UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha: 1/1.0] forState:UIControlStateNormal];
      
        [self setTitleColor: [UIColor colorWithRed:254/255.0 green:65/255.0 blue:16/255.0 alpha: 1/1.0] forState:UIControlStateSelected];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.tagImageView];
        [self addSubview:self.playingImageView];
        self.playingImageView.hidden = YES;
        
    }
    
    return self;
}

- (UIImageView *)tagImageView {
    
    if (!_tagImageView) {
        _tagImageView = [[UIImageView alloc]init];
        _tagImageView.layer.masksToBounds = YES;
    }
    
    return _tagImageView;
}

- (UIImageView *)playingImageView {
    if (!_playingImageView) {
        _playingImageView = [[UIImageView alloc]init];
        _playingImageView.image = [AlivcImage imageInBasicVideoNamed:@"playing"];
    }
    
    return _playingImageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    self.tagImageView.frame = CGRectMake(width - 20, width - 20, 15, 15);
    
    self.playingImageView.frame = CGRectMake(5, 5, 15, 15);
    
}

- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    if (isPlaying) {
        self.playingImageView.hidden = NO;
    }else {
        self.playingImageView.hidden = YES;
    }
    
}

- (void)setIsCaching:(BOOL)isCaching {
    _isCaching = isCaching;
    
    if (isCaching) {
        self.tagImageView.image = [AlivcImage imageInBasicVideoNamed:@"isLoading"];
    }else {
        self.tagImageView.image = nil;
    }
}

- (void)setIsCachedDown:(BOOL)isCachedDown {
    _isCachedDown = isCachedDown;

    if (isCachedDown) {
        self.tagImageView.image = [AlivcImage imageInBasicVideoNamed:@"finishDownload"];
    }else {
        self.tagImageView.image = nil;
    }
    
}


- (void)setIsMultSelect:(BOOL)isMultSelect {
    _isMultSelect = isMultSelect;
    if (isMultSelect) {
        self.tagImageView.image = [AlivcImage imageInBasicVideoNamed:@"multSelected"];
    }else {
        self.tagImageView.image = nil;
    }
    
}


- (void)cleanTag{
    self.isMultSelect = NO;
    self.isCachedDown = NO;
    self.isPlaying = NO;
    self.isCaching = NO;
    
}


@end
