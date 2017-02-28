//
//  SSJDatabaseVersion13.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion13.h"
#import "SSJDatabaseQueue.h"

@implementation SSJDatabaseVersion13

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    

    
    return nil;
}

+ (NSError *)updateFundInfoTableWithDatabase:(FMDatabase *)db {
    
    // 添加渐变色开始和结束颜色字段
    if (![db executeUpdate:@"alter table bk_fund_info add cstartcolor text"]) {
        return [db lastError];
    }
    
    // 添加渐变色开始和结束颜色字段
    if (![db executeUpdate:@"alter table bk_fund_info add cendcolor text"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set cdetaildate = '00:00' where ichargetype = ?", @(SSJChargeIdTypeCircleConfig)]) {
        return [db lastError];
    }
    
    // 修改记账时分字段
    if (![db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(clientadddate,12,5) from bk_user_charge) where length(clientadddate) > 0 and ichargetype <> ?", @(SSJChargeIdTypeCircleConfig)]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(cwritedate,12,5) from bk_user_charge) where length(cdetaildate) = 0 or cdetaildate is null"]) {
        return [db lastError];
    }
    
    return nil;
}


@end
