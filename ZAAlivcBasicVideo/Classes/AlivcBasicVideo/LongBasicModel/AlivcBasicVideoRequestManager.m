//
//  AlivcBasicVideoRequestManager.m
//  AlivcLongVideo
//
//  Created by ToT on 2020/1/20.
//

#import "AlivcBasicVideoRequestManager.h"
#import <AFNetworking/AFNetworking.h>
#import "NSString+AlivcHelper.h"

#define  TIME_OUT     10 //请求超时时间

@implementation AlivcBasicVideoRequestManager

static AFHTTPSessionManager *sessionManager = nil;

+ (AFHTTPSessionManager *)defaultSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [AFHTTPSessionManager manager];
        sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        sessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        sessionManager.requestSerializer.timeoutInterval = TIME_OUT;
        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html",@"application/json",nil];
    });
    return sessionManager;
}

+ (void)startRequestTypeIsGet:(BOOL)isGet parameters:(NSDictionary *)parameters requestUrl:(NSString *)requestUrl success:(requestSuccess)success failure:(requestFailure)failure {
    AFHTTPSessionManager *manager = [self defaultSessionManager];
    NSLog(@"----- 开始请求 ----- url:%@ ----- 参数:%@",requestUrl,parameters);
    if (isGet) {
        [manager GET:requestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"----- request responseObject ----- %@",responseObject);
            if (success) success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleError:error failure:failure];
        }];
    }else {
        [manager POST:requestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"----- request responseObject ----- %@",responseObject);
            if (success) success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleError:error failure:failure];
        }];
    }
}

+ (void)handleError:(NSError *)error failure:(requestFailure)failure {
    NSLog(@"----- request error ----- %@",error);
    if (failure) {
        NSString *errorMsg = [@"未知错误" localString];
        switch (error.code) {
            case -1000: case -1002:
                errorMsg = [@"非法url" localString];
                break;
            case -1001: case -2000:
                errorMsg = [@"连接超时，请稍后重试" localString];
                break;
            case -1003: case -1004:
                errorMsg = [@"请检查服务器配置" localString];
                break;
            case -1005:
                errorMsg = [@"失去连接，请重试" localString];
                break;
            case -1006:
                errorMsg = [@"DNS查找失败" localString];
                break;
            case -1007:
                errorMsg = [@"HTTP重定向过多" localString];
                break;
            case -1008: case -1011:
                errorMsg = [@"服务器错误" localString];
                break;
            case -1009:
                errorMsg = [@"网络未连接，请检查网络" localString];
                break;
            case -1015: case -1016: case -1201:
                errorMsg = [@"服务器返回异常" localString];
                break;
            default:
                errorMsg = [@"未知错误" localString];
                break;
        }
        failure(errorMsg);
    }
}

@end
