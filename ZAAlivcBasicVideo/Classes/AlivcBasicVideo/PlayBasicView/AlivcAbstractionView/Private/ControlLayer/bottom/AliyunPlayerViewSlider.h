//
//  AliyunVodSlider.h
//

#import <UIKit/UIKit.h>

@class AliyunPlayerViewSlider;
@protocol AliyunPlayerViewSliderDelegate <NSObject>

- (void)aliyunPlayerViewSlider:(AliyunPlayerViewSlider *)slider event:(UIControlEvents)event clickedSlider:(float)sliderValue;

@end
@interface AliyunPlayerViewSlider : UISlider
@property (nonatomic, weak) id<AliyunPlayerViewSliderDelegate>sliderDelegate;

@property (nonatomic, assign, readonly) CGFloat beginPressValue;// 手势刚开始的value

@property (nonatomic, assign) BOOL isSupportDot;// 是否支持打点

@end
