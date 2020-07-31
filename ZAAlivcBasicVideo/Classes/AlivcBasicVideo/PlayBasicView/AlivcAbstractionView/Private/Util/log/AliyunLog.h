//
//  AliyunVodPlayerViewLog.h
//  日志类

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, AliyunPlayerViewLogFlag) {
    AliyunPlayerViewLogFlagError   =      (1 << 0),
    AliyunPlayerViewLogFlagWarn    =      (1 << 1),
    AliyunPlayerViewLogFlaginfo    =      (1 << 2),
    AliyunPlayerViewLogFlagDebug   =      (1 << 3),
    AliyunPlayerViewLogFlagVerbose =      (1 << 4),
};


typedef NS_ENUM(NSUInteger,AliyunPlayerViewLogLevel){
    
    AliyunPlayerViewLogLevelUnKnown       =  0,
    AliyunPlayerViewLogLevelError         =  AliyunPlayerViewLogFlagError,
    AliyunPlayerViewLogLevelWarn          =  AliyunPlayerViewLogFlagError   | AliyunPlayerViewLogFlagWarn,
    AliyunPlayerViewLogLevelInfo          =  AliyunPlayerViewLogFlagWarn    | AliyunPlayerViewLogFlaginfo,
    AliyunPlayerViewLogLevelDebug         =  AliyunPlayerViewLogFlaginfo    | AliyunPlayerViewLogFlagDebug,
    AliyunPlayerViewLogLevelVerbose       =  AliyunPlayerViewLogFlagDebug   | AliyunPlayerViewLogFlagVerbose,
    
    AliyunPlayerViewLogLevelAll           = NSUIntegerMax
};

#define ALYPYLog(FORMAT, ...) NSLog((@"Aliyun : [Line %d] " FORMAT),__LINE__,##__VA_ARGS__);

@interface AliyunLog : NSObject
@property (nonatomic, assign) BOOL isPrintLog;

- (void)printLogWithTag:(NSString *)tag level:(AliyunPlayerViewLogLevel)level  message:(NSString *)message;

@end











