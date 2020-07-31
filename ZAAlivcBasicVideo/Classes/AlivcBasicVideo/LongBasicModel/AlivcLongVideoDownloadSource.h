//
//  AlivcLongVideoDownLoadSource.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/2.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import "AlivcLongVideoTVModel.h"
#import <AliyunMediaDownloader/AliyunMediaDownloader.h>

NS_ASSUME_NONNULL_BEGIN

@class AlivcLongVideoDownloadSource;

typedef void(^downloadTypeChangeBlock)(AlivcLongVideoDownloadSource *source);

typedef NS_ENUM(NSInteger, LongVideoDownloadType) {
    LongVideoDownloadTypeStoped,    //停止
    LongVideoDownloadTypeWaiting,    //等待
    LongVideoDownloadTypeLoading, //下载中
    LongVideoDownloadTypefinish,  //已完成
    LongVideoDownloadTypePrepared,//准备完成
    LongVideoDownloadTypeFailed
};

typedef NS_ENUM(NSInteger, DownloadSourceType) {
    DownloadSourceTypeSts,    //sts资源
    DownloadSourceTypeAuth    //auth资源
};

@interface AlivcLongVideoDownloadSource : NSObject

//这些不存数据库
@property (nonatomic,strong)AVPVidStsSource *stsSource;
@property (nonatomic,strong)AVPVidAuthSource *authSource;
@property (nonatomic,assign)LongVideoDownloadType downloadStatus;

//这些存数据库
@property (nonatomic,assign)int trackIndex;//视频的质量

@property (nonatomic,assign)int percent;

@property (nonatomic, assign) NSInteger episodeAlreadyWatchNum;//剧集观看了几集

@property (nonatomic, strong)AlivcLongVideoTVModel * longVideoModel;

@property (nonatomic,copy)NSString *downloadedFilePath;

@property (nonatomic, strong, nullable) NSData *video_imageData;//视频的图片数据
@property (nonatomic, strong, readonly) AVPMediaInfo *mediaInfo;

@property (nonatomic,copy)NSString *totalDataString;// 单个视频所占内存大小

@property (nonatomic,copy)NSString *episodeTotalDataString;// 多个剧集所占内存大小

@property (nonatomic, strong, nullable) NSString *fileName;//视频的本地播放地址
@property (nonatomic, strong, nullable) NSString *format;//视频格式
@property (nonatomic, strong, nullable) NSNumber *videoSize;  //视频大小

@property (nonatomic, assign) NSInteger episodeNum;  //如果是电视剧，缓存的级数
@property (nonatomic, assign) NSInteger firstTvSource;  // 是否在缓存页面的一级页面
@property (nonatomic, assign) BOOL watched;   //  单个视频是否观看

@property (nonatomic,assign)DownloadSourceType downloadSourceType;

/**
 Designated Method
 
 @param media 下载的媒体信息
 @return 实例对象
 */
- (instancetype)initWithMedia:(AVPMediaInfo *)media;
- (BOOL)refreshStatusWithMedia:(AlivcLongVideoDownloadSource *)source;
- (BOOL)isEqualToSource:(AlivcLongVideoDownloadSource *)source;

- (UIImage *__nullable)statusImage; // 状态图片
- (NSString *__nullable)statusString; // 状态信息

- (void)startDownLoad:(UIView *)view; // 开始下载
- (void)stopDownLoad;  // 停止下载

@property (nonatomic,strong)AliMediaDownloader *downloader;
@property (nonatomic,strong)downloadTypeChangeBlock downloadTypeChangeCallBack;

@end

NS_ASSUME_NONNULL_END
