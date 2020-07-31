//
//  AlivcLongVideoCacheListViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/1.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoCacheListViewController.h"
#import "AVCVideoDownloadTCell.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcLongVideoPlayView.h"
#import "AliyunUtil.h"
#import "NSString+AlivcHelper.h"
#import "AlivcLongVideoDBManager.h"
#import "AlivcLongVideoCommonFunc.h"
#import "AlivcDefine.h"
#import "AVPTool.h"
#import "AlivcPlayVideoRequestManager.h"

@interface AlivcLongVideoEditArrayModel : NSObject

@property (nonatomic, strong) NSMutableArray *editVideoArray;

@end

@implementation AlivcLongVideoEditArrayModel

-(NSMutableArray *)editVideoArray{
    if(!_editVideoArray){
        _editVideoArray = [NSMutableArray array];
    }
    return _editVideoArray;
}


@end


@interface AlivcLongVideoCacheListViewController ()<UITableViewDelegate, UITableViewDataSource,AVCVideoDownloadTCellDelegate,AlivcLongVideoDownLoadManagerDelegate,AlivcLongVideoDownLoadProgressManagerDelegate,AliyunVodPlayerViewDelegate>

/**
 离线视频下载tableView
 */
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *downloadTableView;
@property (nonatomic, strong) UILabel *capacityLabel;
@property (nonatomic, strong) NSArray *downloadingVideoArray;
@property (nonatomic, strong) NSArray *doneVideoArray;
@property (nonatomic, strong) NSMutableArray *videoListArray;
@property (nonatomic, strong) AlivcLongVideoEditArrayModel *editArrayModel;
@property (nonatomic, strong) AlivcLongVideoDownLoadProgressManager *downLoadProgressManager;
@property (nonatomic, strong) AlivcLongVideoPlayView *playerView;// 包含了各种控件的播放页面
@property (nonatomic, strong) AlivcLongVideoDBManager *historyDBManager;
@property (nonatomic, strong) AlivcLongVideoDownloadSource *currentPlaySource;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) UIView *replayView;


/**
 是否在编辑下载视频
 */
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *editAllButton;
@property (nonatomic, strong) UIButton *deleteButton;


@end

@implementation AlivcLongVideoCacheListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.downLoadProgressManager.delegate = self;
    if (self.videoListType == AllCacheVideoType) {
        [self localCacheSourceArray];
    }else {
        [self localCacheEpisodeSourceArray:self.tvId];
    }
    
    [self.downloadTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.downLoadProgressManager.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    self.editArrayModel = [[AlivcLongVideoEditArrayModel alloc]init];
    self.videoListArray = [[NSMutableArray alloc]init];
    self.historyDBManager = [AlivcLongVideoDBManager shareManager];
    self.downLoadProgressManager = [AlivcLongVideoDownLoadProgressManager sharedInstance];
    self.downLoadProgressManager.delegate = self;
    [self.editArrayModel addObserver:self forKeyPath:@"editVideoArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    self.view.backgroundColor = [self themeColor];
    
    [self.view addSubview:self.downloadTableView];
    [self.view addSubview:self.noDataLabel];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.editButton];
    self.downloadingVideoArray = [[NSArray alloc]init];
    self.doneVideoArray = [[NSArray alloc]init];
    
    [self.view addSubview:self.capacityLabel];
    [self.view addSubview:self.editAllButton];
    [self.view addSubview:self.deleteButton];
    [self.view addSubview:self.playerView];
    [self.playerView addSubview:self.replayView];
    [self getCaCheInfoMemory];
    
    
    self.isLock = self.playerView.isScreenLocked||self.playerView.fixedPortrait?YES:NO;
    
}

- (UIColor *)themeColor {
    UIColor *color = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    if (@available(iOS 13.0, *)) {
        color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor blackColor];
            } else {
                return color;
            }
        }];
    }
    return color;
}

- (void)becomeActive {
    
    self.isEnterBackground = NO;
    
}

- (void)resignActive {
    
    self.isEnterBackground = YES;
}



