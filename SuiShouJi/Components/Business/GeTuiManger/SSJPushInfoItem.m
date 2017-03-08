//
//  SSJPushInfoItem.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPushInfoItem.h"

@implementation SSJPushInfoItem

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"pushId" : @"pushid",
             @"pushType" : @"type",
             @"pushTitle" : @"title",
             @"pushDesc" : @"desc",
             @"pushTarget" : @"target"
             };
}


@end
