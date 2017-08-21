//
//  SSJUserDefaultFundAcctCreater.m
//  SuiShouJi
//
//  Created by old lang on 17/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserDefaultFundCreater.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefaultFundCreater

+ (void)createDefaultDataTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *record in [self datasWithUserId:userId]) {
        NSString *fundId = record[@"cfundid"];
        NSString *fundName = record[@"cacctname"];
        BOOL existed = [db boolForQuery:@"select count(1) from bk_fund_info where (cfundid = ?) or (cacctname = ? and cuserid = ? and operatortype <> 2)", fundId, fundName, userId];
        if (!existed) {
            BOOL successfull = [db executeUpdate:@"insert into bk_fund_info (cfundid, cacctname, cparent, ccolor, cwritedate, operatortype, iversion, cuserid, cicoin, iorder, cstartcolor, cendcolor) values (:cfundid, :cacctname, :cparent, :ccolor, :cwritedate, :operatortype, :iversion, :cuserid, :cicoin, :iorder, :cstartcolor, :cendcolor)" withParameterDictionary:record];
            if (!successfull) {
                if (error) {
                    *error = [db lastError];
                }
                return;
            }
        }
    }
}

+ (NSArray<NSDictionary *> *)datasWithUserId:(NSString *)userId {
    NSNumber *syncVersion = @(SSJSyncVersion());
    NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    return @[@{@"cfundid":[NSString stringWithFormat:@"%@-1",userId],
               @"cacctname":@"现金",
               @"cparent":@1,
               @"ccolor":@"#fc7a60",
               @"cwritedate":writeDate,
               @"operatortype":@0,
               @"iversion":syncVersion,
               @"cuserid":userId,
               @"cicoin":@"ft_cash",
               @"iorder":@1,
               @"cstartcolor":@"#fc6eac",
               @"cendcolor":@"#fb92bd"},
             
             @{@"cfundid":[NSString stringWithFormat:@"%@-2",userId],
               @"cacctname":@"储蓄卡",
               @"cparent":@2,
               @"ccolor":@"#faa94a",
               @"cwritedate":writeDate,
               @"operatortype":@0,
               @"iversion":syncVersion,
               @"cuserid":userId,
               @"cicoin":@"ft_chuxuka",
               @"iorder":@2,
               @"cstartcolor":@"#f96566",
               @"cendcolor":@"#ff8989"},
             
             @{@"cfundid":[NSString stringWithFormat:@"%@-3",userId],
               @"cacctname":@"信用卡",
               @"cparent":@3,
               @"ccolor":@"#8bb84a",
               @"cwritedate":writeDate,
               @"operatortype":@0,
               @"iversion":syncVersion,
               @"cuserid":userId,
               @"cicoin":@"ft_creditcard",
               @"iorder":@3,
               @"cstartcolor":@"#7c91f8",
               @"cendcolor":@"#9fb0fc"},
             
             @{@"cfundid":[NSString stringWithFormat:@"%@-4",userId],
               @"cacctname":@"支付宝",
               @"cparent":@14,
               @"ccolor":@"#5a98de",
               @"cwritedate":writeDate,
               @"operatortype":@0,
               @"iversion":syncVersion,
               @"cuserid":userId,
               @"cicoin":@"ft_zhifubao",
               @"iorder":@4,
               @"cstartcolor":@"#7fb4f1",
               @"cendcolor":@"#8ddcf0"},
             
             @{@"cfundid":[NSString stringWithFormat:@"%@-7",userId],
               @"cacctname":@"微信钱包",
               @"cparent":@13,
               @"ccolor":@"#5a98de",
               @"cwritedate":writeDate,
               @"operatortype":@0,
               @"iversion":syncVersion,
               @"cuserid":userId,
               @"cicoin":@"ft_weixin",
               @"iorder":@5,
               @"cstartcolor":@"#39d4da",
               @"cendcolor":@"#7fe8e0"},
             
             @{@"cfundid":[NSString stringWithFormat:@"%@-8",userId],
               @"cacctname":@"固收理财",
               @"cparent":@17,
               @"ccolor":@"#5a98de",
               @"cwritedate":writeDate,
               @"operatortype":@0,
               @"iversion":syncVersion,
               @"cuserid":userId,
               @"cicoin":@"ft_gushou",
               @"iorder":@6,
               @"cstartcolor":@"#39d4da",
               @"cendcolor":@"#7fe8e0"},
             
             @{@"cfundid":[NSString stringWithFormat:@"%@-5",userId],
               @"cacctname":@"借出款",
               @"cparent":@10,
               @"ccolor":@"#a883d8",
               @"cwritedate":writeDate,
               @"operatortype":@0,
               @"iversion":syncVersion,
               @"cuserid":userId,
               @"cicoin":@"ft_jiechukuan",
               @"iorder":@7,
               @"cstartcolor":@"#55d696",
               @"cendcolor":@"#9be2a1"},
             
             @{@"cfundid":[NSString stringWithFormat:@"%@-6",userId],
               @"cacctname":@"欠款",
               @"cparent":@11,
               @"ccolor":@"#ef6161",
               @"cwritedate":writeDate,
               @"operatortype":@0,
               @"iversion":syncVersion,
               @"cuserid":userId,
               @"cicoin":@"ft_qiankuan",
               @"iorder":@8,
               @"cstartcolor":@"#f9b656",
               @"cendcolor":@"#f7cf70"}
             ];
}

@end
