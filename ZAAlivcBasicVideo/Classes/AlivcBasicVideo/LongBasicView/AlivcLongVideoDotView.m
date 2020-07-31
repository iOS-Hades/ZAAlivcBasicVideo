//
//  AlivcLongVideoDotView.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/27.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoDotView.h"
#import "NSString+AlivcHelper.h"

@interface AlivcLongVideoDotView ()

@property (nonatomic, strong)UILabel * plotDesLabel;
@property (nonatomic, strong)UIButton * seekButton;
@property (nonatomic, assign) NSTimeInterval dotTime;
@property (nonatomic, strong)NSArray * dotsTimeArray;

@end


@implementation AlivcLongVideoDotView

- (instancetype)init{
    if (self = [super init]) {
        
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@""];
       // self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
       // [self addSubview:self.plotDesLabel];
        [self addSubview:self.seekButton];
        
    }
   
    return self;
}
- (void)setDotsArray:(NSArray *)dotsArray {
    _dotsArray = dotsArray;
    
    NSMutableArray *timeArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in self.dotsArray) {
        NSNumber *time = @([[dic objectForKey:@"time"]integerValue]);
        [timeArray addObject:time];
    }
     _dotsTimeArray = timeArray;
    
}

- (void)showViewWithTime:(NSTimeInterval) time {
    
    for (NSDictionary *dic in self.dotsArray) {
        if ([[dic objectForKey:@"time"]integerValue] == time/1000) {
            NSString * text = [dic objectForKey:@"content"];
            CGRect originFrame = self.frame;
            CGSize size = [text boundingRectWithSize:CGSizeMake(300, 30) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.f]} context:nil].size;
        
            self.frame = CGRectMake(originFrame.origin.x - size.width/2 - 5, 280, size.width +10, 30);
            [self.seekButton setTitle:text forState:UIControlStateNormal];
            
        }
    }
    _dotTime = time;
    
}

- (UILabel *)plotDesLabel {
    if (!_plotDesLabel) {
        _plotDesLabel = [[UILabel alloc]init];
        _plotDesLabel.font  = [UIFont systemFontOfSize:15];
        _plotDesLabel.text = @"～～～";
        _plotDesLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _plotDesLabel;
}

- (UIButton *)seekButton {
    
    if (!_seekButton) {
        _seekButton = [[UIButton alloc]init];
       // [_seekButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
         _seekButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [_seekButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _seekButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_seekButton addTarget:self action:@selector(seekToDot) forControlEvents:UIControlEventTouchUpInside];
         _seekButton.titleLabel.font = [UIFont systemFontOfSize:12];
        
    }
    return _seekButton;
}

- (void)seekToDot {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoDotViewClickToseek:)]) {
        [self.delegate alivcLongVideoDotViewClickToseek:_dotTime];
    }
    
}

- (NSInteger)checkIsTouchOntheDot:(NSTimeInterval)time inScope:(NSTimeInterval)scopeTime {
    
    for (NSNumber * dotTime in self.dotsTimeArray) {

        if (fabs([dotTime integerValue]*1000 - time)<scopeTime) {
            return [dotTime integerValue] *1000;
        }

    }
    return 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGFloat width = self.frame.size.width;
//    CGFloat height = self.frame.size.height;
    //self.plotDesLabel.frame = CGRectMake(0, 0, width - 40, height);
    self.seekButton.frame = self.bounds;
    self.seekButton.layer.masksToBounds = YES;
    self.seekButton.layer.cornerRadius = 3;
    
    
}

@end
