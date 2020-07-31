//
//  AlivcLongVideoPlayButton.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/28.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define PlayButtonBeginTag 10

@interface AlivcLongVideoPlayButton : UIButton

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isCaching;
@property (nonatomic, assign) BOOL isMultSelect;
@property (nonatomic, assign) BOOL isCachedDown;


// 清除所有标志
- (void)cleanTag;

@end

NS_ASSUME_NONNULL_END
