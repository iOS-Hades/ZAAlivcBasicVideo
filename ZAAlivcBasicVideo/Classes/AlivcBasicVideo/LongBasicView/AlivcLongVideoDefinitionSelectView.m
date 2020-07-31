//
//  AlivcLongVideoDefinitionSelectView.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/28.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoDefinitionSelectView.h"
#import "AlivcLongVideoCommonFunc.h"
#import "NSString+AlivcHelper.h"
#define TrackButtonBeginTag 10

@interface AlivcLongVideoDefinitionSelectView()

@property (nonatomic, strong) UIView *bgView;


@end


@implementation AlivcLongVideoDefinitionSelectView


- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self addSubview:self.bgView];
       
       
        
    }
    return self;
}

- (UIView *)bgView {
    
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1/1.0];
    }
    return _bgView;
}

- (void)setTrackInfoArray:(NSArray<AVPTrackInfo *> *)trackInfoArray{
    _trackInfoArray = trackInfoArray;
     [self addTrackButton];
}

- (void)addTrackButton {
    
    for (UIView *subview in self.bgView.subviews) {
        [subview removeFromSuperview];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    NSString *definiton = [AlivcLongVideoCommonFunc getUDSetWithIndex:1];
    NSString *eDefinition = [AlivcLongVideoCommonFunc definitionWithChiStr:definiton];
// 取消默认清晰度排在第一位
//    for (int  i =0; i< self.trackInfoArray.count; ++i){
//        AVPTrackInfo *info = [self.trackInfoArray objectAtIndex:i];
//        if ([info.trackDefinition isEqualToString:eDefinition]) {
//            [array exchangeObjectAtIndex:i withObjectAtIndex:0];
//
//        }
//    }
    
    // 排序
    
   
    NSArray *sortRuleArray = @[@"SQ",@"HQ",@"FD",@"LD",@"SD",@"HD",@"2K",@"4K",@"OD"];
    for (NSString *sortStr in sortRuleArray) {
        for (AVPTrackInfo *info in self.trackInfoArray) {
            if ([info.trackDefinition isEqualToString:sortStr]) {
                [array addObject:info];
                break;
            }
        }
    }
   
    _trackInfoArray = array;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat space = 10;
    CGFloat buttonHeight = (height *0.4 -space)/(self.trackInfoArray.count+1);
    
    for (int  i =0; i<= self.trackInfoArray.count; ++i) {
        UIButton *button = [[UIButton alloc]init];
        button.frame = CGRectMake(0, buttonHeight * i, width, buttonHeight -1);
        if (i == self.trackInfoArray.count) {
            button.frame = CGRectMake(0, buttonHeight * i+10, width, buttonHeight);

        }
        
        UIColor *color = [UIColor whiteColor];
        if (@available(iOS 13.0, *)) {
            color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return [UIColor blackColor];
                } else {
                    return color;
                }
            }];
        }
        button.backgroundColor = color;
        [button setTitleColor: [UIColor colorWithRed:254/255.0 green:65/255.0 blue:16/255.0 alpha:1/1.0] forState:UIControlStateSelected];
        [button setTitleColor: [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectDefinition:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = TrackButtonBeginTag + i;
        if (i == self.trackInfoArray.count) {
            [button setTitle:[@"取消" localString] forState:UIControlStateNormal];
        }else {
            AVPTrackInfo *info = [self.trackInfoArray objectAtIndex:i];
            [button setTitle:[AlivcLongVideoCommonFunc definitionWithEngStr:info.trackDefinition] forState:UIControlStateNormal];
            if ([info.trackDefinition isEqualToString:eDefinition]) {
                button.selected = YES;
            }
            
            
        }
       
        
        [self.bgView addSubview:button];
    }
    
}

- (void)selectDefinition:(UIButton *)button {
    
    
    
    if (button.tag - TrackButtonBeginTag == self.trackInfoArray.count) {
        [UIView animateWithDuration:0.2 animations:^{
           
        self.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);

        }];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoDefinitionSelectViewSelecTrack:)]) {
            [self.delegate alivcLongVideoDefinitionSelectViewSelecTrack:nil];
        }
        
        return;
    }
    AVPTrackInfo *trackInfo = [self.trackInfoArray objectAtIndex:button.tag - TrackButtonBeginTag];
    
    for (int i = 0; i<self.trackInfoArray.count; ++i) {
        UIButton *button = [self.bgView viewWithTag:TrackButtonBeginTag +i];
        button.selected = NO;
    }
    button.selected = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcLongVideoDefinitionSelectViewSelecTrack:)]) {
        [self.delegate alivcLongVideoDefinitionSelectViewSelecTrack:trackInfo];
    }
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat space = 10;
    CGFloat buttonHeight = (height *0.4 -space)/(self.trackInfoArray.count+1);
    
    self.bgView.frame = CGRectMake(0, height *0.6, width, height *0.4);
    for (int i =0; i<=self.trackInfoArray.count; ++i) {
        UIButton *button = [self viewWithTag:TrackButtonBeginTag +i];
        button.frame = CGRectMake(0, buttonHeight * i, width, buttonHeight -1);
        if (i == self.trackInfoArray.count) {
        button.frame = CGRectMake(0, buttonHeight * i+10, width, buttonHeight);
            
        }
    }
    
}

@end
