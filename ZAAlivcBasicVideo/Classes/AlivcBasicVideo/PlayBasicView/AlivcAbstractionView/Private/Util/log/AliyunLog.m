//
//  AliyunVodPlayerViewLog.m
//

#import "AliyunLog.h"

@implementation AliyunLog

- (instancetype)init{
    self = [super init];
    if (self) {
        _isPrintLog = NO;
    }
    return self;
}

- (void)printLogWithTag:(NSString *)tag level:(AliyunPlayerViewLogLevel)level message:(NSString *)message{
    if (!self.isPrintLog) {
        return;
    }
    NSString *tempLevel = [self aliyunPlayerViewLogLevelStringWithLevel:level];
    NSString *format = [NSString stringWithFormat:@"%@,%@,%@",tempLevel,tag,message];
    NSLog(@"%@",format);
   
}

- (NSString *)aliyunPlayerViewLogLevelStringWithLevel : (AliyunPlayerViewLogLevel)level{
    NSString *tempString = @"UnKnown";
    switch (level) {
        case AliyunPlayerViewLogLevelUnKnown:
            
            break;
        case AliyunPlayerViewLogLevelError:
        {
            tempString = @"Error";
        }
            break;
        case AliyunPlayerViewLogLevelWarn:
        {
            tempString = @"Warn";
        }
            break;
        case AliyunPlayerViewLogLevelInfo:
        {
            tempString = @"Info";
        }
            break;
        case AliyunPlayerViewLogLevelDebug:
        {
            tempString = @"Debug";
        }
            break;
        case AliyunPlayerViewLogLevelVerbose:
        {
            tempString = @"Verbose";
        }
            break;
        case AliyunPlayerViewLogLevelAll:
        {
            tempString = @"LevelAll";
        }
            break;
            
        default:
            
            break;
    }
    return tempString;
}

@end
