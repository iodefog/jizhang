//
//  SSJFixedFinanceProductItem.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductItem.h"
#import "FMResultSet.h"
#import "FMDatabase.h"
#import "SSJFixedFinanceProductStore.h"

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

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet inDatabase:(FMDatabase *)db {
    SSJFixedFinanceProductItem *item = [[SSJFixedFinanceProductItem alloc] init];
    item.productid = [resultSet stringForColumn:@"CPRODUCTID"];
    item.userid = [resultSet stringForColumn:@"CUSERID"];
    item.productName = [resultSet stringForColumn:@"cproductname"];
    item.remindid = [resultSet stringForColumn:@"CREMINDID"];
    item.thisfundid = [resultSet stringForColumn:@"CTHISFUNDID"];
    item.targetfundid = [resultSet stringForColumn:@"CTARGETFUNDID"];
    item.etargetfundid = [resultSet stringForColumn:@"CETARGETFUNDID"];
    item.money = [resultSet stringForColumn:@"IMONEY"];
    item.memo = [resultSet stringForColumn:@"CMEMO"];
    item.rate = [resultSet doubleForColumn:@"IRATE"];
    item.ratetype = [resultSet intForColumn:@"IRATETYPE"];
    item.time = [resultSet doubleForColumn:@"ITIME"];
    item.timetype = [resultSet intForColumn:@"ITIMETYPE"];
    item.interesttype = [resultSet intForColumn:@"INTERESTTYPE"];
    item.startdate = [resultSet stringForColumn:@"CSTARTDATE"];
    item.startDate = [item.startdate ssj_dateWithFormat:@"yyyy-MM-dd"];
    item.enddate = [resultSet stringForColumn:@"CENDDATE"];
    item.isend = [resultSet boolForColumn:@"ISEND"];
    if (![resultSet columnIsNull:@"producticon"]) {
        item.productIcon = [resultSet stringForColumn:@"productIcon"];
    }
    
    if (![resultSet columnIsNull:@"cstartcolor"] && ![resultSet columnIsNull:@"cendcolor"]) {
        item.startcolor = [resultSet stringForColumn:@"cstartcolor"];
        item.endcolor = [resultSet stringForColumn:@"cendcolor"];
    }
    return item;
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
    item.productIcon = _productIcon;
    item.startcolor = _startcolor;
    item.endcolor = _endcolor;
    return item;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}
@end
