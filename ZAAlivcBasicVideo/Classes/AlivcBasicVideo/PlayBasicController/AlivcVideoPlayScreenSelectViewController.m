//
//  AVCScreenPlayViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/6/10.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcVideoPlayScreenSelectViewController.h"
#import <MRDLNA/MRDLNA.h>
#import "NSString+AlivcHelper.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AliyunUtil.h"
@interface AlivcVideoPlayScreenSelectViewController ()<UITableViewDelegate, UITableViewDataSource, DLNADelegate>

@property(nonatomic,strong) MRDLNA *dlnaManager;

@property(nonatomic,strong) UITableView *screenPlayTableView;

@property(nonatomic,strong) NSMutableArray *deviceArr;

@property(nonatomic,strong) UIButton  *backButton;

@property(nonatomic,assign) NSInteger  scanCount;



@end

@implementation AlivcVideoPlayScreenSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backButton];
   
    self.deviceArr = [[NSMutableArray alloc]init];
    CLUPnPDevice *model  = [[CLUPnPDevice alloc]init];
    model.friendlyName = @"Airplay";
    [self.deviceArr addObject:model];
    [self.view addSubview:self.screenPlayTableView];
    self.dlnaManager = [MRDLNA sharedMRDLNAManager];
    self.dlnaManager.delegate = self;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _scanCount = 0;
    [self.dlnaManager startSearch];
    NSLog(@"DLNA～～开始发现设备");
}

- (void)searchDLNAResult:(NSArray *)devicesArray{
    NSLog(@"DLNA～～结束发现设备");
   
    if (devicesArray.count == 0 && _scanCount < 5) {
         [self.dlnaManager startSearch];
        NSLog(@"DLNA～～开始发现设备");
        ++ _scanCount;
    }else {
        for (NSString *deviceName in devicesArray) {
            if (![self.deviceArr containsObject:deviceName]) {
                 [self.deviceArr addObjectsFromArray:devicesArray];
            }
        }
  
    [self.screenPlayTableView reloadData];
        
    }
    if (self.deviceArr.count == 0) {
        [MBProgressHUD showMessage:[@"没有支持的设备" localString] inView:self.view];
    }
    
    
}

- (void)dlnaStartPlay{
    NSLog(@"投屏成功 开始播放");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseID = [NSString stringWithFormat:@"cell%lu%lu",(long)indexPath.row,(long)indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
    }
    CLUPnPDevice *device = self.deviceArr[indexPath.row];
    cell.textLabel.text = device.friendlyName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *testUrl = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
    
    //http://223.110.239.40:6060/cntvmobile/vod/p_cntvmobile00000000000020150518/m_cntvmobile00000000000659727681
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.deviceArr.count) {
        CLUPnPDevice *model = self.deviceArr[indexPath.row];
        self.dlnaManager.device = model;
        self.dlnaManager.playUrl = self.playUrl;
       
        if (indexPath.row == 0 && [model.friendlyName isEqualToString:@"Airplay"]) {

            if ([self.playUrl containsString:@"encrypt"]  || (![self.playUrl hasSuffix:@"mp4"]&& ![self.playUrl hasSuffix:@"mov"] )) {
                 [MBProgressHUD showMessage:[@"当前视频不支持airplay投屏" localString]  inView:[UIApplication sharedApplication].keyWindow];
                return;
            }


            [UIView animateWithDuration:0.3 animations:^{
                [self.navigationController popViewControllerAnimated:NO];
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayerStartAirplayToPlay" object:nil];
            }];

        }else {

           // DLNA
            [UIView animateWithDuration:0.3 animations:^{
                [self.navigationController popViewControllerAnimated:NO];
            } completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"PlayerStartDLNAToPlay" object:model];
            }];



        }
       
        
  
    }
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc]init];
         UIImage *backImage = [AlivcImage imageInBasicVideoNamed:@"avcBackIcon"];
        [_backButton setImage:backImage forState:UIControlStateNormal];
        [_backButton setTitle:[@"返回" localString] forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
    return _backButton;
}
- (UITableView *)screenPlayTableView{
    if (!_screenPlayTableView) {
        _screenPlayTableView = [[UITableView alloc]init];
        _screenPlayTableView.dataSource = self;
        _screenPlayTableView.delegate = self;
        UIView *footView = [[UIView alloc]init];
        _screenPlayTableView.tableFooterView = footView;
    }
    return _screenPlayTableView;
}

- (void)backClick {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    NSLog(@"%f %f",ScreenWidth,ScreenHeight);
   
   
    if ([AliyunUtil isInterfaceOrientationPortrait]) {
    self.backButton.frame = CGRectMake(10, SafeTop  , 60, SafeTop);
    self.screenPlayTableView.frame = CGRectMake(0,2 *SafeTop  , ScreenWidth, ScreenHeight - SafeTop -20);
    }else {
        self.backButton.frame = CGRectMake(10, 20  , 60, SafeTop);
        self.screenPlayTableView.frame = CGRectMake(0,SafeTop +20 , ScreenWidth, ScreenHeight - SafeTop -20);
    }
    
}


- (BOOL)shouldAutorotate{
    //不允许转屏
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //viewController所支持的全部旋转方向
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    //viewController初始显示的方向
    return UIInterfaceOrientationPortrait;
}


@end
