//
//  AlivcLongVideoDownLoadManager.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/2.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoDownLoadManager.h"
#import <AliyunMediaDownloader/AliyunMediaDownloader.h>
#import "NSString+AlivcHelper.h"
#import "AlivcAppServer.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcLongVideoDBManager.h"
#import "AlivcLongVideoSTSConfig.h"
#import "AlivcLongVideoCommonFunc.h"
#import "AliyunReachability.h"
#import "AlivcDefine.h"
#import "NSString+AlivcHelper.h"

@interface AlivcLongVideoDownLoadManager ()<AMDDelegate>

@property (nonatomic,strong)NSMutableArray<AlivcLongVideoDownloadSource*> *allSourcesArray;
@property (nonatomic,assign)NSInteger downloadCount;//正在下载个数
@property (nonatomic, strong) AliyunReachability *reachability;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation AlivcLongVideoDownLoadManager

- (void)setMaxDownloadCount:(NSInteger)maxDownloadCount {
    if (_maxDownloadCount != maxDownloadCount) {
        _maxDownloadCount = maxDownloadCount;
        [self startDownloadTask];
    }
}

+ (instancetype)shareManager {
    static AlivcLongVideoDownLoadManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AlivcLongVideoDownLoadManager alloc]init];
        manager.queue = dispatch_queue_create("DownLoad", DISPATCH_QUEUE_SERIAL);
        manager.region = @"cn-shanghai";
        manager.downloadCount = 0;
        manager.maxDownloadCount = [[AlivcLongVideoCommonFunc getUDSetWithIndex:0] integerValue];
        manager.allSourcesArray = [NSMutableArray array];
        manager.downLoadPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSArray *allArray = [DEFAULT_DB allSource];
        __weak typeof(AlivcLongVideoDownLoadManager *) weakManager = manager;
        for (AlivcLongVideoDownloadSource *source in allArray) {
            if (source.percent == 100) {
                source.downloadStatus = DownloadTypefinish;
            }else {
                source.downloadStatus = DownloadTypeStoped;
                source.downloadTypeChangeCallBack = ^(AlivcLongVideoDownloadSource *source) {
                    if ([weakManager.delegate respondsToSelector:@selector(onSourceStateChanged:)]) {
                        [weakManager.delegate onSourceStateChanged:source];
                    }
                };
            }
            [manager.allSourcesArray addObject:source];
        }
    });
    
    manager.reachability = [AliyunReachability reachabilityForInternetConnection];
    [manager.reachability startNotifier];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:manager
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
   
    
    return manager;
}

#pragma mark 收到通知执行的函数

- (void)applicationWillTerminate {
    
    for (AlivcLongVideoDownloadSource * source in self.allSourcesArray) {
        if (source.downloader && (source.downloadStatus == LongVideoDownloadTypeWaiting || source.downloadStatus == LongVideoDownloadTypeLoading)) {
            [source stopDownLoad];
        }
    }
    
}

- (void)reachabilityChanged {
    
    if ([self allowDownload] == YES) {
        NSLog(@"start download~~~~~~~~~~~~~~~~~~~~~~~~~");
        for (AlivcLongVideoDownloadSource * source in self.allSourcesArray) {
            if (source.downloader && source.downloadStatus == LongVideoDownloadTypeWaiting) {
                
                source.downloadStatus = LongVideoDownloadTypeStoped;
                [self startDownloadSource:source];
            
            }
        }
    
    }else if ([self allowDownload] == NO){
        NSLog(@"stop download~~~~~~~~~~~~~~~~~~~~~~~~~");
        for (AlivcLongVideoDownloadSource * source in self.allSourcesArray) {
            if (source.downloader && source.downloadStatus == LongVideoDownloadTypeLoading) {
                [source stopDownLoad];
                source.downloadStatus = LongVideoDownloadTypeWaiting;
                self.downloadCount --;
            }
        }
        
    }

}

- (void)onlyPrepareForTracks:(AlivcLongVideoDownloadSource *)source {
    AliMediaDownloader *downloader = [[AliMediaDownloader alloc] init];
    [downloader setSaveDirectory:self.downLoadPath];
    [downloader setDelegate:self];
    if (source.downloadSourceType == DownloadSourceTypeSts) {
        [downloader prepareWithVid:source.stsSource];
    }else {
        [downloader prepareWithPlayAuth:source.authSource];
    }
    source.downloader = downloader;
    source.downloadStatus = LongVideoDownloadTypePrepared;
}

