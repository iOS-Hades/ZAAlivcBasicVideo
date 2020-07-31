//
//  Created by ToT on 2019/12/4.
//  Copyright © 2019 aliyun. All rights reserved.
//

#import "AlivcVideoPlayPlayerConfig.h"

@implementation AlivcVideoPlayPlayerConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.config = [[AVPConfig alloc]init];
        self.config.enableSEI = YES;
        self.cacheConfig = [[AVPCacheConfig alloc]init];
        self.cacheConfig.maxDuration = 100;
        self.cacheConfig.maxSizeMB = 200;
    }
    return self;
}

- (BOOL)sourceHasPreview {
    switch (self.sourceType) {
        case SourceTypeSts:
            return [self.vidStsSource.playConfig containsString:@"PreviewTime"];
        case SourceTypeAuth:
            return [self.vidAuthSource.playConfig containsString:@"PreviewTime"];
        default:
            return NO;;
    }
}

+ (AVPUrlSource *)copyUrlSourceWithSource:(AVPUrlSource *)source {
    if (source) {
        AVPUrlSource *backSource = [[AVPUrlSource alloc]init];
        backSource.playerUrl = source.playerUrl;
        return backSource;
    }
    return [[AVPUrlSource alloc] urlWithString:@""];
}

+ (AVPVidStsSource *)copyStsSourceWithSource:(AVPVidStsSource *)source {
    return [[AVPVidStsSource alloc] initWithVid:source.vid accessKeyId:source.accessKeyId accessKeySecret:source.accessKeySecret securityToken:source.securityToken region:source.region playConfig:source.playConfig];
}

+ (AVPLiveStsSource *)copyLiveStsSourceWithSource:(AVPLiveStsSource *)source {
    return [[AVPLiveStsSource alloc] initWithUrl:source.url accessKeyId:source.accessKeyId accessKeySecret:source.accessKeySecret securityToken:source.securityToken region:source.region domain:source.domain app:source.app stream:source.stream];
}

+ (AVPVidMpsSource *)copyMpsSourceWithSource:(AVPVidMpsSource *)source {
    return [[AVPVidMpsSource alloc]initWithVid:source.vid accId:source.accId accSecret:source.accSecret stsToken:source.stsToken authInfo:source.authInfo region:source.region playDomain:source.playDomain mtsHlsUriToken:source.mtsHlsUriToken];
}

+ (AVPVidAuthSource *)copyAuthSourceWithSource:(AVPVidAuthSource *)source {
    return [[AVPVidAuthSource alloc] initWithVid:source.vid playAuth:source.playAuth region:source.region playConfig:source.playConfig];
}

+ (AVPConfig *)copyConfigWithConfig:(AVPConfig *)config {
    AVPConfig *backConfig = [[AVPConfig alloc]init];
    backConfig.maxDelayTime = config.maxDelayTime;
    backConfig.highBufferDuration = config.highBufferDuration;
    backConfig.startBufferDuration = config.startBufferDuration;
    backConfig.maxBufferDuration = config.maxBufferDuration;
    backConfig.networkTimeout = config.networkTimeout;
    backConfig.networkRetryCount = config.networkRetryCount;
    backConfig.maxProbeSize = config.maxProbeSize;
    backConfig.referer = config.referer;
    backConfig.userAgent = config.userAgent;
    backConfig.httpProxy = config.httpProxy;
    backConfig.clearShowWhenStop = config.clearShowWhenStop;
    backConfig.enableSEI = config.enableSEI;
    return backConfig;
}

+ (AVPCacheConfig *)copyCacheConfigWithConfig:(AVPCacheConfig *)cacheConfig {
    AVPCacheConfig *backConfig = [[AVPCacheConfig alloc]init];
    backConfig.maxDuration = cacheConfig.maxDuration;
    backConfig.maxSizeMB = cacheConfig.maxSizeMB;
    backConfig.enable = cacheConfig.enable;
    return backConfig;
}

@end