- (UIView *)replayView {
    if (!_replayView) {
        _replayView = [[UIView alloc]init];
        _replayView.hidden = YES;
        _replayView.layer.masksToBounds = YES;
        _replayView.layer.cornerRadius = 4;
        _replayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor whiteColor];
        label.text = [@"视频播放结束" localString];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        
        UIButton *button = [[UIButton alloc]init];
        [button addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[@"重播" localString]forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor colorWithRed:0.16f green:0.53f blue:0.47f alpha:1.00f] forState:UIControlStateNormal];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 2;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor colorWithRed:0.16f green:0.53f blue:0.47f alpha:1.00f].CGColor;
        [_replayView addSubview:label];
        [_replayView addSubview:button];
        
    }
    
    return _replayView;
}

- (UILabel *)noDataLabel {
    if (!_noDataLabel) {
        _noDataLabel = [[UILabel alloc]init];
        _noDataLabel.textColor = [UIColor colorWithRed:0.55f green:0.55f blue:0.55f alpha:1.00f];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = [@"- 暂无缓存视频 -" localString];
        _noDataLabel.hidden = YES;
    }
    return _noDataLabel;
}

- (void)reviveDownload {
    
    NSArray * downloadSourceArray = [self.downLoadManager allReadySources];
    for (AlivcLongVideoDownloadSource * downloadSource in downloadSourceArray) {
        
        if (downloadSource.downloadStatus == LongVideoDownloadTypeStoped && [self.downLoadManager allowDownload] == YES && self.videoListType == AllCacheVideoType && downloadSource.totalDataString && downloadSource.totalDataString.length>0) {
            // 进入开始下载
            [downloadSource startDownLoad:self.view];
         }
    
    }
    
}


-(void)getCaCheInfoMemory{
    
    CGFloat avalibale = [self availableMemory];
    CGFloat occupyMemory = 0;
    NSArray * downedLoadSourceArray  = [self.downLoadManager doneSources];
    for (AlivcLongVideoDownloadSource *source in downedLoadSourceArray) {
        
        NSString * subStr =  [source.totalDataString substringToIndex:source.totalDataString.length -1];
        CGFloat memory = [subStr floatValue];
        occupyMemory = occupyMemory + memory;
    }
    CGFloat percent = occupyMemory/(avalibale*1024);
     self.capacityLabel.text = [NSString stringWithFormat:@"%@%0.1fM,%@%0.1fG%@",[@"已缓存" localString],occupyMemory,[@"剩余" localString],avalibale,[@"可用" localString]];
    
    if (occupyMemory>1024) {
        occupyMemory = occupyMemory/1024;
        self.capacityLabel.text = [NSString stringWithFormat:@"%@%0.1fG,%@%0.1fG%@",[@"已缓存" localString],occupyMemory,[@"剩余" localString],avalibale,[@"可用" localString]];
    }
    
    
    
    
    if (percent > 0.1) {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH *percent, 60)];
        view.backgroundColor = [UIColor colorWithRed:0.81f green:0.85f blue:0.87f alpha:1.00f];
        [self.capacityLabel addSubview:view];
        
    }
   
}

- (AlivcLongVideoPlayView *)playerView {
    if (!_playerView) {
        _playerView = [[AlivcLongVideoPlayView alloc]init];
        _playerView.backgroundColor = [UIColor colorWithRed:0.12f green:0.13f blue:0.18f alpha:1.00f];
        _playerView.delegate = self;
        _playerView.hidden = YES;
        [_playerView cleanLastFrame:YES];
        
    }
    
    return _playerView;
}

- (void)localCacheSourceArray {
    
    self.videoListArray = [NSMutableArray arrayWithArray:[self.downLoadManager allReadySourcesWithoutRepeatTv]];
    
    for (AlivcLongVideoDownloadSource * downloadSource in self.videoListArray) {
        if (downloadSource.longVideoModel.tvId && downloadSource.longVideoModel.tvId.length >0) {
            NSArray *array = [self.downLoadManager tvSource:downloadSource.longVideoModel.tvId];
            downloadSource.episodeNum = array.count;
            downloadSource.firstTvSource = YES;
           
            NSInteger episodeAlreadyWatchNum = 0;
            for (AlivcLongVideoDownloadSource * tvDownloadSource in array) {
                if (tvDownloadSource.watched)
                {
                   ++ episodeAlreadyWatchNum;
                }
            }
            downloadSource.episodeAlreadyWatchNum = episodeAlreadyWatchNum;
            
            
        }
    }
    
}

- (void)localCacheEpisodeSourceArray:(NSString *)tvId {
    
    self.videoListArray = [NSMutableArray arrayWithArray:[self.downLoadManager tvSource:tvId]];
    for (AlivcLongVideoDownloadSource * tvDownloadSource in self.videoListArray) {
        tvDownloadSource.firstTvSource = NO;
    }

    
}



