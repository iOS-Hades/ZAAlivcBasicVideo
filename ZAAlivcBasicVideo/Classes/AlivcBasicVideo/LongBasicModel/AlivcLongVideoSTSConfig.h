//
//  AlivcLongVideoSTSConfig.h
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/9.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FinishedRequestBlock)(void);

@interface AlivcLongVideoSTSConfig : NSObject


@property (nonatomic, copy, readonly) NSString * stsAccessKeyId;
@property (nonatomic, copy,readonly) NSString * stsAccessSecret;
@property (nonatomic, copy,readonly) NSString * stsSecurityToken;


+(instancetype)sharedInstance;
- (void)requestStsInfo:(FinishedRequestBlock)finishedRequestBlock;

@end

NS_ASSUME_NONNULL_END
