//
//  SSJAdviceItem.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAdviceItem.h"

@implementation SSJAdviceItem
+ (NSDictionary *)objectClassInArray{
    return @{
             @"messageItems" : @"SSJChatMessageItem"
             };
}

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"messageItems" : @"data"
             };
}
@end
