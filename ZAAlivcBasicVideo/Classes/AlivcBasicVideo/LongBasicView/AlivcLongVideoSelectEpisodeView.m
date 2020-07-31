//
//  AlivcLongVideoSelectEpisodeView.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/27.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoSelectEpisodeView.h"
#import "AlivcLongVideoPlayButton.h"
#import "NSString+AlivcHelper.h"
#import "AlivcLongVideoTVModel.h"

#define EpisodeButtonTagBegin 10
#define EpisodeButtonWidth 50

@interface AlivcLongVideoSelectEpisodeView ()

@property (nonatomic, strong)UILabel * titleLabel;
@property (nonatomic, strong)UIButton * moreEpisodeButton;
@property (nonatomic, strong)UIScrollView * episodeScrollview;
@property (nonatomic, strong)UIImageView * arrowImageView;


@end

@implementation AlivcLongVideoSelectEpisodeView

- (instancetype)init {
    
    if (self = [super init]) {
        self.episodeArray = [[NSArray alloc]init];
        self.playingEpisodeIndex = 0;
        [self addSubview:self.titleLabel];
        [self addSubview:self.moreEpisodeButton];
        [self addSubview:self.episodeScrollview];
        
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font  = [UIFont systemFontOfSize:15];
        _titleLabel.text = [@"剧集" localString];
    }
    return _titleLabel;
}

- (UIButton *)moreEpisodeButton {
    
    if (!_moreEpisodeButton) {
        _moreEpisodeButton = [[UIButton alloc]init];
        [_moreEpisodeButton setTitleColor:[UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        _moreEpisodeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_moreEpisodeButton addTarget:self action:@selector(moreEpisode) forControlEvents:UIControlEventTouchUpInside];
        self.arrowImageView = [[UIImageView alloc]init];
        self.arrowImageView.image = [AlivcImage imageInBasicVideoNamed:@"rightArrow"];
        [_moreEpisodeButton addSubview:self.arrowImageView];
    }
    return _moreEpisodeButton;
}

- (UIScrollView *)episodeScrollview {
    
    if (!_episodeScrollview) {
        _episodeScrollview  = [[UIScrollView alloc]init];
        _episodeScrollview.showsHorizontalScrollIndicator = NO;
    }
    return _episodeScrollview;
}

// 初始化播放的index
- (void)setPlayingEpisodeIndex:(NSInteger)playingEpisodeIndex {
    
    if (playingEpisodeIndex == _playingEpisodeIndex) {
        return;
    }
    
    AlivcLongVideoPlayButton *preButton = [self viewWithTag:_playingEpisodeIndex + PlayButtonBeginTag];
    preButton.selected = NO;
    _playingEpisodeIndex = playingEpisodeIndex;
    AlivcLongVideoPlayButton *button = [self viewWithTag:_playingEpisodeIndex + PlayButtonBeginTag];
    button.selected = YES;
    
}

- (void)setEpisodeArray:(NSArray *)episodeArray {
    _episodeArray = episodeArray;
    NSInteger num = episodeArray.count;
    CGFloat space = 10;
    self.episodeScrollview.contentSize = CGSizeMake((EpisodeButtonWidth +space)*num + space , 50);
    
    for (UIView *view in self.episodeScrollview.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i<num; ++i) {
        AlivcLongVideoTVModel *model = [episodeArray objectAtIndex:i];
        AlivcLongVideoPlayButton * button = [[AlivcLongVideoPlayButton alloc]init];
        button.frame = CGRectMake((i+1)*space+EpisodeButtonWidth *i, 0, EpisodeButtonWidth, EpisodeButtonWidth);
        button.tag = EpisodeButtonTagBegin +i;
        [button addTarget:self action:@selector(clickToplay:) forControlEvents:UIControlEventTouchUpInside];
        if (model.sort == nil) {
            model.sort = @"1";
        }
        [button setTitle:model.sort forState:UIControlStateNormal];
        [button setTitle:model.sort forState:UIControlStateSelected];
        if (i== self.playingEpisodeIndex) {
            button.selected = YES;
        }
        [_episodeScrollview addSubview:button];
    }
    
    [self.moreEpisodeButton setTitle:[[@"全?集" localString] stringByReplacingOccurrencesOfString:@"?" withString:[NSString stringWithFormat:@"%lu",(unsigned long)(unsigned long)self.episodeArray.count]] forState:UIControlStateNormal];
}

- (void)clickToplay:(UIButton *)button {
    
    NSInteger episode = button.tag - EpisodeButtonTagBegin;
    if (episode == self.playingEpisodeIndex) {
        return;
    }
    UIButton *preButton = [self viewWithTag:self.playingEpisodeIndex+ EpisodeButtonTagBegin];
    preButton.selected = NO;
    self.playingEpisodeIndex = episode;
    button.selected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoSelectEpisodeViewClickEpisode:)]) {
        [self.delegate alivcLongVideoSelectEpisodeViewClickEpisode:episode];
    }
    
    
}

- (void)scrollToIndex:(NSInteger)index {
     CGFloat preX = self.episodeScrollview.contentOffset.x;
    
     CGFloat space = 10;
    
    CGFloat xLeft = (space + EpisodeButtonWidth) *index +space;
    CGFloat xRight = (space + EpisodeButtonWidth) * (index +1);
    if (preX > xLeft || xRight - preX >ScreenWidth) {
        
        [self.episodeScrollview scrollRectToVisible:CGRectMake(xLeft, 0, ScreenWidth, 50) animated:YES];
    }
    
    
}

- (void)moreEpisode{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoSelectEpisodeViewGetMoreEpisode)]) {
        [self.delegate alivcLongVideoSelectEpisodeViewGetMoreEpisode];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
   // CGFloat height = self.frame.size.height;
    self.titleLabel.frame = CGRectMake(15, 0, 80, 20);
    self.moreEpisodeButton.frame = CGRectMake(width - 80, 0, 80, 20);
    self.moreEpisodeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    self.arrowImageView.frame = CGRectMake(50, 0, 20, 20);
    self.episodeScrollview.frame = CGRectMake(0, 40, width, 50);
   
}

@end
