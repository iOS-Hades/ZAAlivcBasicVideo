//
//  QHDanmuSendView.m
//  QHDanumuDemo
//
//  Created by chen on 15/7/8.
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import "QHDanmuSendView.h"
#import "QHDanmuOperateView.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "NSString+AlivcHelper.h"

#define VIEW_OPERATE_HEIGHT    44

@interface QHDanmuSendView () <QHDanmuOperateViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) QHDanmuOperateView *danmuOperateV;
@property (nonatomic, strong) UIControl *blackOverlay;
@property (nonatomic, assign) NSInteger subLen;
@end

@implementation QHDanmuSendView

- (void)dealloc {
    
    [self removeKeyboardNotificationCenter];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.danmuOperateV = nil;
    self.blackOverlay = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Do any additional setup after loading the view.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        [self addSubview:self.blackOverlay];
        
        self.danmuOperateV = [[QHDanmuOperateView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - VIEW_OPERATE_HEIGHT, self.frame.size.width, VIEW_OPERATE_HEIGHT)];
        self.danmuOperateV.deleagte = self;
        self.danmuOperateV.editContentTF.delegate = self;
        [self addSubview:self.danmuOperateV];
        
        [self addKeyboardNotificationCenter];
        
        self.alpha = 0;
    }
    return self;
}

#pragma mark - Private

//重设界面布局
- (void)p_setOperateView:(CGFloat)h {
    CGFloat top = h - CGRectGetHeight(self.danmuOperateV.frame);
    CGRect frame = self.danmuOperateV.frame;
    frame.origin.y = top;
    self.danmuOperateV.frame = frame;
}
- (void)becomeActive{
    
    [self.danmuOperateV.editContentTF resignFirstResponder];
    if ([self.deleagte respondsToSelector:@selector(closeSendDanmu:)]) {
        [self.deleagte closeSendDanmu:self];
    }
    [self removeFromSuperview];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString * deleteSpace = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (deleteSpace.length == 0){
        [MBProgressHUD showMessage:[@"请输入要发送的内容" localString] inView:[[UIApplication sharedApplication].windows lastObject]];
    }else {
           [self closeDanmu:nil];
    }
 
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * currentString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    CGFloat length = [self countW:currentString];
    
   
    if ([string isEqualToString:@""]) {
        return YES;
    }else if (length>20){

        NSInteger currentLength = currentString.length -1;
        while ( [self countW:currentString] >20) {
            currentString = [currentString substringToIndex:currentLength];
            currentLength --;
        }
        textField.text = currentString;
        
        [MBProgressHUD showMessage:[@"最多输入40个字符或20个汉字" localString] inView:[[UIApplication sharedApplication].windows lastObject]];
        return NO;
    }
    return YES;
}

- (CGFloat)countW:(NSString *)s
{
    int i;CGFloat n=[s length],l=0,a=0,b=0;
    CGFloat wLen=0;
    unichar c;
    for(i=0;i<n;i++){
        c=[s characterAtIndex:i];//按顺序取出单个字符
        if(isblank(c)){//判断字符串为空或为空格
            b++;
        }else if(isascii(c)){
            a++;
        }else{
            l++;
        }
        wLen=l+(CGFloat)((CGFloat)(a+b)/2.0);
        NSLog(@"wLen--%f",wLen);
        if (wLen>=4.5&&wLen<5.5) {//设定这个范围是因为，当输入了当输入9英文，即4.5，后面还能输1字母，但不能输1中文
            _subLen=l+a+b;//_subLen是要截取字符串的位置
        }
        
    }
    if(a==0 && l==0)
    {
        _subLen=0;
        return 0;//只有isblank
    }
    else{
        
        return wLen;//长度，中文占1，英文等能转ascii的占0.5
    }
}

#pragma mark - QHDanmuOperateViewDelegate

- (void)closeDanmu:(UIButton *)btn {
    
    NSString * deleteSpace = [self.danmuOperateV.editContentTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (deleteSpace.length == 0){
        [MBProgressHUD showMessage:[@"请输入要发送的内容" localString] inView:[[UIApplication sharedApplication].windows lastObject]];
    }else {
        
    
    if ([self.deleagte respondsToSelector:@selector(sendDanmu:info:)]) {
        [self.deleagte sendDanmu:self info:self.danmuOperateV.editContentTF.text];
    }
    [self hiddenView];
        
    }
}

#pragma mark - Action

- (void)showAction:(UIView *)superView {
    self.alpha = 1;
    CGRect frame = self.frame;
    frame.origin.y = superView.frame.size.height;
    self.frame = frame;
    [UIView animateWithDuration:0.6 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = superView.frame.size.height - self.frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self.danmuOperateV.editContentTF becomeFirstResponder];
    }];
}

- (void)backAction {
    [self hiddenView];
}

- (void)hiddenView {
    [self.danmuOperateV.editContentTF resignFirstResponder];
    [UIView animateWithDuration:0.6 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = self.superview.frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        if ([self.deleagte respondsToSelector:@selector(closeSendDanmu:)]) {
            [self.deleagte closeSendDanmu:self];
        }
        [self removeFromSuperview];
    }];
}



#pragma mark keyboardaction

- (void)addKeyboardNotificationCenter {
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotificationCenter {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardAction:(NSNotification *)notification complete:(void(^)(CGFloat hKeyB))complete {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationCurveObject =[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    NSValue *animationDurationObject =[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSValue *keyboardEndRectObject =[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0,0, 0, 0);
    [animationCurveObject getValue:&animationCurve];
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    CGFloat hKeyB = 0;
    hKeyB = keyboardEndRect.size.height;
    
    [UIView beginAnimations:@"keyboardAction" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    complete(hKeyB);
    [UIView commitAnimations];
}

#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    [self keyboardAction:notification complete:^(CGFloat hKeyB) {
        [self p_setOperateView:ScreenHeight - hKeyB];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self hiddenView];
    [self.deleagte sendDanmu:self info:nil];
    [self keyboardAction:notification complete:^(CGFloat hKeyB) {
        [self p_setOperateView:self.frame.size.height];
    }];
}

#pragma mark - Get

- (UIControl *)blackOverlay {
    if (_blackOverlay == nil) {
        _blackOverlay = [[UIControl alloc] initWithFrame:self.bounds];
        [_blackOverlay addTarget:self action:@selector(quitEdit) forControlEvents:UIControlEventTouchUpInside];
        _blackOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        UIColor *maskColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        _blackOverlay.backgroundColor = maskColor;
    }
    
    return _blackOverlay;
}
- (void)quitEdit {
    if ([self.deleagte respondsToSelector:@selector(sendDanmu:info:)]) {
        [self.deleagte sendDanmu:self info:nil];
    }
    [self hiddenView];
}
- (void)layoutSubviews {
    [super layoutSubviews];
  
}

@end
