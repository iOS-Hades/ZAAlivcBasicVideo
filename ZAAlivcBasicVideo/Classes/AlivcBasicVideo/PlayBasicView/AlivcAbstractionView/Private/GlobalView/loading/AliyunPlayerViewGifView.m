//
//  AliyunPVGifView.m
//

#import "AliyunPlayerViewGifView.h"

@interface AliyunPlayerViewGifView ()

@property (nonatomic,strong)UIActivityIndicatorView *loadingView;

@end

@implementation AliyunPlayerViewGifView

#pragma mark - public method

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc]initWithFrame:self.bounds];
        _loadingView.color = [UIColor whiteColor];
        _loadingView.hidden = YES;
        [self addSubview:_loadingView];
    }
    return _loadingView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _loadingView.frame = self.bounds;
}

/*
 * 功能 ：设定gif动画图片
 */
- (void)setGifImageWithName:(NSString *)name {}

/*
 * 功能 ：开始动画
 */
- (void)startAnimation {
    [self.loadingView startAnimating];
    self.loadingView.hidden = NO;
}

/*
 * 功能 ：停止动画
 */
- (void)stopAnimation {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
}

@end
