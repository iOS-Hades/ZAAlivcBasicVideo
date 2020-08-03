//
//  AlivcPlayVideoRequestManager.m
//  AlivcLongVideo
//
//  Created by ToT on 2020/1/20.
//

#import "AlivcPlayVideoRequestManager.h"

//#define  BASE_URL            @"https://alivc-demo.aliyuncs.com"
//#define  BASE_URL            @"https://outin-196bd434049011ea91c600163e024c6a.oss-cn-shanghai.aliyuncs.com"

@implementation AlivcPlayVideoRequestManager

+ (AlivcPlayVideoRequestManager *)shared {
    static AlivcPlayVideoRequestManager *request = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[AlivcPlayVideoRequestManager alloc] init];
    });
    return request;
}

- (NSString *)BASE_URL {
    if (!_BASE_URL) {
        // 初始值
        _BASE_URL = @"https://alivc-demo.aliyuncs.com";
    }
    return _BASE_URL;
}

+ (NSString *)getUrlFromType:(AVPUrlType)type {
    AlivcPlayVideoRequestManager *m = [self shared];
    switch (type) {
        case AVPUrlTypePlayerVideoSts:
            return [m.BASE_URL stringByAppendingString:@"/player/getVideoSts"];
        case AVPUrlTypePlayerVideoList:
            return [m.BASE_URL stringByAppendingString:@"/demo/getVideoList?cateId=1000025282"];
        case AVPUrlTypePlayerVideoPlayInfo:
            return [m.BASE_URL stringByAppendingString:@"/player/getVideoPlayInfo"];
        case AVPUrlTypePlayerVideoMps:
            return [m.BASE_URL stringByAppendingString:@"/player/getVideoMps"];
        case AVPUrlTypePlayerVideoPlayAuth:
            return [m.BASE_URL stringByAppendingString:@"/player/getVideoPlayAuth"];
        case AVPUrlTypeRandomUser:
            return [m.BASE_URL stringByAppendingString:@"/user/randomUser"];
        case AVPUrlTypeGetRecommendVideoList:
            return [m.BASE_URL stringByAppendingString:@"/vod/getRecommendVideoList"];
        case AVPUrlTypePlayerVideoLiveSts:
            return [m.BASE_URL stringByAppendingString:@"/player/getLiveEncryptSts"];
        default:
            return m.BASE_URL;
    }
}

+ (void)getWithParameters:(NSDictionary *)parameters urlType:(AVPUrlType)type success:(demoRequestSuccess)success failure:(requestFailure)failure {
    [self startRequestTypeIsGet:YES parameters:parameters urlType:type success:success failure:failure];
}

+ (void)postWithParameters:(NSDictionary *)parameters urlType:(AVPUrlType)type success:(demoRequestSuccess)success failure:(requestFailure)failure {
    [self startRequestTypeIsGet:NO parameters:parameters urlType:type success:success failure:failure];
}

+ (void)startRequestTypeIsGet:(BOOL)isGet parameters:(NSDictionary *)parameters urlType:(AVPUrlType)type success:(demoRequestSuccess)success failure:(requestFailure)failure {
    NSString *requestUrl = [self getUrlFromType:type];
    [self startRequestTypeIsGet:isGet parameters:parameters requestUrl:requestUrl success:^(id responseObject) {
        AVPDemoResponseModel *model = [[AVPDemoResponseModel alloc] initWithDictionary:responseObject error:nil];
        if (model.result) {
            if (success) success(model);
        }else {
            if (failure) failure(model.message);
        }
    } failure:failure];
}

@end
