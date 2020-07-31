//
//  AlivcLongVideoDBManager.m
//  AliyunVideoClient_Entrance
//
//  Created by wn Mac on 2019/7/2.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcLongVideoDBManager.h"
#import "FMDB.h"

@interface AlivcLongVideoDBManager ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong) FMDatabase *database;

@end

@implementation AlivcLongVideoDBManager

+ (instancetype)shareManager {
    static AlivcLongVideoDBManager *dbManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbManager = [[AlivcLongVideoDBManager alloc]init];
    });
    return dbManager;
}

- (instancetype)init {
    if (self = [super init]) {
        
       
        NSString *homePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSLog(@"%@",homePath);
        NSString *dbPath = [homePath stringByAppendingPathComponent:@"LongVideoDBManager_SQL.sqlite"];
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            self.database = db;
            if ([db open]){
                NSLog(@"数据库创建成功");
            }else {
                NSLog(@"数据库创建失败！");
            }
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS LongVideoDownloadSourceTable (IDInteger INTEGER primary key autoincrement, title TEXT, coverURL TEXT, downloadedFilePath TEXT, vid TEXT,trackIndex INTEGER, percent INTEGER,totalDataString TEXT,downloadStatus INTEGER,tvId TEXT,tvName TEXT,firstFrameUrl TEXT,tvCoverUrl TEXT,watched INTEGER, downloadSourceType INTEGER)"];
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS LongVideoHistoryTable (IDInteger INTEGER primary key autoincrement, videoId TEXT, title TEXT, watchProgress TEXT, coverUrl TEXT, modifyTime INTEGER, isVip TEXT)"];
        }];
    }
    return self;
}

- (void)addSource:(AlivcLongVideoDownloadSource *)source {

    if ([self hasSource:source]) { return; }

    
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO LongVideoDownloadSourceTable (title ,coverURL ,downloadedFilePath ,vid ,trackIndex ,percent, totalDataString,downloadStatus,tvId,tvName,firstFrameUrl,tvCoverUrl,watched,downloadSourceType) VALUES('%@','%@','%@','%@','%d','%d','%@','%ld','%@','%@','%@','%@','%d','%ld')",source.longVideoModel.title,source.longVideoModel.coverUrl,source.downloadedFilePath,source.longVideoModel.videoId,source.trackIndex,source.percent,source.totalDataString,(long)source.downloadStatus,source.longVideoModel.tvId,source.longVideoModel.tvName,source.longVideoModel.firstFrameUrl,source.longVideoModel.tvCoverUrl,source.watched,(long)source.downloadSourceType];
    [self.database executeUpdate:sqlStr];
    
}

- (void)deleteSource:(AlivcLongVideoDownloadSource *)source {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM LongVideoDownloadSourceTable WHERE vid = '%@' AND trackIndex = '%d' ",source.longVideoModel.videoId,source.trackIndex];
        [db executeUpdate:sqlStr];
    }];
}

// AND trackIndex = '%d' ,source.trackIndex

- (void)deleteAll {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM LongVideoDownloadSourceTable"];
    }];
}

- (void)deleteSourceWithTvId:(NSString *)tvId {
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM LongVideoDownloadSourceTable WHERE tvId = '%@'",tvId];
        [db executeUpdate:sqlStr];
    }];
}


- (void)updateSource:(AlivcLongVideoDownloadSource *)source {
    
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"UPDATE LongVideoDownloadSourceTable SET title = '%@' , coverURL = '%@' , downloadedFilePath = '%@' , percent = '%d', totalDataString = '%@', downloadStatus = '%ld', watched = '%d' WHERE vid = '%@' ",source.longVideoModel.title,source.longVideoModel.coverUrl,source.downloadedFilePath,source.percent,source.totalDataString,(long)source.downloadStatus,source.watched,source.longVideoModel.videoId];
        [db executeUpdate:sqlStr];
        
        
    }];
}

