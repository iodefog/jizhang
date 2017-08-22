//
//  SSJFixedFinanceProductItem.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductItem.h"
#import "FMResultSet.h"

@implementation SSJFixedFinanceProductItem
+ (NSArray *)mj_allowedPropertyNames {
    return [self valueArr];
}

+ (NSArray *)valueArr {
    return @[@"productid",@"userid",@"productName", @"remindid",@"thisfundid",@"targetfundid",@"etargetfundid",@"money",@"memo",@"rate",@"ratetype",@"time",@"timetype",@"interesttype",@"startdate",@"enddate",@"isend"];
}

+ (NSArray *)keyArr {
    return @[@"CPRODUCTID",@"CUSERID", @"cproductname", @"CREMINDID",@"CTHISFUNDID",@"CTARGETFUNDID",@"CETARGETFUNDID",@"IMONEY",@"CMEMO",@"IRATE",@"IRATETYPE",@"ITIME",@"ITIMETYPE",@"INTERESTTYPE",@"CSTARTDATE",@"CENDDATE",@"ISEND"];
}
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return [NSDictionary dictionaryWithObjects:[self valueArr]  forKeys:[self keyArr]];
}

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet {
    return nil;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJFixedFinanceProductItem *item = [[SSJFixedFinanceProductItem alloc] init];
    item.productid = _productid;
    item.userid = _userid;
    item.remindid = _remindid;
    item.thisfundid = _thisfundid;
    item.targetfundid = _targetfundid;
    item.etargetfundid = _etargetfundid;
    item.money = _money;
    item.memo = _memo;
    item.ratetype = _ratetype;
    item.time = _time;
    item.timetype = _timetype;
    item.interesttype = _interesttype;
    item.startdate = _startdate;
    item.enddate = _enddate;
    item.isend = _isend;
    return item;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}
@end