- (void)prepareDownloadSource:(AlivcLongVideoDownloadSource *)source {
    
    AlivcLongVideoDownloadSource *hasSource = [self hasDownloadSource:source];
    if (hasSource) {
        AVPErrorModel *errorModel = [[AVPErrorModel alloc]init];
        errorModel.message = [@"已经加入下载列表" localString];
        [self.delegate downloadManagerOnError:source errorModel:errorModel];
        return;
    }
    
    AliMediaDownloader *downloader = [[AliMediaDownloader alloc] init];
    [downloader setDelegate:self];
    [downloader setSaveDirectory:self.downLoadPath];
    source.downloader = downloader;
    if (source.downloadSourceType == DownloadSourceTypeSts) {
        [downloader prepareWithVid:source.stsSource];
    }else {
        [downloader prepareWithPlayAuth:source.authSource];
    }
    source.downloadStatus = LongVideoDownloadTypePrepared;
    [self.allSourcesArray addObject:source];
    
}


- (AVPVidStsSource *)getStsSourceFromVid:(NSString *)vid {
    
    AlivcLongVideoSTSConfig *stsConfig = [AlivcLongVideoSTSConfig sharedInstance];
    if (!vid || !stsConfig.stsSecurityToken) { return nil; }
    AVPVidStsSource* stsSource = [[AVPVidStsSource alloc] init];
    stsSource.vid = vid;
    stsSource.region = self.region;
    stsSource.securityToken = stsConfig.stsSecurityToken;
    stsSource.accessKeySecret = stsConfig.stsAccessSecret;
    stsSource.accessKeyId = stsConfig.stsAccessKeyId;
    return stsSource;
}

- (void)onErrorWithNoSts:(AlivcLongVideoDownloadSource *)source code:(AVPErrorCode)code{
    if ([self.delegate respondsToSelector:@selector(downloadManagerOnError:errorModel:)]) {
        AVPErrorModel *errorModel = [[AVPErrorModel alloc]init];
        errorModel.message = [@"鉴权信息缺失" localString];
        errorModel.code = code;
        [self.delegate downloadManagerOnError:source errorModel:errorModel];
    }
}

- (void)addDownloadSource:(AlivcLongVideoDownloadSource *)source {
    AlivcLongVideoDownloadSource *hasSource = [self hasDownloadSource:source];
    if (!hasSource){
        hasSource = source;
        
    }
     if (hasSource.downloadStatus == LongVideoDownloadTypePrepared) {
        __weak typeof(self) weakSelf = self;
        hasSource.downloadTypeChangeCallBack = ^(AlivcLongVideoDownloadSource *backSource) {
            if ([weakSelf.delegate respondsToSelector:@selector(onSourceStateChanged:)]) {
                [weakSelf.delegate onSourceStateChanged:backSource];
            }
        };
        hasSource.downloadStatus = LongVideoDownloadTypeStoped;
        [DEFAULT_DB addSource:hasSource];
    }
//    NSArray *array = [DEFAULT_DB allSource];
//    NSLog(@"%@",array);
    
   
}

- (void)startDownloadSource:(AlivcLongVideoDownloadSource *)source {
    AlivcLongVideoDownloadSource *hasSource = [self hasDownloadSource:source];
    if (hasSource && hasSource.downloadStatus == LongVideoDownloadTypeStoped) {
        [self startSourceTask:hasSource];
        [self startDownloadTask];
    }
}


- (void)startAllDownloadSources {
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
        if (source.downloadStatus == DownloadTypeStoped) {
            [self startSourceTask:source];
        }
    }
    [self startDownloadTask];
}

- (void)startSourceTask:(AlivcLongVideoDownloadSource *)source {
    if (source.downloadSourceType == DownloadSourceTypeSts) {
        if (!source.stsSource || source.stsSource.securityToken.length == 0) {
            [self onErrorWithNoSts:source code:ERROR_SERVER_POP_TOKEN_EXPIRED];
        }else {
            source.downloadStatus = DownloadTypeWaiting;
        }
    }else {
        if (!source.authSource || source.authSource.playAuth.length == 0) {
            [self onErrorWithNoSts:source code:ERROR_SERVER_VOD_INVALIDAUTHINFO_EXPIRETIME];
        }else {
            source.downloadStatus = DownloadTypeWaiting;
        }
    }
}