- (NSArray <AlivcLongVideoDownloadSource *>*)tvSource:(NSString *)tvId {
    
    NSMutableArray *backArray = [NSMutableArray array];
    NSInteger episodeNum = 0;
    FMResultSet * set = [self.database executeQuery:@"SELECT * FROM LongVideoDownloadSourceTable"];
    while ([set next]) {
        AlivcLongVideoDownloadSource *source = [[AlivcLongVideoDownloadSource alloc] init];
          NSString * videoTvId = [set stringForColumn:@"tvId"];
        if (!videoTvId || ![videoTvId isEqualToString:tvId]) {
            continue;
        }
        
        ++ episodeNum;
        NSString *title = [set stringForColumn:@"title"];
        if (title && ![title isEqualToString:@"(null)"]) {
            source.longVideoModel.title = title;
        }
        NSString *coverURL = [set stringForColumn:@"coverURL"];
        if (coverURL && ![coverURL isEqualToString:@"(null)"]) {
            source.longVideoModel.coverUrl = coverURL;
        }
        NSString *tvCoverUrl = [set stringForColumn:@"tvCoverUrl"];
        if (tvCoverUrl && ![tvCoverUrl isEqualToString:@"(null)"]) {
            source.longVideoModel.tvCoverUrl = tvCoverUrl;
        }
        
        NSString *downloadedFilePath = [set stringForColumn:@"downloadedFilePath"];
        if (downloadedFilePath && ![downloadedFilePath isEqualToString:@"(null)"]) {
            source.downloadedFilePath = downloadedFilePath;
        }
        source.longVideoModel.videoId = [set stringForColumn:@"vid"];
        source.trackIndex = [set intForColumn:@"trackIndex"] ;
        source.percent = [set intForColumn:@"percent"];
        source.downloadStatus = [set intForColumn:@"downloadStatus"];
        source.totalDataString = [set stringForColumn:@"totalDataString"];
        source.downloadSourceType = [set intForColumn:@"downloadSourceType"];
        NSString *tvId = [set stringForColumn:@"tvId"];
        if (tvId && ![tvId isEqualToString:@"(null)"]) {
            source.longVideoModel.tvId = tvId;
        }
        source.longVideoModel.tvName = [set stringForColumn:@"tvName"];
        source.longVideoModel.firstFrameUrl = [set stringForColumn:@"firstFrameUrl"];
        source.episodeNum = episodeNum;
        source.stsSource = [[AVPVidStsSource alloc]init];
        source.stsSource.vid = source.longVideoModel.videoId;
        source.authSource = [[AVPVidAuthSource alloc]init];
        source.authSource.vid = source.longVideoModel.videoId;;
        source.watched = [set intForColumn:@"watched"];
        
        [backArray addObject:source];
    }
    return backArray.copy;
    
}

// 电视剧存在多个剧集 只获得一个

