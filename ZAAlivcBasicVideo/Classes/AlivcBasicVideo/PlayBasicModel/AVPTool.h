//
//  AVPTool.h
//  AliPlayerDemo
//
//  Created by 郦立 on 2018/12/29.
//  Copyright © 2018年 com.alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AliyunPlayer/AliyunPlayer.h>

@interface AVPTool : NSObject

/**
 在指定view上显示hud

 @param text 文字
 @param view 目标view
 */
+ (void)hudWithText:(NSString *)text view:(UIView *)view;

/**
 在指定view上显示加载中

 @param view 目标view
 */
+ (void)loadingHudToView:(UIView *)view;

/**
 在指定view上隐藏加载中

 @param view 目标view
 */
+ (void)hideLoadingHudForView:(UIView *)view;

/**
 返回当前时间戳

 @return 当前时间戳
 */
+ (NSTimeInterval)currentTimeInterval;

@end






