//
//  AVPDemoResponseModel.h
//  AliPlayerDemo
//
//  Created by 郦立 on 2019/1/15.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@class AVPDemoResponseDataModel;
@class AVPDemoResponseVideoListModel;
@class AVPPlayInfoModel;
@class AVPVideoMetaModel;
@class AVPAkInfoModel;
@protocol AVPDemoResponseVideoListModel;
@protocol AVPPlayInfoModel;

@interface AVPDemoResponseModel : JSONModel

@property (nonatomic,strong)NSString *code;
@property (nonatomic,strong)AVPDemoResponseDataModel *data;
@property (nonatomic,strong)NSString *message;
@property (nonatomic,strong)NSString *requestId;
@property (nonatomic,assign)BOOL result;

@end





@interface AVPDemoResponseDataModel : JSONModel

//sts相关
@property (nonatomic,strong)NSString *videoId;
@property (nonatomic,strong)NSString *accessKeyId;
@property (nonatomic,strong)NSString *accessKeySecret;
@property (nonatomic,strong)NSString *securityToken;
@property (nonatomic,strong)NSString *expiration;
//user相关
@property (nonatomic,strong)NSString *token;
//list相关
@property (nonatomic,strong)NSString *total;
@property (nonatomic,strong)NSArray <AVPDemoResponseVideoListModel *><AVPDemoResponseVideoListModel>*videoList;
//playAuth相关
@property (nonatomic,strong)NSString *playAuth;
//PlayInfo相关
@property (nonatomic,strong)NSArray <AVPPlayInfoModel *><AVPPlayInfoModel>*playInfoList;
//videoMeta相关
@property (nonatomic,strong)AVPVideoMetaModel *videoMeta;
//mps相关
@property (nonatomic,strong)NSString *RegionId;
@property (nonatomic,strong)NSString *MediaId;
@property (nonatomic,strong)NSString *HlsUriToken;
@property (nonatomic,strong)NSString *authInfo;
@property (nonatomic,strong)AVPAkInfoModel *AkInfo;

@end





@interface AVPDemoResponseVideoListModel : JSONModel

@property (nonatomic,strong)NSString *coverUrl;
@property (nonatomic,strong)NSString *firstFrameUrl;
@property (nonatomic,strong)NSString *videoId;
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,assign)NSInteger page;
@property (nonatomic,strong)NSUUID *uuid;
@property (nonatomic,strong)NSString *fileUrl;
@property (nonatomic,strong)NSString *descriptionStr;
@property (nonatomic,strong)NSString *title;

@end





@interface AVPPlayInfoModel : JSONModel

@property (nonatomic,strong)NSString *playURL;

@end





@interface AVPVideoMetaModel : JSONModel

@property (nonatomic,strong)NSString *videoId;

@end





@interface AVPAkInfoModel : JSONModel

@property (nonatomic,strong)NSString *AccessKeyId;
@property (nonatomic,strong)NSString *AccessKeySecret;
@property (nonatomic,strong)NSString *SecurityToken;

@end