- (UIButton *)backButton {
    
    if (!_backButton) {
        _backButton = [[UIButton alloc]init];
        [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[AlivcImage imageInBasicVideoNamed:@"left_back_setting"] forState:UIControlStateNormal];
      
    }
    
    return _backButton;
    
}
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithRed:3/255.0 green:3/255.0 blue:3/255.0 alpha:1/1.0];
        _titleLabel.text =  [@"缓存视频" localString];
        
    }
    return _titleLabel;
}


- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [[UIButton alloc]init];
        [_editButton setTitleColor:[UIColor colorWithRed:24/255.0 green:24/255.0 blue:24/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        [_editButton setTitle:[@"编辑" localString] forState:UIControlStateNormal];
        [_editButton setTitle:[@"取消" localString] forState:UIControlStateSelected];
        _editButton.selected = NO;
        [_editButton addTarget:self action:@selector(isEditCacheVideo:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _editButton;
}

- (void)isEditCacheVideo:(UIButton *)button{
    
    button.selected = !button.selected;
    self.isEdit = button.selected;
    if (self.isEdit) {
        self.editAllButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.editAllButton.selected = NO;
    }else {
        self.editAllButton.hidden = YES;
        self.deleteButton.hidden = YES;
    }
    
    self.isEdit = button.selected;
    if (self.editArrayModel.editVideoArray.count >0) {
        
        [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]removeAllObjects];
    }
    //[self configDownloadEditView:isEdit];
    [self.downloadTableView reloadData];
  

}

- (UIButton *)editAllButton {
    if (!_editAllButton) {
        _editAllButton = [[UIButton alloc]init];
        _editAllButton.backgroundColor = [UIColor whiteColor];
//        [_editAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
//        [_editAllButton setTitle:NSLocalizedString(@"取消全选", nil) forState:UIControlStateSelected];
        [_editAllButton setTitle:[@"全选" localString] forState:UIControlStateNormal];
        [_editAllButton setTitle:[@"取消全选" localString] forState:UIControlStateSelected];
        [_editAllButton  addTarget:self action:@selector(selectAll:) forControlEvents:UIControlEventTouchUpInside];
        [_editAllButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        _editAllButton.hidden = YES;
    }
    
    return _editAllButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
       
        _deleteButton = [[UIButton alloc]init];
        _deleteButton.backgroundColor = [UIColor whiteColor];
        [_deleteButton setTitle:[@"删除" localString] forState:UIControlStateNormal];
        [_deleteButton  addTarget:self action:@selector(deleteDownloadVideo) forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton setTitleColor:[UIColor colorWithRed:0.60f green:0.60f blue:0.60f alpha:1.00f] forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
        
        
    }
    
    return _deleteButton;
}

- (void)selectAll:(UIButton *__nullable)button{
    button.selected = !button.isSelected;
    for (int i = 0; i< self.videoListArray.count; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        AVCVideoDownloadTCell *cell = [self.downloadTableView cellForRowAtIndexPath:indexPath];
        [cell setSelectedCustom:button.selected];
    }

    if (button.selected) {
        
        [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]removeAllObjects];
        [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]addObjectsFromArray:self.videoListArray];
        
    }else {

        [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]removeAllObjects];
    }
    
    [self.downloadTableView reloadData];
}

- (void)deleteDownloadVideo{
    
    if (self.editArrayModel.editVideoArray.count == 0) {
        [MBProgressHUD showMessage:[@"请选择至少一个视频" localString] inView:self.view];
    }else{
        for (AlivcLongVideoDownloadSource *downLoadSource in self.editArrayModel.editVideoArray) {
            [self.videoListArray removeObject:downLoadSource];
            [self.downLoadManager clearMedia:downLoadSource];
    
            if (downLoadSource.longVideoModel.tvId && self.videoListType == AllCacheVideoType) {// 剧集删除
                [self.downLoadManager clearMediaWithTvId:downLoadSource.longVideoModel.tvId];
              
            }
        
        }
        [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]removeAllObjects];
     
        [self.downloadTableView reloadData];
        [self getCaCheInfoMemory];
    }
    
}


