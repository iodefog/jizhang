//
//  SSJFinancingStore.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFinancingStore.h"
#import "SSJFinancingHomeitem.h"
#import "SSJDatabaseQueue.h"

@implementation SSJFinancingStore

+ (void)saveFundingItem:(SSJFinancingHomeitem *)item
                Success:(void (^)(SSJFinancingHomeitem *item))success
                failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *editeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSString *userId = SSJUSERID();
        
        if (!item.fundingID.length) {
            item.fundingID = SSJUUID();
        }
        
        NSInteger maxOrder = [db intForQuery:@"select max(iorder) from bk_fund_info where cuserid = ? and operatortype <> 2",userId] + 1;
        
        // 判断是新增还是修改
        if (![db intForQuery:@"select count(1) from bk_fund_info where cfundid = ? and cuserid = ? and operatortype <> 2",item.fundingID,userId]) {
            item.fundOperatortype = 0;
            item.fundingOrder = maxOrder;
            // 插入资金账户表
            if (![db executeUpdate:@"insert into bk_fund_info (cfundid ,cacctname ,cicoin ,cparent ,ccolor ,cwritedate ,operatortype ,iversion ,cmemo ,cuserid , iorder ,idisplay, cstartcolor, cendcolor) values (?,?,?,?,?,?,0,?,?,?,?,1,?,?)",item.fundingID,item.fundingName,item.fundingIcon,item.fundingParent,item.startColor,editeDate,@(SSJSyncVersion()),item.fundingMemo,userId,@(maxOrder),item.startColor,item.endColor]) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            if (item.fundingAmount > 0) {
                // 如果余额大于0,在流水里插入一条平帐收入
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f",item.fundingAmount],@"1",item.fundingID,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }else if(item.fundingAmount < 0){
                // 如果余额小于0,在流水里插入一条平帐支出
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f", item.fundingAmount],@"2",item.fundingID,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }
            
        }else{
            item.fundOperatortype = 1;
            // 修改资金账户
            if (![db executeUpdate:@"update bk_fund_info set cacctname = ? , ccolor = ?, cwritedate = ?, operatortype = 1, iversion = ?, cmemo = ?, cparent = ?, cicoin = ?, cstartcolor = ?, cendcolor = ? where cfundid = ? and cuserid = ?",item.fundingName,item.fundingColor,editeDate,@(SSJSyncVersion()),item.fundingMemo,item.fundingParent,item.fundingIcon,item.startColor,item.endColor,item.fundingID,userId]) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            NSString *currentDate = [[NSDate date]formattedDateWithFormat:@"yyyy-MM-dd"];
            double originalBalance = [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b left join bk_share_books_member c on c.cbooksid = a.cbooksid and c.cmemberid = ? where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or ichargetype = ?) and b.itype = 0 and a.ifunsid = ? and (c.istate = ? or c.istate is null or a.ibillid in ('13','14'))",userId,userId,currentDate,@(SSJChargeIdTypeLoan),item.fundingID,SSJShareBooksMemberStateNormal] - [db doubleForQuery:@"select sum(a.imoney) from bk_user_charge as a, bk_bill_type as b left join bk_share_books_member c on c.cbooksid = a.cbooksid and c.cmemberid = ? where a.ibillid = b.id and a.cuserid = ? and a.operatortype <> 2 and (a.cbilldate <= ? or ichargetype = ?) and b.itype = 1 and a.ifunsid = ? and (c.istate = ? or c.istate is null or a.ibillid in ('13','14'))",userId,userId,currentDate,@(SSJChargeIdTypeLoan),item.fundingID,SSJShareBooksMemberStateNormal];
            
            double differenceBalance = item.fundingAmount - originalBalance;
            
            if (differenceBalance > 0) {
                // 如果余额大于0,在流水里插入一条平帐收入
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f",differenceBalance],@"1",item.fundingID,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }else if(differenceBalance < 0){
                // 如果余额小于0,在流水里插入一条平帐支出
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid , cuserid , imoney , ibillid , ifunsid , cwritedate , iversion , operatortype  , cbilldate ) values (?,?,?,?,?,?,?,0,?)",SSJUUID(),userId,[NSString stringWithFormat:@"%.2f", - differenceBalance],@"2",item.fundingID,editeDate,@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"]]) {
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }
            
        }
        if (success) {
            SSJDispatchMainAsync(^{
                success(item);
            });
        }
    }];
    
}

+ (void)queryFundingParentListWithFundingType:(SSJAccountType)type
                Success:(void (^)(NSArray <SSJFundingItem *> *items))success
                failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        
        FMResultSet *fundSet = [db executeQuery:@"select * from bk_fund_info where cparent = 'root' and itype = ? order by iorder",@(type)];
        
        if (!fundSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        while ([fundSet next]) {
            SSJFundingItem *item = [[SSJFundingItem alloc] init];
            item.fundingID = [fundSet stringForColumn:@"cfundid"];
            item.fundingName = [fundSet stringForColumn:@"cacctname"];
            item.fundingIcon = [fundSet stringForColumn:@"cicoin"];
            item.fundingMemo = [fundSet stringForColumn:@"cmemo"];
            [tempArr addObject:item];
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(tempArr);
            });
        }
        
    }];
}

+ (BOOL)checkWhetherSameFundingNameExsitsWith:(SSJFinancingHomeitem *)item {
    __block BOOL exsit;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *fundid = item.fundingID ? : @"";
        NSInteger count = [db intForQuery:@"select count(1) from bk_fund_info where cuserid = ? and CACCTNAME = ? and cfundid <> ? and operatortype <> 2",userId,item.fundingName,fundid];
        if (count > 0 ) {
            exsit = YES;
        } else {
            exsit = NO;
        }
    }];
    return exsit;
}

@end