- (void)stopDownloadSource:(AlivcLongVideoDownloadSource *)source {
    AlivcLongVideoDownloadSource *hasSource = [self hasDownloadSource:source];
    if (hasSource) {
        if (hasSource.downloadStatus == DownloadTypeLoading) {
            self.downloadCount --;
            [hasSource.downloader stop];
            hasSource.downloadStatus = DownloadTypeStoped;
        }else if (source.downloadStatus == DownloadTypeWaiting) {
            hasSource.downloadStatus = DownloadTypeStoped;
        }
        [self startDownloadTask];
    }
}

- (void)stopAllDownloadSources {
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
        if (source.downloadStatus == DownloadTypeLoading) {
            self.downloadCount --;
            [source.downloader stop];
            source.downloadStatus = DownloadTypeStoped;
        }else if (source.downloadStatus == DownloadTypeWaiting) {
            source.downloadStatus = DownloadTypeStoped;
        }
    }
}

- (NSArray<AlivcLongVideoDownloadSource*> *)downloadingdSources {
    NSMutableArray *backArray = [NSMutableArray array];
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
        if (source.downloadStatus == LongVideoDownloadTypeLoading || source.downloadStatus == LongVideoDownloadTypeWaiting || source.downloadStatus == LongVideoDownloadTypeStoped) {
            [backArray addObject:source];
        }
    }
    return backArray.copy;
}

- (NSArray<AlivcLongVideoDownloadSource*> *)doneSources {
    NSMutableArray *backArray = [NSMutableArray array];
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
        if (source.downloadStatus == LongVideoDownloadTypefinish) {
            [backArray addObject:source];
        }
    }
    return backArray.copy;
}

- (NSArray<AlivcLongVideoDownloadSource*> *)allReadySources {
    
    NSMutableArray *backArray = [NSMutableArray array];
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
        if (source.downloadStatus != LongVideoDownloadTypePrepared) {
            [backArray addObject:source];
        }
    }
    return backArray.copy;
}


- (NSArray<AlivcLongVideoDownloadSource*> *)allReadySourcesWithoutRepeatTv {
    
    NSMutableArray *backArray = [NSMutableArray array];
    NSMutableArray *tvIdArray = [[NSMutableArray alloc]init];
    
    
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
        
        for (AlivcLongVideoDownloadSource * addSource in backArray) {
            if (addSource.longVideoModel.tvId && ![addSource.longVideoModel.tvId isEqualToString:@"(null)"]) {
                [tvIdArray addObject:addSource.longVideoModel.tvId];
            }
            
        }
        
        
        
        if (source.longVideoModel.tvId && source.longVideoModel.tvId.length >0 && ![source.longVideoModel.tvId isEqualToString:@"(null)"] && source.downloadStatus != LongVideoDownloadTypePrepared  && ![tvIdArray containsObject:source.longVideoModel.tvId]) {
            [backArray addObject:source];
            
        }else if (source.downloadStatus != LongVideoDownloadTypePrepared && ([source.longVideoModel.tvId isEqualToString:@"(null)"] ||source.longVideoModel.tvId.length == 0 ) ) {
            [backArray addObject:source];
        }

    }
    return backArray.copy;
    
}

- (NSArray <AlivcLongVideoDownloadSource *>*)tvSource:(NSString *)tvId {
    
    NSMutableArray *tvIdSourceArray = [[NSMutableArray alloc]init];
    for (AlivcLongVideoDownloadSource * downloadSource in self.allSourcesArray) {
        if (downloadSource.longVideoModel.tvId && [downloadSource.longVideoModel.tvId isEqualToString:tvId]) {
            [tvIdSourceArray addObject:downloadSource];
        }
    }

  return   tvIdSourceArray;
    
    //return [DEFAULT_DB tvSource:tvId];
 
}

- (CGFloat)cachedMemoryWithTvId:(NSString *)tvId {
    
    return [DEFAULT_DB cachedMemoryWithTvId:tvId];
}

-(int)clearMedia:(AlivcLongVideoDownloadSource *)source {
    int result = 0;
    if (source.downloader) {
        if (source.downloadStatus == LongVideoDownloadTypeLoading) {
            self.downloadCount --;
        }
        [source.downloader stop];
        [source.downloader deleteFile];
        source.downloader = nil;
        source.downloadStatus = LongVideoDownloadTypeStoped;
    }else if (source.downloadedFilePath == nil){
       
        [self.allSourcesArray removeObject:source];
        [DEFAULT_DB deleteSource:source];
        return  result;
    }
    else {
        NSArray *pathArray = [source.downloadedFilePath componentsSeparatedByString:@"."];
        NSString *format = pathArray.lastObject;
        result = [AliMediaDownloader deleteFile:DEFAULT_DM.downLoadPath vid:source.longVideoModel.videoId format:format index:source.trackIndex];
    }
    if (result == 0) {
        [self.allSourcesArray removeObject:source];
        [DEFAULT_DB deleteSource:source];

    }
    return result;
}

