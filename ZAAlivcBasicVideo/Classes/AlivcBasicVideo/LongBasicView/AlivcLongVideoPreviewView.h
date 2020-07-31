//
//  AlivcLongVideoPreviewView.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/15.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AlivcLongVideoPreviewViewDelegate <NSObject>

- (void)alivcLongVideoPreviewViewReplay;
- (void)alivcLongVideoPreviewViewGoVipController;
- (void)alivcLongVideoPreviewViewGoBack;

@end


@interface AlivcLongVideoPreviewView : UIView

@property (nonatomic, weak) id <AlivcLongVideoPreviewViewDelegate> delegate;

/// 是否是VIP
@property (nonatomic, assign) BOOL isVip;
/// 试看视频长度
@property (nonatomic, assign) CGFloat previewTime;

@end

NS_ASSUME_NONNULL_END
