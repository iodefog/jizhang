//
//  SSJAppUpdateModel.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAppUpdateModel.h"

@implementation SSJAppUpdateModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"appVersion":@"anum",
             @"upgradeType":@"type",
             @"upgradeContent":@"content",
             @"upgradeUrl":@"url"
             };
}

@end
