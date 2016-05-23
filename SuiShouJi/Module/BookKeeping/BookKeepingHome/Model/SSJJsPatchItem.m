//
//  SSJJsPatchItem.m
//  SuiShouJi
//
//  Created by ricky on 16/5/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJJsPatchItem.h"

@implementation SSJJsPatchItem

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"patchVersion" : @"patchVersion",
             @"patchMD5" : @"fileMD5",
             @"patchUrl" : @"src"
             };
}


@end
