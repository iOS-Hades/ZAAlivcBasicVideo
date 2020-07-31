//
//  AlivcLongVideoCacheListViewController.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/1.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoBasicViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CacheVideoListType) {
    AllCacheVideoType,    // 全部缓存视频
    SpecificEpisodeType,  // 某个电视剧的缓存
};

@interface AlivcLongVideoCacheListViewController : AlivcLongVideoBasicViewController

@property (nonatomic, assign)CacheVideoListType videoListType;

@property (nonatomic, copy)NSString *tvId;

@end

NS_ASSUME_NONNULL_END
