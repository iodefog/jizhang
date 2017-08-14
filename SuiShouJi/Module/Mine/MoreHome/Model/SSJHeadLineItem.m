//
//  SSJHeadLineItem.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJHeadLineItem.h"

@implementation SSJHeadLineItem

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"target":@"target_ios",
             @"headId":@"id",
             @"headContent":@"content",
             @"headType":@"type"
             };
}


- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}
@end