- (void)clearMediaWithTvId:(NSString *)tvID {
    
    NSArray * tvArray = [self tvSource:tvID];
    
    for (AlivcLongVideoDownloadSource *source in tvArray) {
        [self clearMedia:source];
    }
    
}

- (void)clearAllPreparedSources {
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray.copy) {
        if (source.downloadStatus == LongVideoDownloadTypePrepared) {
            source.downloader = nil;
            [self.allSourcesArray removeObject:source];
        }
    }
}

- (void)clearAllSources {
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
        if (source.downloader) {
            [source.downloader stop];
            source.downloader = nil;
        }
    }
    self.downloadCount = 0;
    [self.allSourcesArray removeAllObjects];
    [DEFAULT_DB deleteAll];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:DEFAULT_DM.downLoadPath error:nil];
}

- (int)clearAllSourcesFromMediaDownloader {
    int result = 0;
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray.copy) {
        int onceResult = 0;
        if (source.downloader) {
            [source.downloader stop];
            [source.downloader deleteFile];
            source.downloader = nil;
        }else {
            NSArray *pathArray = [source.downloadedFilePath componentsSeparatedByString:@"."];
            NSString *format = pathArray.lastObject;
            onceResult = [AliMediaDownloader deleteFile:DEFAULT_DM.downLoadPath vid:source.longVideoModel.videoId format:format index:source.trackIndex];
        }
        if (onceResult == 0) {
            [self.allSourcesArray removeObject:source];
            [DEFAULT_DB deleteSource:source];
        }else {
            result = onceResult;
        }
    }
    self.downloadCount = 0;
    return result;
}

#pragma mark private

- (void)startDownloadTask {
    dispatch_async(self.queue, ^{
        if (self.downloadCount > self.maxDownloadCount) {
            for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
                if (source.downloadStatus == LongVideoDownloadTypeLoading) {
                    source.downloadStatus = LongVideoDownloadTypeWaiting;
                    [source.downloader stop];
                    self.downloadCount --;
                    if (self.downloadCount == self.maxDownloadCount) { return; }
                }
            }
        }else if (self.downloadCount < self.maxDownloadCount){
            
            // 从这里进入下载
            if ([self allowDownload] == NO) {
                return;
            }
        
            for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
                if (source.downloadStatus ==  LongVideoDownloadTypeWaiting) {
                    if (source.downloader) {
                        [source.downloader selectTrack:source.trackIndex];
                        source.downloadStatus = LongVideoDownloadTypeLoading;
                        [source.downloader start];
                        
                         self.downloadCount ++;
                        if (self.downloadCount == self.maxDownloadCount) { return; }
                    }else {
                        AliMediaDownloader *downloader = [[AliMediaDownloader alloc] init];
                        [downloader setSaveDirectory:self.downLoadPath];
                        
                        [downloader setDelegate:self];
                        if (source.downloadSourceType == DownloadSourceTypeSts) {
                            [downloader prepareWithVid:source.stsSource];
                        }else {
                            [downloader prepareWithPlayAuth:source.authSource];
                        }
                        source.downloader = downloader;
                        
                    }
                }
            }
        }
    });
}

- (AlivcLongVideoDownloadSource *)hasDownloadSource:(AlivcLongVideoDownloadSource *)source {
    
    for (AlivcLongVideoDownloadSource *eveSource in self.allSourcesArray) {//
        if ([eveSource isEqualToSource:source]) {
            return eveSource;
        }
    }
    return nil;
}

- (BOOL)hasDownloadSourceVideoId:(AlivcLongVideoDownloadSource *)source {
    for (AlivcLongVideoDownloadSource *eveSource in self.allSourcesArray) {//
        if ([eveSource.longVideoModel.videoId isEqualToString:source.longVideoModel.videoId]) {
            return YES;
        }
    }
    return NO;
    
}

#pragma mark AMDDelegate

- (AlivcLongVideoDownloadSource *)findSourceFromDownloader:(AliMediaDownloader *)downloader {
    for (AlivcLongVideoDownloadSource *source in self.allSourcesArray) {
        if (source.downloader == downloader) {
            return source;
        }
    }
    return nil;
}

