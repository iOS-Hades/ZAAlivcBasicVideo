//
//  AlivcLongVideoDownLoadProgressManager.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/10.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoDownLoadProgressManager.h"

@interface AlivcLongVideoDownLoadProgressManager()

@end

static AlivcLongVideoDownLoadProgressManager *downLoadProgressManager = nil;

@implementation AlivcLongVideoDownLoadProgressManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downLoadProgressManager = [[AlivcLongVideoDownLoadProgressManager alloc]init];
    });
    return downLoadProgressManager;
}

#pragma mark downLoadDelegate

- (void)downloadManagerOnPrepared:(AlivcLongVideoDownloadSource *)source mediaInfo:(AVPMediaInfo *)info {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoDownLoadProgressManagerPrepared:mediaInfo:)]) {
        [self.delegate alivcLongVideoDownLoadProgressManagerPrepared:source mediaInfo:info];
    }
}




- (void)downloadManagerOnError:(AlivcLongVideoDownloadSource *)source errorModel:(AVPErrorModel *)errorModel {
    
    source.downloadStatus = LongVideoDownloadTypeFailed;
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoDownLoadProgressErrorModel:source:)]) {
        [self.delegate alivcLongVideoDownLoadProgressErrorModel:errorModel source:source];
    }
}


- (void)downloadManagerOnProgress:(AlivcLongVideoDownloadSource *)source percentage:(int)percent {
    NSLog(@"~~~~~~~~~~%d",percent);

    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoDownLoadProgressManagerOnProgress:percent:)] ) {
        [self.delegate alivcLongVideoDownLoadProgressManagerOnProgress:source percent:percent];
    }
    
}


- (void)downloadManagerOnCompletion:(AlivcLongVideoDownloadSource *)source {
    
    if (source) {
        //改变状态更新进本地数据库，更新tableView
        source.downloadStatus = LongVideoDownloadTypefinish;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoDownLoadProgressManagerComplete:)]) {
        [self.delegate alivcLongVideoDownLoadProgressManagerComplete:source];
    }
    
    
}

- (void)onSourceStateChanged:(AlivcLongVideoDownloadSource *)source {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoDownLoadProgressManagerStateChanged:)]) {
        [self.delegate alivcLongVideoDownLoadProgressManagerStateChanged:source];
    }
    
}








@end


