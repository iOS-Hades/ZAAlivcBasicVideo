//
//  AlivcLongVideoCommonFunc.h
//  longVideo
//
//  Created by Aliyun on 2019/6/26.
//  Copyright © 2019 Aliyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlivcLongVideoCommonFunc : NSObject


+ (NSArray *)getSettingTitleArray;

+ (NSArray *)getSettingDetailsTitleArrayWithKey:(NSString *)key;

+ (NSString *)getUDSetWithIndex:(NSInteger)index;


+ (NSString *)definitionWithChiStr:(NSString *)str;

+ (NSString *)definitionWithEngStr:(NSString *)str;

+ (NSString *)getUDSetWithKey:(NSString *)key;

+ (void)setUDWithKey:(NSString *)key vaule:(NSString *)value;
+ (void)setDlNAStatus:(BOOL)isPlaying;
+ (BOOL)getDLNAStatus;
+ (void)saveImage:(UIImage *)image inView:(UIView *)view;

@end