-(void)onPrepared:(AliMediaDownloader *)downloader mediaInfo:(AVPMediaInfo *)info {
    AlivcLongVideoDownloadSource * source = [self findSourceFromDownloader:downloader];
   
    if (source.trackIndex < 0) {
        BOOL defaultDefinition = NO;
        source.longVideoModel.title = info.title;
        source.longVideoModel.coverUrl = info.coverURL;
        NSArray * tracks = info.tracks;
        
        NSString *definition = [AlivcLongVideoCommonFunc getUDSetWithIndex:1];
        NSString *eDefinitin = [AlivcLongVideoCommonFunc definitionWithChiStr:definition];
        for (AVPTrackInfo * trackInfo in tracks) {
            if ([trackInfo.trackDefinition isEqualToString:eDefinitin] ) {
                CGFloat mSize =    trackInfo.vodFileSize /1024.0 /1024.0;
                NSString *mString = [NSString stringWithFormat:@"%.1fM",mSize];
                source.totalDataString = mString;
                source.format = trackInfo.vodFormat;
                source.videoSize =@(trackInfo.vodFileSize)  ;
                source.trackIndex = trackInfo.trackIndex ;
                defaultDefinition = YES;
                break;
            }
        }
        
        if (defaultDefinition == NO ) {
            AVPTrackInfo *trackInfo = [tracks objectAtIndex:0];
            CGFloat mSize =    trackInfo.vodFileSize /1024.0 /1024.0;
            NSString *mString = [NSString stringWithFormat:@"%.1fM",mSize];
            source.totalDataString = mString;
            source.format = trackInfo.vodFormat;
            source.videoSize =@(trackInfo.vodFileSize)  ;
            source.trackIndex = trackInfo.trackIndex ;
        }
    }
    
    if (source) {
        [self startDownloadTask];

    }
    if ([self.delegate respondsToSelector:@selector(downloadManagerOnPrepared:mediaInfo:)]) {
        [self.delegate downloadManagerOnPrepared:source mediaInfo:info];
    }
    
}

-(void)onError:(AliMediaDownloader *)downloader errorModel:(AVPErrorModel *)errorModel {
    AlivcLongVideoDownloadSource * source = [self findSourceFromDownloader:downloader];
    if (source) {
        if (source.downloadStatus == LongVideoDownloadTypePrepared) {
            [self.allSourcesArray removeObject:source];
        }else if (source.downloadStatus == DownloadTypeWaiting) {
            source.downloadStatus = LongVideoDownloadTypeStoped;
            [self startDownloadTask];
        }else if (source.downloadStatus == DownloadTypeLoading) {
            self.downloadCount --;
            source.downloadStatus = LongVideoDownloadTypeStoped;
            [source.downloader stop];
            [self startDownloadTask];
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(downloadManagerOnError:errorModel:)]) {
        [self.delegate downloadManagerOnError:source errorModel:errorModel];
    }
}

-(void)onDownloadingProgress:(AliMediaDownloader *)downloader percentage:(int)percent {
    NSLog(@"~~~~~~~~~~~~~~~~~~%d",percent);
    AlivcLongVideoDownloadSource * source = [self findSourceFromDownloader:downloader];
    if (source && percent != source.percent && source.percent  != 100) {
        source.percent = percent;
        NSArray *pathArray = [downloader.downloadedFilePath componentsSeparatedByString:@"/"];
        source.downloadedFilePath = pathArray.lastObject;
        if (percent == 100) {
            source.downloadStatus = DownloadTypefinish;
        }
        [DEFAULT_DB updateSource:source];
        if ([self.delegate respondsToSelector:@selector(downloadManagerOnProgress:percentage:)]) {
            [self.delegate downloadManagerOnProgress:source percentage:percent];
        }
    }
}

-(void)onProcessingProgress:(AliMediaDownloader *)downloader percentage:(int)percent {
    NSLog(@"onProcessingProgress:%d", percent);
}

-(void)onCompletion:(AliMediaDownloader *)downloader {
    AlivcLongVideoDownloadSource *source = [self findSourceFromDownloader:downloader];
    if (source) {
        self.downloadCount --;
        source.downloadStatus = DownloadTypefinish;
        source.downloader = nil;
        source.downloadTypeChangeCallBack = nil;
        [self startDownloadTask];
        if ([self.delegate respondsToSelector:@selector(downloadManagerOnCompletion:)]) {
            [self.delegate downloadManagerOnCompletion:source];
        }
    }
}

- (BOOL)allowDownload {
    return YES;
}


@end
