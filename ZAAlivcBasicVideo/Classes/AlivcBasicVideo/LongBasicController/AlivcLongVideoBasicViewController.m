//
//  AlivcLongVideoBasicViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/1.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoBasicViewController.h"
#import<sys/sysctl.h>
#import<mach/mach.h>
#include <sys/param.h>
#include <sys/mount.h>

@interface AlivcLongVideoBasicViewController ()

@end

@implementation AlivcLongVideoBasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
}

- (AlivcLongVideoDownLoadManager *)downLoadManager {
    if (!_downLoadManager) {
        _downLoadManager = [AlivcLongVideoDownLoadManager shareManager];
        AlivcLongVideoDownLoadProgressManager * downLoadProgressManager = [AlivcLongVideoDownLoadProgressManager sharedInstance];
        _downLoadManager.delegate = downLoadProgressManager;
    }
    return _downLoadManager;
}


// 获取当前设备可用内存
- (double)availableMemory
{
        struct statfs buf;
        unsigned long long freeSpace = -1;
        if (statfs("/var", &buf) >= 0) {
            freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
        }
       
        return freeSpace/1024.0/1024.0/1024.0;
    
}

- (NSArray *)localCachedVideo {
    
    
    return nil;
}




@end
