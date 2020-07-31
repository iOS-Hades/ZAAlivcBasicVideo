//
//  AVCVideoDownloadTCell.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/4/11.
//  Copyright © 2018年 Alibaba. All rights reserved.
//  视频下载的cell

#import <UIKit/UIKit.h>
#import "AlivcLongVideoDownLoadManager.h"

@class AVCVideoDownloadTCell;
@protocol AVCVideoDownloadTCellDelegate <NSObject>

- (void)longVideoDownTCell:(AVCVideoDownloadTCell *)cell video:(AlivcLongVideoDownloadSource *)video selected:(BOOL)selected;

/**
 暂停和重新下载
 
 @param cell cell
 @param video video
 */
- (void)longVideoDownTCell:(AVCVideoDownloadTCell *)cell actionButtonTouchedWithVideo:(AlivcLongVideoDownloadSource *)video;




@end

@interface AVCVideoDownloadTCell : UITableViewCell

@property (weak, nonatomic) id <AVCVideoDownloadTCellDelegate> delegate;

@property (assign, nonatomic) BOOL customSelected; //选中状态

/**
 封面视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

/**
 状态视图
 */
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

/**
 标题label
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/**
 状态label
 */
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

/**
 下载总量label
 */
@property (weak, nonatomic) IBOutlet UILabel *totalDataLabel;


/**
 下载进度View
 */
@property (weak, nonatomic) IBOutlet UIProgressView *downLoadProgressView;


- (void)configWithLongVideoSource:(AlivcLongVideoDownloadSource *)downloadSource;

/**
 设置cell是否进入编辑模式

 @param isEdit 是否
 */
- (void)setTOEditStyle:(BOOL)isEdit;

/**
 编辑模式下的选中状态

 @param selected 选中状态
 */
- (void)setSelectedCustom:(BOOL)selected;

@end