- (UITableView *)downloadTableView {
    
    if (!_downloadTableView) {
        
        _downloadTableView = [[UITableView alloc]init];
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcBasicVideo.bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        [_downloadTableView registerNib:[UINib nibWithNibName:@"AVCVideoDownloadTCell" bundle:bundle] forCellReuseIdentifier:@"AVCVideoDownloadTCell"];
        _downloadTableView.tableFooterView = [UIView new];
        _downloadTableView.dataSource = self;
        _downloadTableView.delegate = self;
        _downloadTableView.backgroundColor = [self themeColor];
        [_downloadTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
    }
    return _downloadTableView;
    
}

- (UILabel *)capacityLabel {
    
    if (!_capacityLabel) {
        _capacityLabel  = [[UILabel alloc]init];
        _capacityLabel.backgroundColor = [UIColor colorWithRed:236/255.0 green:239/255.0 blue:241/255.0 alpha:1/1.0];
        _capacityLabel.textAlignment = NSTextAlignmentCenter;
        _capacityLabel.font = [UIFont systemFontOfSize:13];
        _capacityLabel.textColor = [UIColor colorWithRed:140/255.0 green:140/255.0 blue:140/255.0 alpha:1/1.0];
    }
    
    return _capacityLabel;
}


#pragma mark - UITableViewDataSource


- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.videoListArray.count || self.videoListArray.count == 0) {
        self.noDataLabel.hidden = NO;
        self.capacityLabel.hidden = YES;
        self.editButton.hidden = YES;
    }else{
        self.noDataLabel.hidden = YES;
        self.capacityLabel.hidden = NO;
        self.editButton.hidden = NO;
    }
        
    return  self.videoListArray.count;
     
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AVCVideoDownloadTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AVCVideoDownloadTCell"];
    AlivcLongVideoDownloadSource *video = [self.videoListArray objectAtIndex:indexPath.row];
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (video) {
        
        if (video.longVideoModel.tvId && self.videoListType == AllCacheVideoType) {
            video.episodeTotalDataString = [NSString stringWithFormat:@"%0.1fM",[self.downLoadManager cachedMemoryWithTvId:video.longVideoModel.tvId]];
        }
        
        [cell configWithLongVideoSource:video];
        //选中状态根据self.editVideoArray来适配，保证ui和数据的统一
        BOOL haveSelected = false;
        for (AlivcLongVideoDownloadSource *editVideo in self.editArrayModel.editVideoArray) {
            if ([editVideo isEqualToSource:video]) {
                haveSelected = true;
                break;
            }
        }
        [cell setSelectedCustom:haveSelected];
    }
    [cell setTOEditStyle:self.isEdit];
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AlivcLongVideoDownloadSource *video = nil;
    video = [self.videoListArray objectAtIndex:indexPath.row];
    
    if (video) {
        if (self.isEdit) {
            //切换选中非选中状态
            AVCVideoDownloadTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            BOOL selected = !cell.customSelected;
            [cell setSelectedCustom:selected];
            if (selected) {
                [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]addObject:video];
               
            }else{
                [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]removeObject:video];
             
            }
            
        }else{
            
            
            // 跳到剧集下载详情页
            if (self.videoListType == AllCacheVideoType && video.longVideoModel.tvId && video.longVideoModel.tvId.length >0) {
                
                AlivcLongVideoCacheListViewController * vc = [[AlivcLongVideoCacheListViewController alloc]init];
                vc.videoListType = SpecificEpisodeType;
                vc.tvId = video.longVideoModel.tvId;
                [self.navigationController pushViewController:vc animated:YES];
            }else {
                
                //播放视频
                 _currentPlaySource = video;
                 [self changeToPlayLocalVideo:video];
               
                
            }
           
            
            
        }
        
    }
}

- (void)changeToPlayLocalVideo:(AlivcLongVideoDownloadSource *)video {
    
    if (video.downloadStatus != LongVideoDownloadTypefinish) {
        [MBProgressHUD showMessage:[@"视频还未下载完成" localString] inView:self.view];
        return;
    }
    //不熄屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.playerView.hidden = NO;
    [self set:UIInterfaceOrientationLandscapeRight];
    NSString *path = DEFAULT_DM.downLoadPath;
    NSString *str = [NSString stringWithFormat:@"%@/%@",path,video.downloadedFilePath];
    [[AlivcLongVideoDBManager shareManager]addHistoryTVModel:video.longVideoModel];
    [self.playerView stop];
    [self.playerView setTitle:video.longVideoModel.title];
    [self.playerView playViewPrepareWithLocalURL:[NSURL URLWithString:str]];
   
    
    
}

