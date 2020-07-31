//
//  AlivcLongVideoDBManager.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/2.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcLongVideoDownloadSource.h"

NS_ASSUME_NONNULL_BEGIN

#define DEFAULT_DB   [AlivcLongVideoDBManager shareManager]

@interface AlivcLongVideoDBManager : NSObject

+ (instancetype)shareManager;

- (void)addSource:(AlivcLongVideoDownloadSource *)source;

- (void)deleteSource:(AlivcLongVideoDownloadSource *)source;

- (void)deleteAll;

- (void)deleteSourceWithTvId:(NSString *)tvId;

- (void)updateSource:(AlivcLongVideoDownloadSource *)source;


- (NSArray <AlivcLongVideoDownloadSource *>*)allSource;
// 获取所有缓存，如果存在剧集只获取该剧集的一个
- (NSArray <AlivcLongVideoDownloadSource *>*)allSourceNoRepeatTv;

// 获取某个电视剧的缓存
- (NSArray <AlivcLongVideoDownloadSource *>*)tvSource:(NSString *)tvId;

- (BOOL)hasSource:(AlivcLongVideoDownloadSource *)source;

// 获取某个电视剧的缓存内存大小
- (CGFloat)cachedMemoryWithTvId:(NSString *)tvId;

/*********** 观看历史记录部分 *********/

- (void)addHistoryTVModel:(AlivcLongVideoTVModel *)model;

- (void)deleteAllHistory;

- (NSArray *)historyTVModelArray;

- (BOOL)hasHistoryTVModelFromvideoId:(NSString *)videoId;

@end

NS_ASSUME_NONNULL_END
