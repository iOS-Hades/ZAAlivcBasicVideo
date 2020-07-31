//
//  AlivcLongVideoSelectEpisodeView.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/27.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AlivcLongVideoSelectEpisodeViewDelegate <NSObject>

// episode 从0开始
- (void)alivcLongVideoSelectEpisodeViewClickEpisode:(NSInteger)episode;
- (void)alivcLongVideoSelectEpisodeViewGetMoreEpisode;

@end


@interface AlivcLongVideoSelectEpisodeView : UIView

@property (nonatomic, strong)NSArray *episodeArray;
@property (nonatomic, assign)NSInteger playingEpisodeIndex;
@property (nonatomic, weak)id <AlivcLongVideoSelectEpisodeViewDelegate> delegate;

- (void)scrollToIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
