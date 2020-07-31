//
//  AlivcLongVideoTVModel.m
//  longVideo
//
//  Created by Aliyun on 2019/6/25.
//  Copyright © 2019 Aliyun. All rights reserved.
//

#import "AlivcLongVideoTVModel.h"

@implementation AlivcLongVideoTVModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.watchProgress = @"0";
    }
    return self;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"idStr": @"id",@"descriptionStr":@"description"}];
}

@end
