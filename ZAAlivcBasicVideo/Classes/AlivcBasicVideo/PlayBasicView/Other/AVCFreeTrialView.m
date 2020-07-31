//
//  AVCFreeTrialView.m
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/6.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AVCFreeTrialView.h"
#import "NSString+AlivcHelper.h"

@interface AVCFreeTrialView()

@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, assign) VideoFreeTrialType trialType;
@property (nonatomic, strong) UIView *superView;
@end

@implementation AVCFreeTrialView

- (instancetype)initWithFreeTime:(NSTimeInterval)freeTime freeTrialType:(VideoFreeTrialType)type inView:(UIView *)view{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handleDeviceOrientationDidChange:)
        name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [self addSubview:self.desLabel];
        NSInteger min = freeTime/60;
         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        if (type == FreeTrialStart) {
            _desLabel.text = [NSString stringWithFormat:@"%@%ld%@",[@"您只能试看" localString],(long)min,[@"分钟" localString]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               
                    [self removeFromSuperview];
                
            });
        }else if (type == FreeTrialEnd) {
           
            _desLabel.text = [@"对不起试看结束" localString];
        }
        
    }
    
    _superView = view;
    [view addSubview:self];
    return self;
}


- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textAlignment = NSTextAlignmentCenter;
        _desLabel.font = [UIFont systemFontOfSize:15];
        _desLabel.textColor = [UIColor whiteColor];
    }
    return _desLabel;
}


- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    [self setFrame];
}


- (void)setFrame {
    CGFloat width = _superView.bounds.size.width;
    CGFloat height = _superView.bounds.size.height;
    self.frame = CGRectMake((width -150)/2, height - 100, 150, 40);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setFrame];
     self.desLabel.frame = self.bounds;
    
}

@end
