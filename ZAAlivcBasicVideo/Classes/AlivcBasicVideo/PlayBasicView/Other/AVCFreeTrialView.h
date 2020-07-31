//
//  AVCFreeTrialView.h
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/6.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    FreeTrialStart, //开始试看
    FreeTrialEnd, // 结束试看
} VideoFreeTrialType;

@interface AVCFreeTrialView : UIView

/**
 初始化函数
 @param freeTime 试看时间，单位秒
 @param type 试看view类型
 @param view 试看提示的父view
 @return 试看提示图片
 */
- (instancetype)initWithFreeTime:(NSTimeInterval)freeTime freeTrialType:(VideoFreeTrialType)type inView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
