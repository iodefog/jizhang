//
//  SSJBannerItem.m
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAdItem.h"

@implementation SSJAdItem

+ (NSDictionary *)objectClassInArray{
    return @{
             @"bannerItems" : @"SSJBannerItem"
             };
}

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"listAdItem" : @"pinnedBanner",
             @"bannerItems" : @"loopBanners"
             };
}

@end