- (NSArray <AlivcLongVideoDownloadSource *>*)allSourceNoRepeatTv {
    NSMutableArray *backArray = [NSMutableArray array];
    NSMutableArray *tvIdArray = [NSMutableArray array];
    FMResultSet * set = [self.database executeQuery:@"SELECT * FROM LongVideoDownloadSourceTable"];
    while ([set next]) {
        AlivcLongVideoDownloadSource *source = [[AlivcLongVideoDownloadSource alloc] init];
        
        NSString *tvId = [set stringForColumn:@"tvId"];
        if (tvId && ![tvId isEqualToString:@"(null)"]) {
            
            if ([tvIdArray containsObject:tvId]) {
                continue;
            }
            
            source.longVideoModel.tvId = tvId;
            [tvIdArray addObject:tvId];
        }
        
        
        
        NSString *title = [set stringForColumn:@"title"];
        if (title && ![title isEqualToString:@"(null)"]) {
            source.longVideoModel.title = title;
        }
        NSString *coverURL = [set stringForColumn:@"coverURL"];
        if (coverURL && ![coverURL isEqualToString:@"(null)"]) {
            source.longVideoModel.coverUrl = coverURL;
        }
        NSString *tvCoverUrl = [set stringForColumn:@"tvCoverUrl"];
        if (tvCoverUrl && ![tvCoverUrl isEqualToString:@"(null)"]) {
            source.longVideoModel.tvCoverUrl = tvCoverUrl;
        }
        NSString *downloadedFilePath = [set stringForColumn:@"downloadedFilePath"];
        if (downloadedFilePath && ![downloadedFilePath isEqualToString:@"(null)"]) {
            source.downloadedFilePath = downloadedFilePath;
        }
        source.longVideoModel.videoId = [set stringForColumn:@"vid"];
        source.trackIndex = [set intForColumn:@"trackIndex"] ;
        source.percent = [set intForColumn:@"percent"];
        source.downloadStatus = [set intForColumn:@"downloadStatus"];
        source.totalDataString = [set stringForColumn:@"totalDataString"];
        source.downloadSourceType = [set intForColumn:@"downloadSourceType"];
        if (tvId && ![tvId isEqualToString:@"(null)"]) {
            source.longVideoModel.tvId = tvId;
        }
        source.longVideoModel.tvName = [set stringForColumn:@"tvName"];
        source.longVideoModel.firstFrameUrl = [set stringForColumn:@"firstFrameUrl"];
        source.stsSource = [[AVPVidStsSource alloc]init];
        source.stsSource.vid = source.longVideoModel.videoId;
        source.authSource = [[AVPVidAuthSource alloc]init];
        source.authSource.vid = source.longVideoModel.videoId;;
        source.watched = [set intForColumn:@"watched"];
        if ([source.longVideoModel.videoId isEqualToString:@"(null)"]) {
            source.longVideoModel.videoId = nil;
        }
        
        [backArray addObject:source];
    }
    return backArray.copy;
}

// 所有资源
- (NSArray <AlivcLongVideoDownloadSource *>*)allSource {
    NSMutableArray *backArray = [NSMutableArray array];
   
    FMResultSet * set = [self.database executeQuery:@"SELECT * FROM LongVideoDownloadSourceTable"];
    while ([set next]) {
        
        AlivcLongVideoDownloadSource *source = [[AlivcLongVideoDownloadSource alloc] init];
        
        NSString *title = [set stringForColumn:@"title"];
        if (title && ![title isEqualToString:@"(null)"]) {
            source.longVideoModel.title = title;
        }
        NSString *coverURL = [set stringForColumn:@"coverURL"];
        if (coverURL && ![coverURL isEqualToString:@"(null)"]) {
            source.longVideoModel.coverUrl = coverURL;
        }
        NSString *tvCoverUrl = [set stringForColumn:@"tvCoverUrl"];
        if (tvCoverUrl && ![tvCoverUrl isEqualToString:@"(null)"]) {
            source.longVideoModel.tvCoverUrl = tvCoverUrl;
        }
        NSString *downloadedFilePath = [set stringForColumn:@"downloadedFilePath"];
        if (downloadedFilePath && ![downloadedFilePath isEqualToString:@"(null)"]) {
            source.downloadedFilePath = downloadedFilePath;
        }
        source.longVideoModel.videoId = [set stringForColumn:@"vid"];
        source.trackIndex = [set intForColumn:@"trackIndex"] ;
        source.percent = [set intForColumn:@"percent"];
        source.downloadStatus = [set intForColumn:@"downloadStatus"];
        source.totalDataString = [set stringForColumn:@"totalDataString"];
        source.downloadSourceType = [set intForColumn:@"downloadSourceType"];
        NSString *tvId = [set stringForColumn:@"tvId"];
        if (tvId && ![tvId isEqualToString:@"(null)"]) {
            source.longVideoModel.tvId = tvId;
        }
        source.longVideoModel.tvName = [set stringForColumn:@"tvName"];
        source.longVideoModel.firstFrameUrl = [set stringForColumn:@"firstFrameUrl"];
        source.stsSource = [[AVPVidStsSource alloc]init];
        source.stsSource.vid = source.longVideoModel.videoId;
        source.authSource = [[AVPVidAuthSource alloc]init];
        source.authSource.vid = source.longVideoModel.videoId;;
        source.watched = [set intForColumn:@"watched"];
        if ([source.longVideoModel.videoId isEqualToString:@"(null)"]) {
            source.longVideoModel.videoId = nil;
        }
        
        [backArray addObject:source];
    }
    return backArray.copy;
}

