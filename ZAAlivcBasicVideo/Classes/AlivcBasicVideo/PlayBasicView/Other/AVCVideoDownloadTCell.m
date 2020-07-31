//
//  AVCVideoDownloadTCell.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/4/11.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AVCVideoDownloadTCell.h"
#import "AlivcUIConfig.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+AlivcHelper.h"
@interface AVCVideoDownloadTCell()


@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *besideToLeftConstraint;
@property (weak, nonatomic) IBOutlet UIButton *edutButton;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (strong, nonatomic) AlivcLongVideoDownloadSource *downloadVideo;

@end

@implementation AVCVideoDownloadTCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.coverImageView.layer.cornerRadius = 5;
    self.coverImageView.clipsToBounds = true;
    self.coverImageView.contentMode =  UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configWithLongVideoSource:(AlivcLongVideoDownloadSource *)downloadSource {
    
    self.downloadVideo = downloadSource;
    self.edutButton.selected = self.customSelected;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = downloadSource.longVideoModel.title;
    if (downloadSource.longVideoModel.coverUrl) {
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:downloadSource.longVideoModel.coverUrl]];
    }else if (downloadSource.longVideoModel.firstFrameUrl){
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:downloadSource.longVideoModel.coverUrl]];
    }
    
    if (downloadSource.downloadStatus == DownloadTypefinish) {
        self.statusImageView.hidden = true;
        self.downLoadProgressView.hidden = true;
       
        if (downloadSource.totalDataString) {
            self.statusLabel.text = downloadSource.totalDataString;
        }
        
        if (downloadSource.watched) {
             self.statusLabel.text = [@"已观看" localString];
        }else{
             self.statusLabel.text = [@"未观看" localString];
        }
       
        self.statusLabel.frame = CGRectMake(self.statusLabel.frame.origin.x, self.downLoadProgressView.frame.origin.y, self.statusLabel.frame.size.width, self.statusLabel.frame.size.height);
        self.totalDataLabel.text = downloadSource.totalDataString;
        self.totalDataLabel.hidden = NO;
        self.actionButton.hidden = true;
    }else{
        self.statusImageView.hidden = false;
        self.downLoadProgressView.hidden = false;
       
        if (downloadSource.statusString) {
            self.statusLabel.text = downloadSource.statusString;
        }
        self.actionButton.hidden = false;
        self.statusImageView.image = downloadSource.statusImage;
        self.totalDataLabel.hidden = YES;
       
    }
    
    if (downloadSource.longVideoModel.tvId && downloadSource.firstTvSource == YES && ![downloadSource.longVideoModel.tvId isEqualToString:@"(null)"]) {
        self.statusLabel.text = [NSString stringWithFormat:@"%ld%@ %ld%@",downloadSource.episodeNum,[@"个视频" localString],downloadSource.episodeAlreadyWatchNum,[@"个已观看" localString]];
        self.totalDataLabel.text  = downloadSource.episodeTotalDataString;
        self.titleLabel.text = downloadSource.longVideoModel.tvName;
        self.downLoadProgressView.hidden = YES;
        self.actionButton.hidden = YES;
        self.statusImageView.hidden = YES;
        if (downloadSource.longVideoModel.tvCoverUrl) {
            [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:downloadSource.longVideoModel.tvCoverUrl]];
        }
    }else {
        [self.downLoadProgressView setProgressTintColor:[UIColor colorWithRed:1.00f green:0.25f blue:0.06f alpha:1.00f]];
        [self.downLoadProgressView setProgress:downloadSource.percent /100.0];
        
    }
    if (downloadSource.downloadStatus == DownloadTypeLoading) {
        [self.maskView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        self.maskView.hidden = false;
    }else{
        self.maskView.hidden = true;
    }
    
    //progress  ;[AlivcUIConfig shared].kAVCThemeColor
   
    
    
    
}

- (void)refreshProgress:(CGFloat)progress{
    [self.downLoadProgressView setProgress:progress];
}

- (IBAction)editButtonTouched:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.customSelected = sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(longVideoDownTCell:video:selected:)]) {
         [self.delegate longVideoDownTCell:self video:self.downloadVideo selected:self.customSelected];
    }
    
}

- (void)setTOEditStyle:(BOOL)isEdit{
     self.edutButton.hidden = !isEdit;
    if (isEdit) {
        self.besideToLeftConstraint.constant = self.edutButton.frame.size.width;
    }else{
        self.besideToLeftConstraint.constant = 0;
    }
}

- (void)setSelectedCustom:(BOOL)selected{
    self.customSelected = selected;
    self.edutButton.selected = selected;
}
- (IBAction)actionButtonTouched:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(longVideoDownTCell:actionButtonTouchedWithVideo:)]) {
         [self.delegate longVideoDownTCell:self actionButtonTouchedWithVideo:self.downloadVideo];
    }
    
}

@end
