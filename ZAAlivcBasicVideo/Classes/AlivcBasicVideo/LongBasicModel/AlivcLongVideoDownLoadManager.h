//
//  AlivcLongVideoDownLoadManager.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/2.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcLongVideoDownloadSource.h"


NS_ASSUME_NONNULL_BEGIN

#define DEFAULT_DM  [AlivcLongVideoDownLoadManager shareManager]

typedef NS_ENUM(NSInteger, DownloadType) {
    DownloadTypeStoped,    //停止
    DownloadTypeWaiting,    //等待
    DownloadTypeLoading, //下载中
    DownloadTypefinish,  //已完成
    DownloadTypePrepared,//准备完成
    DownloadTypeFailed
};


@class AlivcLongVideoDownLoadManager;

@protocol AlivcLongVideoDownLoadManagerDelegate <NSObject>

@optional

/**
 @brief 下载准备完成事件回调
 @param source 下载source指针
 @param info 下载准备完成回调，@see AVPMediaInfo
 */
-(void)downloadManagerOnPrepared:(AlivcLongVideoDownloadSource *)source mediaInfo:(AVPMediaInfo*)info;

/**
 @brief 错误代理回调
 @param source 下载source指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)downloadManagerOnError:(AlivcLongVideoDownloadSource *)source errorModel:(AVPErrorModel *)errorModel;

/**
 @brief 下载进度回调
 @param source 下载source指针
 @param percent 下载进度 0-100
 */
- (void)downloadManagerOnProgress:(AlivcLongVideoDownloadSource *)source percentage:(int)percent;

/**
 @brief 下载完成回调
 @param source 下载source指针
 */
- (void)downloadManagerOnCompletion:(AlivcLongVideoDownloadSource *)source;

/**
 下载状态改变回调
 */
- (void)onSourceStateChanged:(AlivcLongVideoDownloadSource *)source;

@end

@interface AlivcLongVideoDownLoadManager : NSObject

/**
 最大下载个数，默认5个
 */
@property (nonatomic,assign) NSInteger maxDownloadCount;

/**
 代理
 */
@property (nonatomic,weak) id<AlivcLongVideoDownLoadManagerDelegate> delegate;

/**
 下载路径
 */
@property (nonatomic,strong) NSString *downLoadPath;

/**
 region
 */
@property (nonatomic,strong)NSString *region;

/**
 securityToken
 */
@property (nonatomic,strong)NSString *securityToken;

/**
 accessKeySecret
 */
@property (nonatomic,strong)NSString *accessKeySecret;

/**
 accessKeyId
 */
@property (nonatomic,strong)NSString *accessKeyId;

/**
 获取单利对象
 
 @return 单利对象
 */
+ (instancetype)shareManager;

/*
 功能：调用此方法来获取下载视频信息，OnPrepare回调来获取
 参数：source 视频信息源
 */
- (void)prepareDownloadSource:(AlivcLongVideoDownloadSource *)source;

/*
 功能：调用此方法来添加下载视频信息
 参数：source 视频信息源
 */
- (void)addDownloadSource:(AlivcLongVideoDownloadSource *)source;

/*
 功能：开始下载单个视频资源。调用此方法后，开始下载视频
 参数：source 视频信息源
 */
- (void)startDownloadSource:(AlivcLongVideoDownloadSource *)source;

/*
 功能：开始所有下载视频资源
 */
- (void)startAllDownloadSources;

/*
 功能：结束下载视频资源
 参数：source 视频信息项
 */
- (void)stopDownloadSource:(AlivcLongVideoDownloadSource *)source;

/*
 功能：停止所有下载视频资源
 */
- (void)stopAllDownloadSources;

/*
 功能：获取正在下载视频资源列表,包括等待下载列表
 参数：downloadingdSources 视频信息项列表
 */
- (NSArray<AlivcLongVideoDownloadSource*> *)downloadingdSources;

/*
 功能：获取已经完成的列表
 参数：downloadingdSources 视频信息项列表
 */
- (NSArray<AlivcLongVideoDownloadSource*> *)doneSources;

/*
 功能：获取所有的视频资源列表
 */
- (NSArray<AlivcLongVideoDownloadSource*> *)allReadySources;

/*
 功能：获取所有的视频资源列表
 */
- (NSArray<AlivcLongVideoDownloadSource*> *)allReadySourcesWithoutRepeatTv;

/*
 功能：获取电视剧资源列表
 */
- (NSArray <AlivcLongVideoDownloadSource *>*)tvSource:(NSString *)tvId;

/*
 功能：获取电视剧资源缓存大小
 */
- (CGFloat)cachedMemoryWithTvId:(NSString *)tvId;
/*
 功能：清除指定下载的视频资源
 参数：downloadSource 要删除的视频资源
 */
-(int)clearMedia:(AlivcLongVideoDownloadSource *)source;
/*
 功能：清除某个电视剧的所有剧集
 */
- (void)clearMediaWithTvId:(NSString *)tvID;

/*
 功能：清除所有准备的的视频资源
 */
- (void)clearAllPreparedSources;

/*
 功能：清除所有下载的视频资源
 */
- (void)clearAllSources;

/**
 功能：清除所有下载的视频资源
 
 @return 是否全部成功
 */
- (int)clearAllSourcesFromMediaDownloader;

/**
 功能：判断视频是否在下载列表中了
 
 @return 存在，返回本地的视频信息
 */
- (AlivcLongVideoDownloadSource *)hasDownloadSource:(AlivcLongVideoDownloadSource *)source;
/**
 功能：判断视频是否在下载列表中,videoId 对比
 
 @return 存在，返回本地的视频信息
 */
- (BOOL)hasDownloadSourceVideoId:(AlivcLongVideoDownloadSource *)source;
/**
 功能：网络状况是否允许下载
 
 @return 存在，返回本地的视频信息
 */
- (BOOL)allowDownload;
/**
 功能：请求下载剧集支持的清晰度
 */
- (void)onlyPrepareForTracks:(AlivcLongVideoDownloadSource *)source;

@end

NS_ASSUME_NONNULL_END
