//
//  AlyunVodTopView.h
//

#import <UIKit/UIKit.h>
#import "AliyunPrivateDefine.h"

@class AliyunPlayerViewTopView;
@protocol AliyunPVTopViewDelegate <NSObject>

/*
 * 功能 ： 点击返回按钮
 * 参数 ： topView 对象本身
 */
- (void)onBackViewClickWithAliyunPVTopView:(AliyunPlayerViewTopView*)topView;

/*
 * 功能 ： 点击下载按钮
 * 参数 ： topView 对象本身
 */
- (void)onDownloadButtonClickWithAliyunPVTopView:(AliyunPlayerViewTopView*)topView;

/*
 * 功能 ： 点击展示倍速播放界面按钮
 * 参数 ： 对象本身
 */
- (void)onSpeedViewClickedWithAliyunPVTopView:(AliyunPlayerViewTopView*)topView;

/*
 * 功能 ： 弹幕按钮
 * 参数 ： 对象本身
 */
- (void)danmuViewClickedWithAliyunPVTopView:(AliyunPlayerViewTopView*)topView;

/*
 * 功能 ： 跑马灯按钮
 * 参数 ： 对象本身
 */
- (void)loopViewClickedWithAliyunPVTopView:(AliyunPlayerViewTopView*)topView;

@end

@interface AliyunPlayerViewTopView : UIView

@property (nonatomic, strong) UIButton *downloadButton;     //下载视频
@property (nonatomic, weak  ) id<AliyunPVTopViewDelegate>delegate;
@property (nonatomic, assign) AliyunVodPlayerViewSkin skin;         //皮肤
@property (nonatomic, copy  ) NSString *topTitle;                   //标题

@property (nonatomic, strong) UIImageView *topBarBG;        //背景图片
@property (nonatomic, strong) UILabel *titleLabel;          //标题
@property (nonatomic, strong) UIButton *backButton;         //返回按钮
@property (nonatomic, strong) UIButton *speedButton;        //倍速播放界面展示按钮，更多按钮
@property (nonatomic, strong) UIButton *danmuButton;        //弹幕按钮
@property (nonatomic, strong) UIButton *loopViewButton;     //跑马灯按钮

@property (nonatomic ,assign) ALYPVPlayMethod playMethod; //播放方式

- (UIButton *)speedButton;

@end
