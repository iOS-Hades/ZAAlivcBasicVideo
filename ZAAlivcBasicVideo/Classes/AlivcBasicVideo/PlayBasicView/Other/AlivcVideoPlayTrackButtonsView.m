//
//  AlivcVideoPlayTrackButtonsView.m
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/25.
//

#import "AlivcVideoPlayTrackButtonsView.h"
#import "AlivcUIConfig.h"
#import "NSString+AlivcHelper.h"

@interface AlivcVideoPlayTrackButtonsView()

@property (nonatomic,strong)NSMutableArray *buttonsArray;
@property (nonatomic,assign)BOOL isHorizontal;

@end

@implementation AlivcVideoPlayTrackButtonsView

- (instancetype)initWithFrame:(CGRect)frame isHorizontal:(BOOL)isHorizontal{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.buttonsArray = [NSMutableArray array];
        self.isHorizontal = isHorizontal;
        
    }
    return self;
}

- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    
    self.selectIndex = 0;
    for (UIButton *button in self.buttonsArray) {
        [button removeFromSuperview];
    }
    [self.buttonsArray removeAllObjects];
    
    for (int i = 0; i<titleArray.count; i++) {
        CGRect buttonFrame = CGRectMake(0, 0, 120, 40);
        if (self.isHorizontal) { buttonFrame = CGRectMake(0, 0, 50, 40); }
        UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        NSString *title = titleArray[i];
        [button setTitle:title.localString forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        if ( i == 0) {
            [button setTitleColor:[self buttonColorIsSelected:YES] forState:UIControlStateNormal];
        }else {
            [button setTitleColor:[self buttonColorIsSelected:NO] forState:UIControlStateNormal];
        }
        [self.buttonsArray addObject:button];
        [self addSubview:button];
    }
    [self layoutSubviews];
}

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray <NSString *>*)titleArray isHorizontal:(BOOL)isHorizontal {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleArray = titleArray;
        self.buttonsArray = [NSMutableArray arrayWithCapacity:titleArray.count];
        self.isHorizontal = isHorizontal;
        
        for (int i = 0; i<titleArray.count; i++) {
            CGRect buttonFrame = CGRectMake(0, 0, 120, 40);
            if (isHorizontal) { buttonFrame = CGRectMake(0, 0, 50, 40); }
            UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            NSString *title = titleArray[i];
            [button setTitle:title.localString forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            if ( i == 0) {
                [button setTitleColor:[self buttonColorIsSelected:YES] forState:UIControlStateNormal];
            }else {
                [button setTitleColor:[self buttonColorIsSelected:NO] forState:UIControlStateNormal];
            }
            [self.buttonsArray addObject:button];
            [self addSubview:button];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray <NSString *>*)titleArray {
    return [self initWithFrame:frame titleArray:titleArray isHorizontal:NO];
}

- (instancetype)initHorizontalWithFrame:(CGRect)frame titleArray:(NSArray <NSString *>*)titleArray {
    return [self initWithFrame:frame titleArray:titleArray isHorizontal:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isHorizontal) {
        for (int i = 0; i<self.buttonsArray.count; i++) {
            UIButton *button = self.buttonsArray[i];
            button.center = CGPointMake(self.frame.size.width/2-((CGFloat)(self.titleArray.count-1.0)/2-i)*button.frame.size.width, self.frame.size.height/2);
        }
    }else {
        for (int i = 0; i<self.buttonsArray.count; i++) {
            UIButton *button = self.buttonsArray[i];
            button.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-((CGFloat)(self.titleArray.count-1.0)/2-i)*button.frame.size.height);
        }
    }
}

- (void)buttonClickAction:(UIButton *)sender {
    self.selectIndex = sender.tag;
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex == selectIndex) {
        return;
    }
    if (_selectIndex >= 0 && _selectIndex < self.buttonsArray.count) {
        UIButton *lastButton = self.buttonsArray[_selectIndex];
        [lastButton setTitleColor:[self buttonColorIsSelected:NO] forState:UIControlStateNormal];
    }
    if (selectIndex >= 0 && selectIndex < self.buttonsArray.count) {
        UIButton *currentButton = self.buttonsArray[selectIndex];
        [currentButton setTitleColor:[self buttonColorIsSelected:YES] forState:UIControlStateNormal];
        _selectIndex = selectIndex;
        if (self.hidden == NO) {
            self.hidden = YES;
            if (self.callBack) {
                self.callBack(selectIndex,self.titleArray[selectIndex]);
            }
        }
    }
}

- (UIColor *)buttonColorIsSelected:(BOOL)isSelected {
    if (isSelected) {
        return [AlivcUIConfig shared].kAVCThemeColor;
    }else {
        return [UIColor whiteColor];
    }
}

@end
