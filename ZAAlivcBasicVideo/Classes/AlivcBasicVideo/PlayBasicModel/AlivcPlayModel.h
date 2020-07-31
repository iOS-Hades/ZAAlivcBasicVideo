//
//  AlivcPlayModel.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/16.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    AlivcPlayVideoNoneAdsType = 1,
    AlivcPlayVideoImageAdsType ,
    AlivcPlayVideoVideoAdsType,
    AlivcPlayVideoFreeTrialType,
} VideoAuthorityType;


@interface AlivcPlayModel : JSONModel

@property (nonatomic, assign) BOOL waterMark; // 水印

@end

NS_ASSUME_NONNULL_END
