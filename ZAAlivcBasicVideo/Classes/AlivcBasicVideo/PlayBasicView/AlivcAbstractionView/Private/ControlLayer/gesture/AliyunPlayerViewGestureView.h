
#import <UIKit/UIKit.h>
#import "AliyunPrivateDefine.h"

@class AliyunPlayerViewGestureView;
@protocol AliyunPVGestureViewDelegate <NSObject>

//单击屏幕
- (void)onSingleClickedWithAliyunPVGestureView:(AliyunPlayerViewGestureView *)gestureView;

//双击屏幕
- (void)onDoubleClickedWithAliyunPVGestureView:(AliyunPlayerViewGestureView *)gestureView;

//手势水平移动偏移量
- (void)horizontalOrientationMoveOffset:(float)moveOffset;

//手势开始
- (void)UIGestureRecognizerStateBeganWithAliyunPVGestureView:(AliyunPlayerViewGestureView *)gestureView;

//水平手势结束
- (void)UIGestureRecognizerStateHorizontalEndedWithAliyunPVGestureView:(AliyunPlayerViewGestureView *)gestureView;

@end

@interface AliyunPlayerViewGestureView : UIView
@property (nonatomic, weak) id<AliyunPVGestureViewDelegate>delegate;

/*
 * 功能 ： 是否禁用手势滑动
 */
- (void)setEnableGesture:(BOOL)enableGesture;

/*
 * 功能 ： 传递
 */
- (void)setSeekTime:(NSTimeInterval)time direction:(UISwipeGestureRecognizerDirection)direction;

/*
 * 功能 ： 是否禁用垂直手势滑动，锁屏时禁用
 */
- (void)setIsLock:(BOOL)lock;


@end
