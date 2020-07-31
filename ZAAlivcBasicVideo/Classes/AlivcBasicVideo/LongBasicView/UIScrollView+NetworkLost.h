//
//  UIScrollView+NetworkLost.h
//  longVideo
//
//  Created by Aliyun on 2019/7/18.
//  Copyright © 2019 Aliyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^retryCallBack)(void);

@interface UIScrollView (NetworkLost)

- (void)showNetworkLostView;

- (void)dismissNetworkLostView;

- (void)networkLostRetryCallBack:(retryCallBack)callBack;

- (void)showMiddleLabelWithTitle:(NSString *)title;

- (void)dismissMiddleLabel;

@end

