//
//  AlivcLongVideoDownLoadProgressManager.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/10.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcLongVideoDownloadSource.h"
#import "AlivcLongVideoDownLoadManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AlivcLongVideoDownLoadProgressManagerDelegate <NSObject>

@optional

- (void)alivcLongVideoDownLoadProgressManagerPrepared:(AlivcLongVideoDownloadSource *)source mediaInfo:(AVPMediaInfo *)mediaInfo;

- (void)alivcLongVideoDownLoadProgressManagerOnProgress:(AlivcLongVideoDownloadSource *)source percent:(int)percent;

- (void)alivcLongVideoDownLoadProgressManagerComplete:(AlivcLongVideoDownloadSource *)source;

- (void)alivcLongVideoDownLoadProgressManagerStateChanged:(AlivcLongVideoDownloadSource *)source;

- (void)alivcLongVideoDownLoadProgressErrorModel:(AVPErrorModel *)errorModel source:(AlivcLongVideoDownloadSource *)source;

@end


@interface AlivcLongVideoDownLoadProgressManager : NSObject <AlivcLongVideoDownLoadManagerDelegate>

@property (nonatomic, weak) id<AlivcLongVideoDownLoadProgressManagerDelegate>delegate;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
