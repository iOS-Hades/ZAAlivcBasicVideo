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
        // 初始值 https://api.mapgin.com/mapgin_app/alisdk/aliyunVideo/getVideoPlayAuth
        _BASE_URL = @"https://api.mapgin.com";
    }
    return _BASE_URL;
}

- (NSString *)URL_PATH {
    if (!_URL_PATH) {
        _URL_PATH = @"/mapgin_app/alisdk";
    }
    return _URL_PATH;
}

+ (NSString *)getUrlFromType:(AVPUrlType)type {
    AlivcPlayVideoRequestManager *m = [self shared];
    NSString *url = [NSString stringWithFormat:@"%@%@",m.BASE_URL,m.URL_PATH];
    switch (type) {
        case AVPUrlTypePlayerVideoSts:
            return [url stringByAppendingString:@"/aliyunVideo/getVideoSts"];
        case AVPUrlTypePlayerVideoList:
            return [url stringByAppendingString:@"/demo/getVideoList?cateId=1000025282"];
        case AVPUrlTypePlayerVideoPlayInfo:
            return [url stringByAppendingString:@"/aliyunVideo/getVideoPlayInfo"];
        case AVPUrlTypePlayerVideoMps:
            return [url stringByAppendingString:@"/aliyunVideo/getVideoMps"];
        case AVPUrlTypePlayerVideoPlayAuth:
            return [url stringByAppendingString:@"/aliyunVideo/getVideoPlayAuth"];
        case AVPUrlTypeRandomUser:
            return [url stringByAppendingString:@"/user/randomUser"];
        case AVPUrlTypeGetRecommendVideoList:
            return [url stringByAppendingString:@"/vod/getRecommendVideoList"];
        case AVPUrlTypePlayerVideoLiveSts:
            return [url stringByAppendingString:@"/aliyunVideo/getLiveEncryptSts"];
        default:
            return url;
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
