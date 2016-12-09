//
//  SSJChatMessageItem.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChatMessageItem.h"

@implementation SSJChatMessageItem
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"creplyContent" : @"creply",
             @"creplyDate" : @"creplydate",
             @"caddDate" : @"cadddate",
             @"cContent" : @"ccontent"
             };
}

@end
