//
//  AlivcLongVideoDownLoadSource.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/2.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoDownloadSource.h"
#import "NSString+AlivcHelper.h"
#import "AlivcAppServer.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcLongVideoDownLoadManager.h"
#import "AlivcLongVideoDBManager.h"
#import "AlivcLongVideoSTSConfig.h"
#import "AlivcDefine.h"

#define DEFAULT_DM  [AlivcLongVideoDownLoadManager shareManager]


@interface AlivcLongVideoDownloadSource()



@end

@implementation AlivcLongVideoDownloadSource

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloadStatus =LongVideoDownloadTypeStoped;
        self.percent = 0;
        self.episodeNum = 1;
        self.trackIndex = -1;
        self.firstTvSource = NO;
        self.downloadSourceType = DownloadSourceTypeSts;
    }
    return self;
}

- (instancetype)initWithMedia:(AVPMediaInfo *)media{
    self = [super init];
    if (self) {
        _mediaInfo = media;
        self.longVideoModel.title = media.title;
        
    }
    return self;
}


- (BOOL)refreshStatusWithMedia:(AlivcLongVideoDownloadSource *)source{
    if (source.mediaInfo == self.mediaInfo) {
        return true;
    }
    
    return false;
}

- (AlivcLongVideoTVModel *)longVideoModel {
    if (!_longVideoModel) {
        _longVideoModel = [[AlivcLongVideoTVModel alloc]init];
    }
    
    return _longVideoModel;
    
}

- (void)setTotalDataString:(NSString *)totalDataString {
    if (!totalDataString) {
        NSLog(@"q");
    }
    _totalDataString = totalDataString;
}

- (void)setDownloadStatus:(LongVideoDownloadType)downloadStatus {
    
    if (_downloadStatus  != downloadStatus) {
        _downloadStatus = downloadStatus;
       
        if (self.downloadTypeChangeCallBack) {
            [[AlivcLongVideoDBManager shareManager] updateSource:self];
            self.downloadTypeChangeCallBack(self);
        }
    }
}


- (void)setStsSource:(AVPVidStsSource *)stsSource {
    if (_stsSource != stsSource) {
        _stsSource = stsSource;
        if (stsSource.vid.length != 0) {
            self.longVideoModel.videoId = stsSource.vid;
        }
    }
}

- (void)setAuthSource:(AVPVidAuthSource *)authSource {
    if (_authSource != authSource) {
        _authSource = authSource;
        if (authSource.vid.length != 0) {
            self.longVideoModel.videoId = authSource.vid;
        }
    }
}

- (BOOL)isEqualToSource:(AlivcLongVideoDownloadSource *)source {
    if ([self.longVideoModel.videoId isEqualToString:source.longVideoModel.videoId] && self.trackIndex == source.trackIndex) {
        return YES;
    }
    return NO;
}

- (UIImage *__nullable)statusImage{
    return [AlivcLongVideoDownloadSource imageWithStatus:self.downloadStatus];
}

+ (UIImage *__nullable)imageWithStatus:(LongVideoDownloadType)status{
    switch (status) {
        case LongVideoDownloadTypeLoading:
            return [AlivcImage imageInBasicVideoNamed:@"avcDownloadPause"];
            break;
        case LongVideoDownloadTypeStoped:
            return [AlivcImage imageInBasicVideoNamed:@"avcDownload"];
            break;
        case LongVideoDownloadTypePrepared:
            return [AlivcImage imageInBasicVideoNamed:@"avcDownload"];
            break;
        case LongVideoDownloadTypeWaiting:
            return [AlivcImage imageInBasicVideoNamed:@"avcWait"];
            break;
        case LongVideoDownloadTypeFailed:
            return [AlivcImage imageInBasicVideoNamed:@"avcDownload"];
            break;
        default:
            return  nil;
            break;
    }
    
}

- (NSString *__nullable)statusString{
    return [AlivcLongVideoDownloadSource stringWithStatus:self.downloadStatus];
}

+ (NSString *__nullable)stringWithStatus:(LongVideoDownloadType)status{
    switch (status) {
        case LongVideoDownloadTypeLoading:
            return [@"下载中" localString];
            break;
        case LongVideoDownloadTypeWaiting:
            return [@"等待中" localString];
            break;
        case LongVideoDownloadTypeFailed:
            return [@"下载错误" localString];
            break;
        case LongVideoDownloadTypeStoped:
            return [@"已暂停" localString];
        default:
            return  nil;
            break;
    }
}


- (void)startDownLoad:(UIView *)view{
    self.downloadStatus = LongVideoDownloadTypeStoped;
    [DEFAULT_DM startDownloadSource:self];
}

- (void)stopDownLoad{
    
//    AliMediaDownloader * mediaDownLoader = self.downloader;
//    [mediaDownLoader stop];
//    self.downloadStatus = LongVideoDownloadTypeStoped;
    [DEFAULT_DM stopDownloadSource:self];
}

@end


