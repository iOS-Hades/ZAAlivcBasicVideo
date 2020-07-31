//
//  AlivcVideoPlayListModel.m
//  AliyunVideoClient_Entrance
//
//  Created by 王凯 on 2018/5/23.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcVideoPlayListModel.h"

@implementation AlivcVideoPlayListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:
  @{@"status":@"Status",
    @"duration":@"Duration",
    @"creationTime" : @"CreationTime",
    @"modifyTime" : @"ModifyTime",
    @"size" : @"Size",
    @"coverURL" : @"CoverURL",
    @"title" : @"Title",
    @"createTime" : @"CreateTime",
    @"videoId" : @"VideoId",
    @"snapshots" : @"Snapshots"
    }];
}

/**
 CoverURL": "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00005.jpg",
 "ModificationTime": "2018-10-16T09:42:38Z",
 "VideoId": "90080e220ff4402ea21075b100f6e31d",
 "ModifyTime": "2018-10-16T09:42:38Z",
 "Title": "阿里云又发明一项黑科技-8K医疗",
 "CreationTime": "2018-10-16T09:42:00Z",
 "Status": "Normal",
 "CateId": 872354889,
 "CateName": "趣视频解决方案推荐(不要删除)",
 "Duration": 136.6827,
 "CreateTime": "2018-10-16 17:42:00",
 "Snapshots": {
 "Snapshot": [
 "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00001.jpg",
 "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00002.jpg",
 "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00003.jpg",
 "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00004.jpg",
 "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00005.jpg",
 "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00006.jpg",
 "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00007.jpg",
 "https://vod-test2.cn-shanghai.aliyuncs.com/snapshot/90080e220ff4402ea21075b100f6e31d00008.jpg"
 ]
 },
 "StorageLocation": "out-20170320144514766-asatv1s154.oss-cn-shanghai.aliyuncs.com",
 "Size": 95837040

 @param dic 实例如上
 @return 实例
 */
- (instancetype)initWithCustomDic:(NSDictionary *)dic{
    if (self = [super init]) {
        _videoId = dic[@"VideoId"];
    }
    return self;
}

@end

