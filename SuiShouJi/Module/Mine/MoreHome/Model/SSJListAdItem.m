//
//  SSJListAdItem.m
//  SuiShouJi
//
//  Created by ricky on 16/9/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJListAdItem.h"

@implementation SSJListAdItem

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"adTitle" : @"title",
             @"hidden" : @"hide",
             @"url" : @"tourl",
             @"imageUrl" : @"imgurl",
             @"smallImage" : @"simg"
             };
}

@end
