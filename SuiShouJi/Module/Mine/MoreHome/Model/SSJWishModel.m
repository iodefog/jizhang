//
//  SSJWishModel.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishModel.h"

@implementation SSJWishModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"wishId":@"wishid",
             @"cuserId":@"cuserid",
             @"wishName":@"wishname",
             @"wishMoney":@"wishmoney",
             @"wishImage":@"wishimage",
             @"cwriteDate":@"cwritedate",
             @"operatorType":@"operatortype",
//             @"status":@"status",
             @"remindId":@"remindid",
             @"startDate":@"startdate",
             @"endDate":@"enddate",
             @"wishType":@"wishtype"
             };
}

+ (NSDictionary *)propertyMapping {
    return @{@"wishId":@"wishid",
             @"cuserId":@"cuserid",
             @"wishName":@"wishname",
             @"wishMoney":@"wishmoney",
             @"wishImage":@"wishimage",
             @"cwriteDate":@"cwritedate",
             @"operatorType":@"operatortype",
//             @"status":@"status",
             @"remindId":@"remindid",
             @"startDate":@"startdate",
             @"endDate":@"enddate",
             @"wishType":@"wishtype"
             };
}
@end
