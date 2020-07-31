//
//  AlivcPlayVideoRequestManager.h
//  AlivcLongVideo
//
//  Created by ToT on 2020/1/20.
//

#import "AlivcBasicVideoRequestManager.h"
#import "AVPDemoResponseModel.h"

typedef void(^demoRequestSuccess)(AVPDemoResponseModel* responseObject);

typedef NS_ENUM(NSUInteger, AVPUrlType) {
    AVPUrlTypeRandomUser,
    AVPUrlTypeGetRecommendVideoList,
    AVPUrlTypePlayerVideoList,
    AVPUrlTypePlayerVideoPlayInfo,
    AVPUrlTypePlayerVideoSts,
    AVPUrlTypePlayerVideoMps,
    AVPUrlTypePlayerVideoPlayAuth,
    AVPUrlTypePlayerVideoLiveSts,
};

@interface AlivcPlayVideoRequestManager : AlivcBasicVideoRequestManager

/**
 开始get请求
 
 @param parameters 请求的parameters
 @param type AVPUrlType
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getWithParameters:(NSDictionary *)parameters urlType:(AVPUrlType)type success:(demoRequestSuccess)success failure:(requestFailure)failure;

/**
 开始post请求
 
 @param parameters 请求的parameters
 @param type AVPUrlType
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)postWithParameters:(NSDictionary *)parameters urlType:(AVPUrlType)type success:(demoRequestSuccess)success failure:(requestFailure)failure;

@end


