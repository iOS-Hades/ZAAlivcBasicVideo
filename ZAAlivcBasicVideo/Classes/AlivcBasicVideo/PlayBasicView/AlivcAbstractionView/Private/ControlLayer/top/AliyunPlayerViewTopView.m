//
//  AlyunVodTopView.m
//

#import "AliyunPlayerViewTopView.h"

static const CGFloat ALYPVTopViewTitleLabelMargin = 8;  //标题 间隙
static const CGFloat ALYPVTopViewBackButtonWidth  = 40; //返回按钮宽度
static const CGFloat ALYPVTopViewDownLoadButtonWidth  = 30; //返回按钮宽度

@interface AliyunPlayerViewTopView()



@end
@implementation AliyunPlayerViewTopView

- (UIImageView *)topBarBG{
    if (!_topBarBG) {
        _topBarBG = [[UIImageView alloc] init];
    }
    return _topBarBG;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextColor:kALYPVColorTextNomal];
        [_titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    }
    return _titleLabel;
}

- (UIButton *)backButton{
    if (!_backButton){
        _backButton = [[UIButton alloc] init];
        UIImage *backImage = [AlivcImage imageInBasicVideoNamed:@"avcBackIcon"];
        [_backButton setImage:backImage forState:UIControlStateNormal];
        [_backButton setImage:backImage forState:UIControlStateSelected];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)speedButton{
    if (!_speedButton) {
        _speedButton = [[UIButton alloc] init];
        [_speedButton addTarget:self action:@selector(speedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speedButton;
}

- (UIButton *)danmuButton{
    if (!_danmuButton) {
        _danmuButton = [[UIButton alloc] init];
        [_danmuButton addTarget:self action:@selector(danmuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _danmuButton;
}

- (UIButton *)loopViewButton{
    if (!_loopViewButton) {
        _loopViewButton = [[UIButton alloc] init];
        [_loopViewButton addTarget:self action:@selector(loopViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loopViewButton;
}

- (UIButton *)downloadButton{
    if (!_downloadButton) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *downloadImage = [AlivcImage imageInBasicVideoNamed:@"avcDownload"];
//        _downloadButton.frame = CGRectMake(0, 0, downloadImage.size.width, downloadImage.size.height);
        [_downloadButton setBackgroundImage:downloadImage forState:UIControlStateNormal];
        [_downloadButton setBackgroundImage:downloadImage forState:UIControlStateSelected];
        [_downloadButton addTarget:self action:@selector(downloadButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        _downloadButton.center = CGPointMake(self.frame.size.width - 16 - self.downloadButton.frame.size.width / 2, 44);
    }
    return _downloadButton;
}

#pragma mark - init
- (instancetype)init{
   return  [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topBarBG];
        [self addSubview:self.titleLabel];
        [self addSubview:self.backButton];
        [self addSubview:self.downloadButton];
        [self addSubview:self.speedButton];
        [self addSubview:self.danmuButton];
        [self addSubview:self.loopViewButton];
    }
    return self;
}

- (void)setPlayMethod:(ALYPVPlayMethod)playMethod{
    _playMethod = playMethod;
    if (playMethod == ALYPVPlayMethodUrl) {
        self.downloadButton.hidden = true;
    }else{
        if (ScreenWidth < ScreenHeight) {
            self.downloadButton.hidden = false;
        }
    }
    if (self.playMethod == ALYPVPlayMethodLocal) {
        self.downloadButton.hidden = true;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    if ([AliyunUtil isInterfaceOrientationPortrait]) {
        //竖屏
        self.speedButton.hidden = true;
        self.danmuButton.hidden = true;
        self.loopViewButton.hidden = true;
        self.downloadButton.hidden = false;
    }else{
        //横屏
        self.speedButton.hidden = true;
        self.danmuButton.hidden = true;
        self.loopViewButton.hidden = true;
        self.downloadButton.hidden = false;
    }
    
    self.topBarBG.frame = self.bounds;
    
    self.backButton.frame = CGRectMake(ALYPVTopViewTitleLabelMargin, (height - ALYPVTopViewBackButtonWidth)/2.0, ALYPVTopViewBackButtonWidth, ALYPVTopViewBackButtonWidth);
    
    self.downloadButton.frame = CGRectMake(width-ALYPVTopViewTitleLabelMargin-ALYPVTopViewDownLoadButtonWidth, (height - ALYPVTopViewDownLoadButtonWidth)/2.0, ALYPVTopViewDownLoadButtonWidth, ALYPVTopViewDownLoadButtonWidth);
    
    self.speedButton.frame = CGRectMake(width-ALYPVTopViewTitleLabelMargin-50, (height - 40)/2.0, 50, 40);
    
    self.loopViewButton.frame = CGRectMake(width-ALYPVTopViewTitleLabelMargin*4-ALYPVTopViewDownLoadButtonWidth*2, (height - ALYPVTopViewDownLoadButtonWidth)/2.0, ALYPVTopViewDownLoadButtonWidth, ALYPVTopViewDownLoadButtonWidth);
    
    self.danmuButton.frame = CGRectMake(width-ALYPVTopViewTitleLabelMargin*7-ALYPVTopViewDownLoadButtonWidth*3, (height - ALYPVTopViewDownLoadButtonWidth)/2.0, ALYPVTopViewDownLoadButtonWidth, ALYPVTopViewDownLoadButtonWidth);
    
    CGFloat titleWidth = width - (ALYPVTopViewBackButtonWidth + 2*ALYPVTopViewTitleLabelMargin) - (ALYPVTopViewDownLoadButtonWidth+2*ALYPVTopViewTitleLabelMargin);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.backButton.frame)+ALYPVTopViewTitleLabelMargin, 0, titleWidth, height);
    
    if (self.playMethod == ALYPVPlayMethodLocal) {
        self.downloadButton.hidden = true;
    }
}

#pragma mark - 重写setter方法
- (void)setSkin:(AliyunVodPlayerViewSkin)skin{
    
    
    _skin = skin;
    [self.topBarBG setImage:[AliyunUtil imageWithNameInBundle:@"al_topbar_bg" skin:skin]];
//    [self.backButton setBackgroundImage:[AlivcImage imageInBasicVideoNamed:@"avcBackIcon"] forState:UIControlStateNormal];
//
////    [self.backButton setBackgroundImage:[AliyunUtil imageWithNameInBundle:@"avcBackIcon" skin:skin] forState:UIControlStateHighlighted];
    [self.speedButton setImage:[AliyunUtil imageWithNameInBundle:@"al_top_right" skin:skin] forState:UIControlStateNormal];
    [self.speedButton setImage:[AliyunUtil imageWithNameInBundle:@"al_top_right" skin:skin] forState:UIControlStateHighlighted];

   // [self.danmuButton setImage:[AliyunUtil imageWithNameInBundle:@"al_top_right" skin:skin] forState:UIControlStateNormal];
   // [self.loopViewButton setImage:[AliyunUtil imageWithNameInBundle:@"al_top_right" skin:skin] forState:UIControlStateNormal];
}

- (void)setTopTitle:(NSString *)topTitle{
    _topTitle = topTitle;
    self.titleLabel.text = topTitle;
}

#pragma mark - ButtonClicked
- (void)backButtonClicked:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBackViewClickWithAliyunPVTopView:)]) {
        [self.delegate onBackViewClickWithAliyunPVTopView:self];
    }
}

- (void)speedButtonClicked:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSpeedViewClickedWithAliyunPVTopView:)]) {
        [self.delegate onSpeedViewClickedWithAliyunPVTopView:self];
    }
}

- (void)danmuButtonClicked:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(danmuViewClickedWithAliyunPVTopView:)]) {
        [self.delegate danmuViewClickedWithAliyunPVTopView:self];
    }
}

- (void)loopViewButtonClicked:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(loopViewClickedWithAliyunPVTopView:)]) {
        [self.delegate loopViewClickedWithAliyunPVTopView:self];
    }
}

- (void)downloadButtonTouched:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDownloadButtonClickWithAliyunPVTopView:)]) {
        [self.delegate onDownloadButtonClickWithAliyunPVTopView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/




@end
