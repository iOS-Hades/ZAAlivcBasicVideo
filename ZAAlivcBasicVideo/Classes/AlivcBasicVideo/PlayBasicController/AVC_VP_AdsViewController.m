//
//  AVC_VP_AdsViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by 汪宁 on 2019/3/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AVC_VP_AdsViewController.h"
#import <WebKit/WebKit.h>
#import "AliyunUtil.h"
#import "NSString+AlivcHelper.h"
@interface AVC_VP_AdsViewController ()

@property (nonatomic, strong)WKWebView * webView;
@property (nonatomic, strong)UIButton *backButton;

@end

@implementation AVC_VP_AdsViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowPresentView" object:@"1"];
   
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowPresentView" object:@"0"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[WKWebView alloc] init];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlLink]]];
    //self.webView.navigationDelegate = self;
    //self.webView.UIDelegate = self;
    //开了支持滑动返回
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
    _backButton = [[UIButton alloc]init];
    [self.view addSubview:_backButton];
    [_backButton setTitle:[@"返回" localString] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)viewDidLayoutSubviews {
    
      UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

        if (orientation == UIInterfaceOrientationPortrait ){
    
            self.webView.frame = CGRectMake(0, 44+ SafeTop, ScreenWidth, ScreenHeight - 44 -SafeTop);
            _backButton.frame = CGRectMake(10, SafeTop, 60, 44);
    
        }else {
             self.webView.frame = CGRectMake(0, 44, ScreenWidth, ScreenHeight - 44);
           _backButton.frame = CGRectMake(20, 0, 60, 44);
        }
    

    
}

- (void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.goBackBlock) {
        self.goBackBlock();
    }
}



@end