- (BOOL)hasSource:(AlivcLongVideoDownloadSource *)source {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM LongVideoDownloadSourceTable WHERE vid = '%@' AND trackIndex = '%d'",source.longVideoModel.videoId,source.trackIndex];
    FMResultSet * set = [self.database executeQuery:sqlStr];
    while ([set next]) { return YES; }
    return NO;
}

- (CGFloat)cachedMemoryWithTvId:(NSString *)tvId {
    
    CGFloat occupyMemory = 0;
    NSArray *tvSourceArray = [self tvSource:tvId];
    for (AlivcLongVideoDownloadSource *tvSource in tvSourceArray) {
        NSString * subStr =  [tvSource.totalDataString substringToIndex:tvSource.totalDataString.length -1];
        CGFloat memory = [subStr floatValue];
        occupyMemory = occupyMemory + memory;
    }
    
    return occupyMemory;
    
}

/*********** 观看历史记录部分 *********/

- (void)addHistoryTVModel:(AlivcLongVideoTVModel *)model {
    NSDate *datenow = [NSDate date];
    long modifyTime = (long)[datenow timeIntervalSince1970];
    if ([self hasHistoryTVModelFromvideoId:model.videoId]) {
        //存在这个model，进行跟新
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            NSString *sqlStr = [NSString stringWithFormat:@"UPDATE LongVideoHistoryTable SET title = '%@', watchProgress = '%@', coverUrl = '%@',modifyTime = '%ld',isVip = '%@' WHERE videoId = '%@'",model.title,model.watchProgress,model.coverUrl,modifyTime,model.isVip,model.videoId];
            [db executeUpdate:sqlStr];
        }];
    }else {
        //没有这个model，新添加
        NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO LongVideoHistoryTable (videoId ,title,watchProgress,coverUrl,modifyTime,isVip) VALUES('%@','%@','%@','%@','%ld','%@')",model.videoId,model.title,model.watchProgress,model.coverUrl,modifyTime,model.isVip];
        [self.database executeUpdate:sqlStr];
    }
}

- (BOOL)hasHistoryTVModelFromvideoId:(NSString *)videoId {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM LongVideoHistoryTable WHERE videoId = '%@'",videoId];
    FMResultSet * set = [self.database executeQuery:sqlStr];
    while ([set next]) {
        [set close];
        return YES;
    }
    return NO;
}

- (void)deleteAllHistory {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM LongVideoHistoryTable"];
    }];
}

- (NSArray *)historyTVModelArray {
    NSMutableArray *backArray = [NSMutableArray array];
    FMResultSet * set = [self.database executeQuery:@"SELECT * FROM LongVideoHistoryTable Order By modifyTime Desc"];
    while ([set next]) {
        AlivcLongVideoTVModel *model = [[AlivcLongVideoTVModel alloc] init];
        model.videoId = [set stringForColumn:@"videoId"];
        model.title = [set stringForColumn:@"title"];
        model.watchProgress = [set stringForColumn:@"watchProgress"];
        model.coverUrl = [set stringForColumn:@"coverUrl"];
        model.isVip = [set stringForColumn:@"isVip"];
        [backArray addObject:model];
    }
    [set close];
    return backArray.copy;
}

@end
