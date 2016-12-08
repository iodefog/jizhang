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
             @"bannerItems" : @"SSJBannerItem",
             @"listAdItems" : @"SSJListAdItem"
             };
}

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"listAdItems" : @"pinnedBanner",
             @"bannerItems" : @"loopBanners",
             @"booksAdItem" : @"booksBanner"
             };
}

@end