#pragma mark -  AVCVideoDownloadTCellDelegate

- (void)longVideoDownTCell:(AVCVideoDownloadTCell *)cell video:(AlivcLongVideoDownloadSource *)video selected:(BOOL)selected{
    if (selected) {
       [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]addObject:video];
    }else{
        [[self.editArrayModel mutableArrayValueForKeyPath:@"editVideoArray"]removeObject:video];
    }
}

- (void)longVideoDownTCell:(AVCVideoDownloadTCell *)cell actionButtonTouchedWithVideo:(AlivcLongVideoDownloadSource *)video{
    
    switch (video.downloadStatus) {
        case LongVideoDownloadTypeStoped: {
            
            [video startDownLoad:self.view];
        }
            break;
            
        case LongVideoDownloadTypePrepared :{
            //重新开始下载 - stsData得重新获取
            [video startDownLoad:self.view];
            
        }
            break;
        case LongVideoDownloadTypeFailed :{
            
            [video startDownLoad:self.view];
            
        }
            break;
            
        case LongVideoDownloadTypeLoading:{
            //暂停下载
            
            [video stopDownLoad];
            video.downloadStatus = DownloadTypeStoped;
            
        }
            break;
        case LongVideoDownloadTypeWaiting :{
            [video startDownLoad:self.view];
        }
            break;
            
            
        default:
            break;
    }
    [self.downloadTableView reloadData];
    
    
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.editArrayModel.editVideoArray.count == 0) {
       
        [_deleteButton setTitleColor:[UIColor colorWithRed:0.60f green:0.60f blue:0.60f alpha:1.00f] forState:UIControlStateNormal];
        [self.deleteButton setTitle:[@"删除" localString] forState:UIControlStateNormal];
    }else {
        
        NSInteger count = self.editArrayModel.editVideoArray.count;
        if (self.videoListType == AllCacheVideoType) {
            for (AlivcLongVideoDownloadSource * downloadSource in self.editArrayModel.editVideoArray) {
                if (downloadSource.longVideoModel.tvId) {
                    NSArray *array = [self.downLoadManager tvSource:downloadSource.longVideoModel.tvId];
                    count = count + array.count -1;
                }
            }
            
        }
            
        
        [self.deleteButton setTitle:[NSString stringWithFormat:@"%@(%d)",[@"删除" localString],count] forState:UIControlStateNormal];
        [_deleteButton setTitleColor: [UIColor colorWithRed:254/255.0 green:65/255.0 blue:16/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    }
    
    if (self.videoListArray.count == 0) {
        
        self.editButton.selected = NO;
        self.editButton.hidden = YES;
        self.deleteButton.hidden = YES;
        self.editAllButton.hidden = YES;
        self.isEdit = NO;
    }
    
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    self.backButton.frame = CGRectMake(10, SafeTop, 50, 44);
    self.titleLabel.frame = CGRectMake(0, SafeTop , ScreenWidth, 44);
    self.editButton.frame = CGRectMake(ScreenWidth - 70, SafeTop, 60, 44);
    self.capacityLabel.frame = CGRectMake(0, ScreenHeight - 60, ScreenWidth, 60);
    self.downloadTableView.frame = CGRectMake(0, SafeTop+44, ScreenWidth, ScreenHeight - 60 -SafeTop - 44);
    self.noDataLabel.frame = CGRectMake(0, SCREEN_HEIGHT *0.45, SCREEN_WIDTH, 30);
    self.editAllButton.frame = CGRectMake(0, ScreenHeight - 60, ScreenWidth/2, 60);
    self.deleteButton.frame = CGRectMake(ScreenWidth/2, ScreenHeight - 60, ScreenWidth/2, 60);
    self.playerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.replayView.frame = CGRectMake(SCREEN_WIDTH *0.35, SCREEN_HEIGHT *0.35, SCREEN_WIDTH *0.3, SCREEN_HEIGHT*0.3);
    for (UIView * view in self.replayView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            view.frame = CGRectMake(0, 20, SCREEN_WIDTH * 0.3, 20);
        }
        if ([view isKindOfClass: [UIButton class]]) {
            view.frame = CGRectMake((SCREEN_WIDTH * 0.3 -90)/2, SCREEN_HEIGHT *0.3 - 50, 90, 30);
        }
        
    }
   
    
    
}

