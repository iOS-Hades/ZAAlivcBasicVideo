//
//  AlivcLongVideoSTSConfig.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/9.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoSTSConfig.h"
#import "AlivcPlayVideoRequestManager.h"

static AlivcLongVideoSTSConfig * stsConfig = nil;

@interface AlivcLongVideoSTSConfig ()

@property (nonatomic,strong)NSString *expiration;
@property (nonatomic, assign)NSTimeInterval setTime;

@end




@implementation AlivcLongVideoSTSConfig

@synthesize stsAccessKeyId =_stsAccessKeyId;
@synthesize stsAccessSecret =_stsAccessSecret;
@synthesize stsSecurityToken =_stsSecurityToken;

+(instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stsConfig = [[AlivcLongVideoSTSConfig alloc]init];
    });
    
    return stsConfig;
}

- (void)requestStsInfo:(FinishedRequestBlock)finishedRequestBlock {
    [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoSts success:^(AVPDemoResponseModel *responseObject) {
        self->_stsAccessKeyId = responseObject.data.accessKeyId;
        self->_stsAccessSecret = responseObject.data.accessKeySecret;
        self->_stsSecurityToken = responseObject.data.securityToken;
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        self->_setTime = [dat timeIntervalSince1970];
        finishedRequestBlock();
    } failure:nil];
}

- (NSString *)stsAccessKeyId {
    
  NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
  NSTimeInterval currentTime = [dat timeIntervalSince1970];
    if (_setTime == 0 || currentTime - _setTime >1000 * 60 *30 ) {
        return nil;
    }

    return _stsAccessKeyId;
}


- (NSString *)stsAccessSecret {
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval currentTime = [dat timeIntervalSince1970];
    if (_setTime == 0 || currentTime - _setTime >1000 * 60 *30 ) {
        return nil;
    }
    return _stsAccessSecret;
}

- (NSString *)stsSecurityToken {
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval currentTime = [dat timeIntervalSince1970];
    if (_setTime == 0 || currentTime - _setTime >1000 * 60 *30 ) {
        return nil;
    }
    return _stsSecurityToken;
}

@end
