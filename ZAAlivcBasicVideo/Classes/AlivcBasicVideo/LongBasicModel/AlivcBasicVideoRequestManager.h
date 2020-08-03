//
//  AlivcBasicVideoRequestManager.h
//  AlivcLongVideo
//
//  Created by ToT on 2020/1/20.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void(^requestSuccess)(id responseObject);
typedef void(^requestFailure)(NSString *errorMsg);

@interface AlivcBasicVideoRequestManager : NSObject

/**
 开始请求
 
 @param isGet 是否是get请求
 @param parameters 请求的parameters
 @param requestUrl 请求的URL
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)startRequestTypeIsGet:(BOOL)isGet parameters:(NSDictionary *)parameters requestUrl:(NSString *)requestUrl success:(requestSuccess)success failure:(requestFailure)failure;

@end


