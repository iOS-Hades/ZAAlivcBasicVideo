//
//  AlivcLongVideoYourFavoritCell.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/8.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoYourFavoritCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface AlivcLongVideoYourFavoritCell()

@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end


@implementation AlivcLongVideoYourFavoritCell


- (instancetype)init {
    if (self = [super init]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.videoImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subtitleLabel];
    }
    return self;
}
- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc]init];
        _videoImageView.contentMode =  UIViewContentModeScaleAspectFill;
        _videoImageView.clipsToBounds = YES;
    
    }
    return _videoImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.textColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1/1.0];
        _subtitleLabel.font = [UIFont systemFontOfSize:14];
    }
    
    return _subtitleLabel;
}

- (void)configWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageUrl:(NSString *)imageUrl {
    
  
    self.titleLabel.text = title;
    self.subtitleLabel.text = subtitle;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[AlivcImage imageInBasicVideoNamed:@"AppIcon"]];
   

    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.videoImageView.frame = CGRectMake(15, 10, 120, 80);
    self.videoImageView.layer.masksToBounds = YES;
    self.videoImageView.layer.cornerRadius = 10;
    self.titleLabel.frame = CGRectMake(140, 20, ScreenWidth - 160, 30);
    self.subtitleLabel.frame = CGRectMake(140, 50, ScreenWidth - 160, 20);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
