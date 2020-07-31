//
//  AlivcLongVideoTVModel.h
//  longVideo
//
//  Created by Aliyun on 2019/6/25.
//  Copyright © 2019 Aliyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcPlayModel.h"


@protocol AlivcLongVideoTVModel;

@interface AlivcLongVideoTVModel : AlivcPlayModel

@property (nonatomic,strong)NSString *idStr;
@property (nonatomic,strong)NSString *tvId;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *descriptionStr;
@property (nonatomic,strong)NSString *coverUrl;
@property (nonatomic,strong)NSString *tvCoverUrl;
@property (nonatomic,strong)NSString *firstFrameUrl;
@property (nonatomic,strong)NSString *tags;
@property (nonatomic,strong)NSString *cateId;
@property (nonatomic,strong)NSString *cateName;
@property (nonatomic,strong)NSString *total;
@property (nonatomic,strong)NSString *creationTime;
@property (nonatomic,strong)NSString *isRelease;
@property (nonatomic,strong)NSString *isRecommend;
@property (nonatomic,strong)NSString *isHomePage;
@property (nonatomic,strong)NSString *videoId;
@property (nonatomic,strong)NSString *duration;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *size;
@property (nonatomic,strong)NSString *tvName;
@property (nonatomic,strong)NSArray *dotList;
@property (nonatomic,strong)NSString *sort;
@property (nonatomic,strong)NSString *transcodeStatus;
@property (nonatomic,strong)NSString *snapshotStatus;
@property (nonatomic,strong)NSString *censorStatus;
@property (nonatomic,strong)NSString *tryUrl;
@property (nonatomic,strong)NSString *isVip;

@property (nonatomic,assign)VideoAuthorityType authorityType;
//保存本地播放进度
@property (nonatomic,strong)NSString *watchProgress;

@end

