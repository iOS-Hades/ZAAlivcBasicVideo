//
//  AlivcLongVideoViewController.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/25.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoBasicViewController.h"
#import "AlivcVideoPlayPlayerConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface AlivcLongVideoViewDetailController : AlivcLongVideoBasicViewController

@property (nonatomic,copy) AlivcLongVideoTVModel *model;
@property (nonatomic,assign)NSInteger watchProgress;
@property (nonatomic,strong)AlivcVideoPlayPlayerConfig *playerConfig;

@end

NS_ASSUME_NONNULL_END
