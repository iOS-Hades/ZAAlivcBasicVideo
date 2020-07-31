//
//  PVDropDownModule.m
//

#import "AliyunPlayerViewQualityListView.h"
#import "AliyunUtil.h"
#import <AliyunPlayer/AliyunPlayer.h>
#import "NSString+AlivcHelper.h"
#define kALYPVPopQualityListBackGroundColor      [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
static const CGFloat AliyunPlayerViewQualityListViewQualityButtonHeight = 32;

@interface AliyunPlayerViewQualityListView ()
@property (nonatomic, strong)NSMutableArray<UIButton *> *qualityBtnArray; //清晰度按钮数组
@end
@implementation AliyunPlayerViewQualityListView

#pragma mark - init
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _playMethod = ALYPVPlayMethodSTS;
        self.clipsToBounds = NO;
        self.backgroundColor = kALYPVPopQualityListBackGroundColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.bounds.size.width;
    float btnHeight = AliyunPlayerViewQualityListViewQualityButtonHeight;
    for (int i = 0; i < _qualityBtnArray.count; i++) {
        UIButton *btn = _qualityBtnArray[i];
        btn.frame = CGRectMake(0, btnHeight * i, width, btnHeight);
    }
}

#pragma  mark - public method
/*
 * 功能 ：计算清晰度列表所需高度
 */
- (float)estimatedHeight{
    return [self.allSupportQualities count] * AliyunPlayerViewQualityListViewQualityButtonHeight;
}

/*
 * 功能 ：清晰度按钮颜色改变
 */
- (void)setCurrentQuality:(int)quality {
    if (![self.allSupportQualities containsObject:[NSString stringWithFormat:@"%d", quality]]) {
        return;
    }
    for (UIButton *btn in self.qualityBtnArray) {
        if (btn.tag == quality) {
            [btn setTitleColor:kALYPVColorBlue forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:kALYPVColorTextNomal forState:UIControlStateNormal];
        }
    }
}

/*
 * 功能 ：清晰度按钮颜色改变
 */
- (void)setCurrentDefinition:(NSString*)videoDefinition{
    if (![self.allSupportQualities containsObject:videoDefinition]) {
        return;
    }
    for (UIButton *btn in self.qualityBtnArray) {
        if ([btn.titleLabel.text isEqualToString:videoDefinition]) {
            [btn setTitleColor:kALYPVColorBlue forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:kALYPVColorTextNomal forState:UIControlStateNormal];
        }
    }
}

#pragma mark - private method
/*
 * 功能 ： 监测字符串中的int值
 */
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}


- (NSString *)qualityFromTrackDefinition:(NSString *)definition {
    
    NSArray *array = @[@"FD",@"HD",@"LD",@"OD",@"SD",@"2K",@"4K",@"SQ",@"HQ"];
    NSInteger index = [array indexOfObject:definition];
    NSString * nameStr;
    switch (index) {
        case 0:
            nameStr = [@"流畅" localString];
            break;
        case 1:
            nameStr = [@"超清" localString];
            break;
        case 2:
            nameStr = [@"标清" localString];
            break;
        case 3:
            nameStr = [@"原画" localString];
            break;
        case 4:
            nameStr = [@"高清" localString];
            break;
        case 5:
            nameStr = [@"2K" localString];
            break;
        case 6:
            nameStr = [@"4K" localString];
            break;
        case 7:
            nameStr = [@"低音质" localString];
            break;
        case 8:
            nameStr = [@"高音质" localString];
            break;
        default:
            break;
    }
    
    return nameStr;
}

#pragma mark - 重写setter方法
-(void)setAllSupportQualities:(NSArray *)allSupportQualities {
    if ([allSupportQualities count] == 0) {
        return;
    }
    
    NSMutableArray *sorttedQualitiesArray = [NSMutableArray array];
    NSArray *sortRuleArray = @[@"SQ",@"HQ",@"FD",@"LD",@"SD",@"HD",@"2K",@"4K",@"OD"];
    for (NSString *sortStr in sortRuleArray) {
        for (AVPTrackInfo *info in allSupportQualities) {
            if ([info.trackDefinition isEqualToString:sortStr]) {
                [sorttedQualitiesArray addObject:info];
                break;
            }
        }
    }
    
    _allSupportQualities = sorttedQualitiesArray;
    self.qualityBtnArray = [NSMutableArray array];
    
    
    NSMutableArray *allSupportQualitysTitle = [[NSMutableArray alloc]init];
    for (AVPTrackInfo *info in _allSupportQualities) {
        [allSupportQualitysTitle addObject:info.trackDefinition];
    }
    
    //枚举类型
    NSArray *ary  = [AliyunUtil allQualities];
    NSString *title ;
    for (int i = 0; i < _allSupportQualities.count; i++) {
        int tempTag = -1;
        UIButton *btn = [[UIButton alloc] init];
        title = [self qualityFromTrackDefinition:allSupportQualitysTitle[i]];
        if (self.playMethod == ALYPVPlayMethodMPS) {
            tempTag = i+100000;
           
            [btn setTitle:title forState:UIControlStateNormal];
        }else{
            tempTag = i+200000;
            [btn setTitle:title forState:UIControlStateNormal];
        }
        UIButton *tempButton = (UIButton *)[self viewWithTag:tempTag];
        if (tempButton) {
            [tempButton removeFromSuperview];
            tempButton = nil;
        }
        [btn setTitleColor:kALYPVColorTextGray forState:UIControlStateNormal];
        [btn setTitleColor:kALYPVColorBlue forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:[AliyunUtil nomalTextSize]]];
        [btn setTag:tempTag];
        [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self.qualityBtnArray addObject:btn];
    }
}

#pragma mark - button action
- (void)onClick:(UIButton *)btn {
    if (self.playMethod == ALYPVPlayMethodMPS) {
        NSString* videoDefinition = btn.titleLabel.text;
        if (self.delegate && [self.delegate respondsToSelector:@selector(qualityListViewOnDefinitionClick:)]) {
            for (UIButton *btn in self.qualityBtnArray) {
                if ([btn.titleLabel.text isEqualToString:videoDefinition]) {
                    [btn setTitleColor:kALYPVColorBlue forState:UIControlStateNormal];
                }else{
                    [btn setTitleColor:kALYPVColorTextNomal forState:UIControlStateNormal];
                }
            }
            [self.delegate qualityListViewOnDefinitionClick:videoDefinition];
        }
    }else{
        int tag = (int) btn.tag-200000;
        if (self.delegate && [self.delegate respondsToSelector:@selector(qualityListViewOnDefinitionClick:)]) {
            for (UIButton *btn in self.qualityBtnArray) {
                if (btn.tag == tag+100000) {
                    [btn setTitleColor:kALYPVColorBlue forState:UIControlStateNormal];
                }else{
                    [btn setTitleColor:kALYPVColorTextNomal forState:UIControlStateNormal];
                }
            }
            AVPTrackInfo * track = [_allSupportQualities objectAtIndexedSubscript:tag];
            [self.delegate qualityListViewOnItemClick:track.trackIndex];
        }
    }
    [self removeFromSuperview];
}

@end
