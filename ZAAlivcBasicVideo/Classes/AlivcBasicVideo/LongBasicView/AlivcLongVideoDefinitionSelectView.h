//
//  AlivcLongVideoDefinitionSelectView.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/28.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunPlayer/AliyunPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AlivcLongVideoDefinitionSelectViewDelegate <NSObject>

- (void)alivcLongVideoDefinitionSelectViewSelecTrack:(AVPTrackInfo *)info;

@end


@interface AlivcLongVideoDefinitionSelectView : UIView

@property (nonatomic, weak)id <AlivcLongVideoDefinitionSelectViewDelegate>delegate;

/**
 清晰度选项
 */
@property (nonatomic, strong) NSArray <AVPTrackInfo*> * trackInfoArray;


@end

NS_ASSUME_NONNULL_END
