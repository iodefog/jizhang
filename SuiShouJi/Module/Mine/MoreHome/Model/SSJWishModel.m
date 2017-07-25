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


- (id)copyWithZone:(nullable NSZone *)zone {
    SSJWishModel *model = [[SSJWishModel alloc] init];
    model.wishId = self.wishId;
    model.cuserId = self.cuserId;
    model.wishName = self.wishName;
    model.wishMoney = self.wishMoney;
    model.wishImage = self.wishImage;
    model.cwriteDate = self.cwriteDate;
    model.operatorType = self.operatorType;
    model.status = self.status;
    model.remindId = self.remindId;
    model.startDate = self.startDate;
    model.endDate = self.endDate;
    model.wishType = self.wishType;
    model.wishSaveMoney = self.wishSaveMoney;
    return model;
}

@end
