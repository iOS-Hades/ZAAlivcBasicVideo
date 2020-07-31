//
//  AlivcLongVideoCommonFunc.m
//  longVideo
//
//  Created by Aliyun on 2019/6/26.
//  Copyright © 2019 Aliyun. All rights reserved.
//

#import "AlivcLongVideoCommonFunc.h"
#import "NSString+AlivcHelper.h"
#import "AlivcLongVideoDownLoadManager.h"
#import <Photos/Photos.h>
#import "MBProgressHUD+AlivcHelper.h"

#define USER_UD_KEY  @"longVideo_current_user"

@implementation AlivcLongVideoCommonFunc


+ (NSArray *)getSettingTitleArray {
    return @[[@"视频同时下载个数" localString],[@"下载清晰度" localString],[@"运营商网络下载" localString],[@"运营商网络自动播放" localString],[@"启用硬解码" localString],[@"是否开启VIP" localString]];
}

+ (NSArray *)getSettingDetailsTitleArrayWithKey:(NSString *)key {
    NSArray *settingTitleArray = [self getSettingTitleArray];
    if ([key isEqualToString:settingTitleArray[0]]) {
        return @[@"1",@"2",@"3",@"4",@"5"];
    }
    if ([key isEqualToString:settingTitleArray[1]]) {
        return @[[@"标清" localString],[@"高清" localString],[@"超清" localString]];
    }
    return [NSArray array];
}

+ (NSString *)getUDSetWithIndex:(NSInteger)index {
    NSArray *settingTitleArray = [self getSettingTitleArray];
    if (index >= settingTitleArray.count) {
        return nil;
    }
    NSString *settingTitle = settingTitleArray[index];
    return [self getUDSetWithKey:settingTitle];
}

+ (NSString *)definitionWithChiStr:(NSString *)str{
    NSArray *definitionArray = @[[@"流畅" localString],[@"超清" localString],[@"标清" localString],[@"原画" localString],[@"高清" localString],[@"2K" localString],[@"4K" localString],[@"低音质" localString],[@"高音质" localString]];
    NSArray *array = @[@"FD",@"HD",@"LD",@"OD",@"SD",@"2K",@"4K",@"SQ",@"HQ"];
    NSInteger index = [definitionArray indexOfObject:str];
    NSString * nameStr = [array objectAtIndex:index] ;
    return nameStr;
}

+ (NSString *)definitionWithEngStr:(NSString *)str{
    NSArray *definitionArray = @[@"FD",@"HD",@"LD",@"OD",@"SD",@"2K",@"4K",@"SQ",@"HQ"];
    NSArray *array = @[[@"流畅" localString],[@"超清" localString],[@"标清" localString],[@"原画" localString],[@"高清" localString],[@"2K" localString],[@"4K" localString],[@"低音质" localString],[@"高音质" localString]];
    NSInteger index = [definitionArray indexOfObject:str];
    NSString * nameStr = [array objectAtIndex:index] ;
    return nameStr;
}

+ (NSString *)getUDSetWithKey:(NSString *)key {
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if (str.length == 0) {
        NSArray *settingTitleArray = [self getSettingTitleArray];
        if ([key isEqualToString:settingTitleArray[0]]) {
            return [self getSettingDetailsTitleArrayWithKey:key].lastObject;
        }else if ([key isEqualToString:settingTitleArray[1]]) {
            return [self getSettingDetailsTitleArrayWithKey:key].firstObject;
        }else if ([key isEqualToString:settingTitleArray[4]]) {
            return @"1";
        }
        return @"0";
    }
    return str;
}

+ (void)setUDWithKey:(NSString *)key vaule:(NSString *)value {
    if (value.length != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    if ([key isEqualToString:[self getSettingTitleArray].firstObject] && value) {
        [AlivcLongVideoDownLoadManager shareManager].maxDownloadCount = [value integerValue];
    }
}
+ (void)setDlNAStatus:(BOOL)isPlaying {
   
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isPlaying] forKey:@"DLNAStatus"];
    
}

+ (BOOL)getDLNAStatus {
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"DLNAStatus"] boolValue];
}

+ (void)saveImage:(UIImage *)image inView:(UIView *)view {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted) {
        [MBProgressHUD showMessage:NSLocalizedString(@"因为系统原因, 保存到相册失败", nil)  inView:view];
    } else if (status == PHAuthorizationStatusDenied) {
        [MBProgressHUD showMessage:NSLocalizedString(@"因为权限原因, 保存到相册失败", nil)  inView:view];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self saveImageHasAuthority:image inView:view];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self saveImageHasAuthority:image inView:view];
            }else {
                [MBProgressHUD showMessage:NSLocalizedString(@"因为权限原因, 保存到相册失败", nil)  inView:view];
            }
        }];
    }
}

+ (void)saveImageHasAuthority:(UIImage *)image inView:(UIView *)view {
    // PHAsset : 一个资源, 比如一张图片\一段视频
    // PHAssetCollection : 一个相簿
    // PHAsset的标识, 利用这个标识可以找到对应的PHAsset对象(图片对象)
    __block NSString *assetLocalIdentifier = nil;
    
    // 如果想对"相册"进行修改(增删改), 那么修改代码必须放在[PHPhotoLibrary sharedPhotoLibrary]的performChanges方法的block中
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 1.保存图片A到"相机胶卷"中
        // 创建图片的请求
        if (@available(iOS 9.0, *)) {
            assetLocalIdentifier = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success == NO) {
            [MBProgressHUD showMessage:NSLocalizedString(@"保存图片失败!", nil)  inView:view];
            return;
        }
        
        // 2.获得相簿
        PHAssetCollection *createdAssetCollection = [self createdAssetCollection];
        if (createdAssetCollection == nil) {
            [MBProgressHUD showMessage:NSLocalizedString(@"创建相簿失败!", nil)  inView:view];
            return;
        }
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            // 3.添加"相机胶卷"中的图片A到"相簿"D中
            
            // 获得图片
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalIdentifier] options:nil].lastObject;
            
            // 添加图片到相簿中的请求
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            
            // 添加图片到相簿
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success == NO) {
                [MBProgressHUD showMessage:NSLocalizedString(@"保存图片失败!", nil)  inView:view];
            } else {
                [MBProgressHUD showMessage:NSLocalizedString(@"保存图片成功!", nil)  inView:view];
            }
        }];
    }];
}

+ (PHAssetCollection *)createdAssetCollection {
    // 从已存在相簿中查找这个应用对应的相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        if ([assetCollection.localizedTitle isEqualToString:@"相机胶卷"]) {
            return assetCollection;
        }
    }
    
    // 没有找到对应的相簿, 得创建新的相簿
    
    // 错误信息
    NSError *error = nil;
    
    // PHAssetCollection的标识, 利用这个标识可以找到对应的PHAssetCollection对象(相簿对象)
    __block NSString *assetCollectionLocalIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 创建相簿的请求
        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"相机胶卷"].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    // 如果有错误信息
    if (error) return nil;
    
    // 获得刚才创建的相簿
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject;
}

@end
