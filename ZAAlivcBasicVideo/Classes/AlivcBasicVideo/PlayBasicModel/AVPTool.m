//
//  AVPTool.m
//  AliPlayerDemo
//
//  Created by 郦立 on 2018/12/29.
//  Copyright © 2018年 com.alibaba. All rights reserved.
//

#import "AVPTool.h"
#import "MBProgressHUD.h"
#import "NSString+AlivcHelper.h"

@implementation AVPTool

+ (void)hudWithText:(NSString *)text view:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * hudShowText = text;
        NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
        for (UIView *subview in subviewsEnum) {
            if ([subview isKindOfClass:[MBProgressHUD class]] && subview.tag == 999) {
                MBProgressHUD *hud = (MBProgressHUD *)subview;
                if (hud.detailsLabel.text.length > 0) {
                    hud.hidden = YES;
                    [hud removeFromSuperview];
                    hudShowText = [[hudShowText stringByAppendingString:@"\n"] stringByAppendingString:hud.detailsLabel.text];
                }
            }
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.tag = 999;
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.text = hudShowText;
        hud.detailsLabel.numberOfLines = 5;
        hud.margin = 10.f;
        [hud setOffset:CGPointMake(0, [UIScreen mainScreen].bounds.size.height*0.35)];
        hud.userInteractionEnabled = NO;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:3];
    });
}

+ (void)loadingHudToView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        hud.label.text = [@"加载中..." localString];
    });
}

+ (void)hideLoadingHudForView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
        for (UIView *subview in subviewsEnum) {
            if ([subview isKindOfClass:[MBProgressHUD class]]) {
                MBProgressHUD *hud = (MBProgressHUD *)subview;
                if ([hud.label.text isEqualToString:[@"加载中..." localString]]) {
                    hud.hidden = YES;
                    [hud removeFromSuperview];
                }
            }
        }
    });
}

+ (NSTimeInterval)currentTimeInterval {
    return [[NSDate date] timeIntervalSince1970];
}

@end






