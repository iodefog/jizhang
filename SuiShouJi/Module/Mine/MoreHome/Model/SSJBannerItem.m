//
//  SSJBannerItem.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBannerItem.h"

@implementation SSJBannerItem

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"bannerImageUrl" : @"image",
             @"bannerName" : @"title",
             @"bannerUrl" : @"url"
             };
}

@end
