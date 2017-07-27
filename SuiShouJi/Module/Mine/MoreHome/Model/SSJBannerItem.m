//
//  SSJBannerItem.m
//  SuiShouJi
//
//  Created by ricky on 16/9/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerItem.h"

@implementation SSJBannerItem

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"bannerImageUrl" : @"image",
             @"bannerName" : @"title",
             @"bannerUrl" : @"url",
             @"bannerType" : @"url",
             @"bannerType" : @"url"
             };
}

@end
