//
//  SSJBooksAdBanner.m
//  SuiShouJi
//
//  Created by ricky on 16/11/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksAdBanner.h"

@implementation SSJBooksAdBanner

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"adImage" : @"image",
             @"hidden" : @"hide",
             @"adUrl" : @"url"
             };
}


@end
