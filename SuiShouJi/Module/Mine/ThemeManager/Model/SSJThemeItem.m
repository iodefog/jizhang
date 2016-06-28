//
//  SSJThemeItem.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeItem.h"

@implementation SSJThemeItem

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"themeId" : @"patchVersion",
             @"themeTitle" : @"name",
             @"themeImageUrl" : @"imgUrl",
             @"themeThumbImageUrl" : @"imgUrl",
             @"themeDesc" : @"desc",
             @"downLoadUrl" : @"IOSHREF",
             @"images" : @"imgs",
             @"themeSize" : @"size"
             };
}

@end