#pragma mark AlivcLongVideoDownLoadProgressManagerDelegate

- (void)alivcLongVideoDownLoadProgressManagerPrepared:(AlivcLongVideoDownloadSource *)source mediaInfo:(AVPMediaInfo *)mediaInfo {
    
  [self.downLoadManager startDownloadSource:source];
    
}

- (void)alivcLongVideoDownLoadProgressManagerOnProgress:(AlivcLongVideoDownloadSource *)source percent:(int)percent {
    
    source.downloadStatus = LongVideoDownloadTypeLoading;
    AlivcLongVideoDownloadSource *currentSource = nil;
    
    for (AlivcLongVideoDownloadSource *downloadSource in self.videoListArray) {
        
        if (self.videoListType == AllCacheVideoType && (source.longVideoModel.tvId.length != 0 ||[source.longVideoModel.tvId isEqualToString:@"(null)"])) {
            if([downloadSource.longVideoModel.tvId isEqualToString:source.longVideoModel.tvId]){
                currentSource = downloadSource;
                
                break;
            }
        }else if ([downloadSource.longVideoModel.videoId isEqualToString:source.longVideoModel.videoId] && downloadSource.trackIndex == source.trackIndex) {
            currentSource = downloadSource;
            break;
        }
    }
    
    NSLog(@"%d",percent);
    
    //找到对应的cell
    currentSource.percent = percent;
    if (currentSource) {
        NSInteger index = [self.videoListArray indexOfObject:currentSource];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *cell = [self.downloadTableView cellForRowAtIndexPath:indexPath];
        AVCVideoDownloadTCell *downloadCell = (AVCVideoDownloadTCell *)cell;
        if (downloadCell) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [downloadCell configWithLongVideoSource:currentSource];
            });
            
        }
        
    }
    
}

- (void)alivcLongVideoDownLoadProgressManagerComplete:(AlivcLongVideoDownloadSource *)source {
    if (source) {
        //改变状态更新进本地数据库，更新tableView
        source.downloadStatus = LongVideoDownloadTypefinish;
    }
    
    [self getCaCheInfoMemory];
    
    
}

- (void)alivcLongVideoDownLoadProgressManagerStateChanged:(AlivcLongVideoDownloadSource *)source {
    
    
    
    if (self.videoListType == AllCacheVideoType && source.longVideoModel.tvId && source.longVideoModel.tvId.length >0) {
        // 不更新
    }else {
         dispatch_async(dispatch_get_main_queue(), ^{
        AVCVideoDownloadTCell * cell = [self cellOfSource:source];
        if (cell) {
        [cell configWithLongVideoSource:source];
                
        }
             
            });
           
      
        
    }
  
}

- (void)alivcLongVideoDownLoadProgressErrorModel:(AVPErrorModel *)errorModel source:(AlivcLongVideoDownloadSource *)source {
    if (errorModel.code == ERROR_SERVER_POP_TOKEN_EXPIRED) {
        [AVPTool loadingHudToView:self.view];
        [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":source.stsSource.vid} urlType:AVPUrlTypePlayerVideoSts success:^(AVPDemoResponseModel *responseObject) {
            [AVPTool hideLoadingHudForView:self.view];
            source.stsSource = [[AVPVidStsSource alloc] initWithVid:responseObject.data.videoId accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai"];
            [source.downloader updateWithVid:source.stsSource];
            [source startDownLoad:nil];
        } failure:^(NSString *errorMsg) {
            [AVPTool hideLoadingHudForView:self.view];
            [AVPTool hudWithText:errorMsg view:self.view];
        }];
    }else if (errorModel.code == ERROR_SERVER_VOD_INVALIDAUTHINFO_EXPIRETIME) {
        [AVPTool loadingHudToView:self.view];
        [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":source.authSource.vid} urlType:AVPUrlTypePlayerVideoPlayAuth success:^(AVPDemoResponseModel *responseObject) {
            [AVPTool hideLoadingHudForView:self.view];
            source.authSource = [[AVPVidAuthSource alloc]initWithVid:responseObject.data.videoMeta.videoId playAuth:responseObject.data.playAuth region:@"cn-shanghai"];
            [source.downloader updateWithPlayAuth:source.authSource];
            [source startDownLoad:nil];
        } failure:^(NSString *errorMsg) {
            [AVPTool hideLoadingHudForView:self.view];
            [AVPTool hudWithText:errorMsg view:self.view];
        }];
    }
}

