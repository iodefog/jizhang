//
//  SSJFundingTypeManager.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingTypeManager.h"

@implementation SSJFundingParentmodel

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"subFunds" : @"SSJFundingParentmodel",
             };
}

@end

@interface SSJFundingTypeManager ()



@end

@implementation SSJFundingTypeManager

+ (instancetype)sharedManager {
    static SSJFundingTypeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSJFundingTypeManager alloc] init];
    });
    return manager;
}

- (NSArray *)assetsFundIds {
    return @[@"1",@"2",@"18",@"19",@"20",@"21",@"10",@"15"];
}

- (NSArray *)liabilitiesFundIds {
    return @[@"3",@"16",@"11"];
}

@end
