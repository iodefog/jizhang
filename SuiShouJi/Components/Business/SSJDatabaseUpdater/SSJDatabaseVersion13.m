//
//  SSJDatabaseVersion13.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion13.h"
#import "SSJDatabaseQueue.h"
#import "SSJFinancingGradientColorItem.h"

@implementation SSJDatabaseVersion13

+ (NSString *)dbVersion {
    return @"2.2.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    
    NSError *error = [self updateFundInfoTableWithDatabase:db];
    if (error) {
        return error;
    }
    
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
    
    // 将原有付类型是网络账户的支付宝帐户的父类型改为支付宝
    if (![db executeUpdate:@"update bk_fund_info set cparent = '14', cicoin = 'ft_zhifubao' where cacctname = '支付宝' and cparent = '7'"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", @"13", @"微信钱包", @"ft_weixin", @"root", @"-1", @"0"]) {
        return [db lastError];
    }

    if (![db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cicoin, cparent, cwritedate, operatortype) values (?, ?, ?, ?, ?, ?)", @"14", @"支付宝", @"ft_zhifubao", @"root", @"-1", @"0"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_fund_info set cmemo = '9188彩票等' where cfundid = '7'"]) {
        return [db lastError];
    }
    
    // 将没有渐变色的数据改成渐变色
    FMResultSet *result = [db executeQuery:@"select cfundid ,iorder from bk_fund_info where (length(cstartcolor) = 0 or cstartcolor is null) and cparent <> 'root' and operatortype <> 2"];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSArray *colors = [SSJFinancingGradientColorItem defualtColors];
    
    while ([result next]) {
        NSString *fundid = [result stringForColumn:@"cfundid"];
        NSString *order = [result stringForColumn:@"iorder"] ?: @"";
        NSDictionary *dic = @{@"fundid":fundid,
                              @"order":order};
        [tempArr addObject:dic];
    };
    
    for (NSDictionary *dict in tempArr) {
        NSString *fundid = [dict objectForKey:@"fundid"];
        NSString *order = [dict objectForKey:@"order"];
        NSInteger index = [order integerValue];
        if (index > 1) {
            index --;
        }
        index = index - index / 7 * 7;
    
//        if (index > 7) {
//            index = (index - 1) % 7;
//        }
//        if (index < 0) {
//            index = 0;
//        }
        SSJFinancingGradientColorItem *item = [colors objectAtIndex:index];
        if (![db executeUpdate:@"update bk_fund_info set ccolor = ?, cstartcolor = ? , cendcolor = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cfundid = ?",item.startColor,item.startColor,item.endColor,cwriteDate,@(SSJSyncVersion()),fundid]) {
            return [db lastError];
        }
    }
    
    return nil;
}


@end