- (AVCVideoDownloadTCell *)cellOfSource:(AlivcLongVideoDownloadSource *)source {
    
    if (self.videoListType == SpecificEpisodeType && ![source.longVideoModel.tvId isEqualToString:self.tvId]) {
        return nil;
    }
    
    int index = -1 ;
    for (int i = 0; i< self.videoListArray.count ; ++i) {
        AlivcLongVideoDownloadSource * arraySource = [self.videoListArray objectAtIndex:i];
        
        if (self.videoListType == AllCacheVideoType && source.longVideoModel.tvId.length >0 && ![source.longVideoModel.tvId isEqualToString:@"(null)"]) {
            if([arraySource.longVideoModel.tvId isEqualToString:source.longVideoModel.tvId]){
                index = i;
                break;
            }
        }else if ([source.longVideoModel.videoId isEqualToString:arraySource.longVideoModel.videoId] && source.trackIndex == arraySource.trackIndex) {
            index = i;
            break;
        }
    }
    
    //未找到
    if(index == -1){
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.downloadTableView cellForRowAtIndexPath:indexPath];
    AVCVideoDownloadTCell *downloadCell = (AVCVideoDownloadTCell *)cell;

    return downloadCell;
}


#pragma mark AliyunVodPlayerViewDelegate


- (void)onBackViewClickWithAliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView {
    
    [self.playerView stop];
    self.playerView.hidden = YES;
    self.replayView.hidden = YES;
    //可以熄屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self set:UIInterfaceOrientationPortrait];
    
}

- (void)replay{
    
      self.replayView.hidden = YES;
      [self changeToPlayLocalVideo:_currentPlaySource];
}
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView happen:(AVPEventType )event {
    
    if (event == AVPEventCompletion) {
        self.replayView.hidden = NO;
        [self.playerView stop];
        [self.playerView controlViewEnable:NO];
        
    }else if (event == AVPEventPrepareDone){
        
        [self.playerView controlViewEnable:YES];
       
    }else if (event == AVPEventFirstRenderedStart){
        
        if (_currentPlaySource.watched == NO) {
            _currentPlaySource.watched = YES;
            [[AlivcLongVideoDBManager shareManager]updateSource:_currentPlaySource]; // 跟新数据库，已看
            [self.downloadTableView reloadData];
        }
    }
    
}

- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView *)playerView fullScreen:(BOOL)isFullScreen{
    if (self.isEnterBackground == YES) {
        return;
    }
    
    if (isFullScreen == NO) {
        [self.playerView stop];
        self.playerView.hidden = YES;
        self.replayView.hidden = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}
/**
 * 功能：是否锁屏
 */
- (void)aliyunVodPlayerView:(AlivcLongVideoPlayView*)playerView lockScreen:(BOOL)isLockScreen {
    self.isLock = isLockScreen;
}

- (void)onCurrentWatchProgressChangedWithVodPlayerView:(AlivcLongVideoPlayView *)playerView progress:(NSInteger)Progress {
    NSString *progressStr = [NSString stringWithFormat:@"%ld",(long)Progress];
    if ( ![progressStr isEqualToString:self.currentPlaySource.longVideoModel.watchProgress]) {
        self.currentPlaySource.longVideoModel.watchProgress = progressStr;
        [DEFAULT_DB addHistoryTVModel:self.currentPlaySource.longVideoModel];
    }else {
        [DEFAULT_DB addHistoryTVModel:self.currentPlaySource.longVideoModel];
    }
}

- (void)set:(UIInterfaceOrientation)Orientation{
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setArgument:&Orientation atIndex:2];
        [invocation invoke];
    }
    [[UIApplication sharedApplication]setStatusBarOrientation:Orientation animated:YES];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    if (self.isLock) {
        return toInterfaceOrientation = UIInterfaceOrientationPortrait;
        
    }else{
        return YES;
    }
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}
- (BOOL)shouldAutorotate{
    return !self.isLock;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (self.isLock || self.isEnterBackground) {
        
        return UIInterfaceOrientationMaskLandscapeRight;
    }else{
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }
}



- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.editArrayModel removeObserver:self forKeyPath:@"editVideoArray"];
    [self.playerView releasePlayer];
    if (_playerView) {
        [_playerView removeFromSuperview];
        _playerView  = nil;
    }
}



@end
