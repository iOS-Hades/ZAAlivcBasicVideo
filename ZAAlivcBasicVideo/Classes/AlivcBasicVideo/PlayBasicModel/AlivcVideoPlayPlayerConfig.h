//
//  Created by ToT on 2019/12/4.
//  Copyright © 2019 aliyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunPlayer/AliyunPlayer.h>

typedef NS_ENUM(NSInteger, SourceType) {
    SourceTypeNull,
    SourceTypeUrl,
    SourceTypeSts,
    SourceTypeMps,
    SourceTypeAuth,
    SourceTypeLiveSts
};

@interface AlivcVideoPlayPlayerConfig : NSObject

@property (nonatomic,assign)SourceType sourceType;
@property (nonatomic,strong)AVPUrlSource *urlSource;
@property (nonatomic,strong)AVPVidStsSource *vidStsSource;
@property (nonatomic,strong)AVPLiveStsSource *liveStsSource;
@property (nonatomic,strong)AVPVidMpsSource *vidMpsSource;
@property (nonatomic,strong)AVPVidAuthSource *vidAuthSource;
@property (nonatomic,strong)AVPConfig *config;
@property (nonatomic,strong)AVPCacheConfig *cacheConfig;
@property (nonatomic,assign)BOOL enableHardwareDecoder;
@property (nonatomic,assign)AVPMirrorMode mirrorMode;
@property (nonatomic,assign)AVPRotateMode rotateMode;
@property (nonatomic,assign)AVPScalingMode scalingMode;
@property (nonatomic,assign)BOOL autoVideo;
@property (nonatomic,assign,readonly)BOOL sourceHasPreview;
@property (nonatomic,assign)BOOL accurateSeek;
@property (nonatomic,assign)BOOL backPlay;

@property(nonatomic,assign) NSTimeInterval liveStsExpireTime;

+ (AVPUrlSource *)copyUrlSourceWithSource:(AVPUrlSource *)source;
+ (AVPVidStsSource *)copyStsSourceWithSource:(AVPVidStsSource *)source;
+ (AVPLiveStsSource *)copyLiveStsSourceWithSource:(AVPLiveStsSource *)source;
+ (AVPVidMpsSource *)copyMpsSourceWithSource:(AVPVidMpsSource *)source;
+ (AVPVidAuthSource *)copyAuthSourceWithSource:(AVPVidAuthSource *)source;
+ (AVPConfig *)copyConfigWithConfig:(AVPConfig *)config;
+ (AVPCacheConfig *)copyCacheConfigWithConfig:(AVPCacheConfig *)cacheConfig;

@end


