//
//  AVPDemoResponseModel.m
//  AliPlayerDemo
//
//  Created by 郦立 on 2019/1/15.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import "AVPDemoResponseModel.h"

@implementation AVPDemoResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end





@implementation AVPDemoResponseDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end





@implementation AVPDemoResponseVideoListModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.uuid = [NSUUID UUID];
        self.index = 0;
        self.page = 1;
    }
    return self;
}

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"descriptionStr":@"description"}];
}

@end





@implementation AVPPlayInfoModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end





@implementation AVPVideoMetaModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end





@implementation AVPAkInfoModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

