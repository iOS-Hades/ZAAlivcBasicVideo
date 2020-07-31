//
//  AlivcLongVideoBasicViewController.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/1.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcLongVideoTVModel.h"
#import "AlivcLongVideoDownloadSource.h"
#import "AlivcLongVideoDownLoadManager.h"
#import "AlivcLongVideoDownLoadProgressManager.h"
#import "MBProgressHUD+AlivcHelper.h"
NS_ASSUME_NONNULL_BEGIN

@interface AlivcLongVideoBasicViewController : UIViewController


@property (nonatomic, strong)AlivcLongVideoDownLoadManager * downLoadManager;
@property (nonatomic, assign) BOOL isLock; // 锁屏功能
@property (nonatomic, assign) BOOL isEnterBackground; // 进入后台
// 获取当前设备可用内存
- (double)availableMemory;

// 获取本地缓存的视频
- (NSArray *)localCachedVideo;

@end

NS_ASSUME_NONNULL_END
