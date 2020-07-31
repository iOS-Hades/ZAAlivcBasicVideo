//
//  AVC_VP_AdsViewController.h
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVC_VP_AdsViewController : UIViewController

@property (nonatomic, copy) NSString * urlLink;

@property (nonatomic, copy) void (^ goBackBlock)(void);

@end

NS_ASSUME_NONNULL_END
