//
//  SSJCreditRepaymentSyncTable.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditRepaymentSyncTable.h"

@implementation SSJCreditRepaymentSyncTable

+ (NSString *)tableName {
    return @"bk_credit_repayment";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"crepaymentid",
            @"iinstalmentcount",
            @"capplydate",
            @"ccardid",
            @"repaymentmoney",
            @"ipoundagerate",
            @"cmemo",
            @"cuserid",
            @"operatortype",
            @"cwritedate",
            @"iversion",
            @"crepaymentmonth",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"crepaymentid"];
}

- (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        NSString *repaymentid = recordInfo[@"crepaymentid"];
        NSString *instalmentcount = recordInfo[@"iinstalmentcount"];
        NSString *applydate = recordInfo[@"capplydate"];
        NSString *cardid = recordInfo[@"ccardid"];
        NSString *money = recordInfo[@"repaymentmoney"];
        NSString *poundagerate = recordInfo[@"ipoundagerate"];
        NSString *memo = recordInfo[@"cmemo"];
        NSString *userid = recordInfo[@"cuserid"];
        NSString *operatortype = recordInfo[@"operatortype"];
        NSString *writedate = recordInfo[@"cwritedate"];
        NSString *version = recordInfo[@"iversion"];
        NSString *month = recordInfo[@"crepaymentmonth"];
        
        BOOL isExsit = NO;
        NSInteger localOperatortype = 0;
        FMResultSet *rs = [db executeQuery:@"select * from bk_credit_repayment where cuserid = ? and crepaymentid = ?",userid,repaymentid];
        while ([rs next]) {
            isExsit = YES;
            localOperatortype = [rs intForColumn:@"operatortype"];
        }
        [rs close];
        
        if (!([db intForQuery:@"select count(1) from bk_credit_repayment where cuserid = ? and crepaymentmonth = ? and iinstalmentcount > 0 and operatortype <> 2",userId,month] && [instalmentcount integerValue]) || [operatortype isEqualToString:@"2"]) {
            // 首先判断当月有没有分期,如果有,则直接抛弃这条数据
            if (localOperatortype == 1 || localOperatortype == 0) {
                // 如果本地有一条已经删除的数据,则抛弃这条数据
                if (isExsit) {
                    // 判断本地是否已经存在这条数据
                    if (![db executeUpdate:@"update bk_credit_repayment set iinstalmentcount = ?, capplydate = ?, ccardid = ?, repaymentmoney = ?, ipoundagerate = ?, cmemo = ?, operatortype = ?, cwritedate = ?, iversion = ?, crepaymentmonth = ? where crepaymentid = ? and cwritedate < ? and cuserid = ?",instalmentcount,applydate,cardid,money,poundagerate,memo,operatortype,writedate,version,month,repaymentid,writedate,userId]) {
                        return NO;
                    }
                } else {
                    if (![db executeUpdate:@"insert into bk_credit_repayment (crepaymentid,iinstalmentcount,capplydate,ccardid,repaymentmoney,ipoundagerate,cmemo,operatortype,cwritedate,iversion,crepaymentmonth,cuserid) values (?,?,?,?,?,?,?,?,?,?,?,?)",repaymentid,instalmentcount,applydate,cardid,money,poundagerate,memo,operatortype,writedate,version,month,userId]) {
                        return NO;
                    }
                }
            }
            
        }
    }
    return YES;
}


@end
