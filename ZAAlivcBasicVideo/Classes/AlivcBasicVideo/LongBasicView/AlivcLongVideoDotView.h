//
//  AlivcLongVideoDotView.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/27.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AlivcLongVideoDotViewDelegate <NSObject>

- (void)alivcLongVideoDotViewClickToseek:(NSTimeInterval)time;

@end


@interface AlivcLongVideoDotView : UIImageView


- (void)showViewWithTime:(NSTimeInterval) time;
- (NSInteger)checkIsTouchOntheDot:(NSTimeInterval)time inScope:(NSTimeInterval)scopeTime;

@property (nonatomic, weak)id <AlivcLongVideoDotViewDelegate> delegate;
@property (nonatomic, strong)NSArray * dotsArray;
@end

NS_ASSUME_NONNULL_END
