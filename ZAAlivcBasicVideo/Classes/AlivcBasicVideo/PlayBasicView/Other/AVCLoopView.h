//
//  AVCLoopView.h
//  AVCLoopView
//
//  Created by Aliyun on 2019/3/9.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVCLoopView : UIView

/**
 *  跑马灯loop速度
 */
@property (nonatomic,assign) float Speed;

/**
 *  跑马灯loop一次的时间
 */
@property (nonatomic,assign) NSInteger countTime;

/**
 展示的label，用来设置样式等
 */
@property (nonatomic,strong)UILabel *tickerLabel;

/**
 *  显示的内容(支持多条数据)
 */
@property (nonatomic,strong) NSArray *tickerArrs;

/**
 *  设置背景颜色
 */
-(void)setBackColor:(UIColor *)color;

/**
 *  开启
 */
-(void)start;

@end



