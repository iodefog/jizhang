//
//  SSJCalenderHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJChargeMemberItem.h"

@implementation SSJCalenderHelper
+ (void)queryDataInYear:(NSInteger)year
                          month:(NSInteger)month
                        success:(void (^)(NSMutableDictionary *data))success
                        failure:(void (^)(NSError *error))failure {
    
    if (year == 0 || month > 12) {
        SSJPRINT(@"class:%@\n method:%@\n message:(year == 0 || month > 12)",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        failure(nil);
        return;
    }
    NSString *dateStr = [NSString stringWithFormat:@"%04ld-%02ld-__",(long)year,(long)month];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userid];
        if (!booksid.length) {
            booksid = userid;
        }
        
        FMResultSet *resultSet = nil;
        BOOL isShareBook = [db boolForQuery:@"select count(*) from bk_share_books where cbooksid = ?", booksid];
        if (isShareBook) {
            resultSet = [db executeQuery:@"select a.*, b.CNAME, b.CICOIN, b.CCOLOR, b.ITYPE, c.CMARK from BK_USER_CHARGE as a, BK_USER_BILL_TYPE as b, BK_SHARE_BOOKS_FRIENDS_MARK as c where a.IBILLID = b.CBILLID and a.CUSERID = b.CUSERID and a.CBOOKSID = b.CBOOKSID and a.CBILLDATE like ? and a.OPERATORTYPE <> 2 and a.CBOOKSID = ? and a.CBOOKSID = c.CBOOKSID and c.CFRIENDID = a.CUSERID and c.CUSERID = ? order by a.CBILLDATE desc, a.cdetaildate desc, a.cwritedate desc", dateStr,booksid, userid];
        } else {
            resultSet = [db executeQuery:@"select a.*, b.CNAME, b.CICOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_USER_BILL_TYPE as b where a.IBILLID = b.CBILLID and a.CUSERID = b.CUSERID and a.CBOOKSID = b.CBOOKSID and a.CBILLDATE like ? and a.OPERATORTYPE <> 2 and a.cbooksid = ? order by a.CBILLDATE desc, a.cdetaildate desc, a.cwritedate desc", dateStr,booksid];
        }
        
        if (!resultSet) {
            SSJPRINT(@"class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.userId = [resultSet stringForColumn:@"CUSERID"];
            item.imageName = [resultSet stringForColumn:@"CICOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"CWRITEDATE"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.idType = [resultSet intForColumn:@"ichargetype"];
            item.billDetailDate = [resultSet stringForColumn:@"cdetaildate"];
            if (item.idType == SSJChargeIdTypeCircleConfig) {
                item.sundryId = [resultSet stringForColumn:@"cid"];
            }
            NSString *billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            if (isShareBook) {
                item.memberNickname = [item.userId isEqualToString:userid] ? @"我" : [resultSet stringForColumn:@"CMARK"];
            }
            
            if ([result objectForKey:billDate] == nil) {
                NSMutableArray *items = [[NSMutableArray alloc]init];
                [items addObject:item];
                [result setObject:items forKey:billDate];
            }else{
                NSMutableArray *items = [result objectForKey:billDate];
                [items addObject:item];
                [result setObject:items forKey:billDate];
            }
        }
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (void)queryBalanceForDate:(NSString*)date
             success:(void (^)(double income , double expence))success
             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        double income = 0;
        double expence = 0;
        NSString *userId = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        if (!booksid.length) {
            booksid = SSJUSERID();
        }
        
        income = [db doubleForQuery:@"select sum(imoney) from bk_user_charge uc, bk_user_bill_type bt where uc.cbilldate = ? and uc.cbooksid = ? and uc.ibillid = bt.cbillid and uc.cuserid = bt.cuserid and uc.cbooksid = bt.cbooksid and bt.itype = ? and uc.operatortype <> 2",date,booksid,@(SSJBillTypeIncome)];
        
        expence = [db doubleForQuery:@"select sum(imoney) from bk_user_charge uc, bk_user_bill_type bt where uc.cbilldate = ? and uc.cbooksid = ? and uc.ibillid = bt.cbillid and uc.cuserid = bt.cuserid and uc.cbooksid = bt.cbooksid and bt.itype = ? and uc.operatortype <> 2",date,booksid,@(SSJBillTypePay)];

        SSJDispatch_main_async_safe(^{
            success(income,expence);
        });
    }];
}

+ (void)queryChargeDetailWithId:(NSString *)chargeId
                        success:(void (^)(SSJBillingChargeCellItem *chargeItem))success
                        failure:(void(^)(NSError *error))failure {
    if (!chargeId.length) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"参数chargeId无效"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"select a.* , b.* from bk_user_charge a , bk_user_bill_type b where a.ichargeid = ? and a.ibillid = b.cbillid and a.cuserid = b.cuserid and a.cbooksid = b.cbooksid", chargeId];
        if (!rs) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        while ([rs next]) {
            item.ID = chargeId;
            item.userId = [rs stringForColumn:@"cuserid"];
            item.billId = [rs stringForColumn:@"IBILLID"];
            item.imageName = [rs stringForColumn:@"CICOIN"];
            item.typeName = [rs stringForColumn:@"CNAME"];
            item.money = [rs stringForColumn:@"IMONEY"];
            item.chargeImage = [rs stringForColumn:@"CIMGURL"];
            item.chargeMemo = [rs stringForColumn:@"CMEMO"];
            item.billDate = [rs stringForColumn:@"CBILLDATE"];
            item.fundId = [rs stringForColumn:@"IFUNSID"];
            item.colorValue = [rs stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [rs boolForColumn:@"ITYPE"];
            item.billDetailDate = [rs stringForColumn:@"cdetaildate"];
            item.booksId = [rs stringForColumn:@"cbooksid"];
            item.booksId = item.booksId.length ? item.booksId : SSJUSERID();
            item.idType = [rs intForColumn:@"ichargetype"];
            item.sundryId = [rs stringForColumn:@"cid"];
        }
        [rs close];
        
        if (item.idType == SSJChargeIdTypeShareBooks) { // 共享账本
            item.memberNickname = [db stringForQuery:@"select cmark from bk_share_books_friends_mark where cuserid = ? and cbooksid = ? and cfriendid = ?", SSJUSERID(), item.booksId, item.userId];
            
            if ([item.userId isEqualToString:SSJUSERID()]) {
                item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?", item.fundId];
            }
            
            item.booksName = [db stringForQuery:@"select cbooksname from bk_share_books where cbooksid = ?", item.booksId];
            // 如果账本名称为nil，就是退出了共享账本，需要从相同账本、资金账户下的平账流水中查询账本名称
            if (!item.booksName) {
                item.booksName = [db stringForQuery:@"select t1.cmemo from bk_user_charge as t1, bk_user_charge as t2 where t1.cbooksid = t2.cbooksid and t1.ifunsid = t2.ifunsid and t1.ichargeid != t2.ichargeid and t1.ibillid in ('13', '14') and t2.ichargeid = ?", chargeId];
            }
        } else { // 个人账本
            rs = [db executeQuery:@"select fi.cacctname, bt.cbooksname from bk_user_charge as uc, bk_fund_info as fi, bk_books_type as bt where uc.ifunsid = fi.cfundid and uc.cbooksid = bt.cbooksid and uc.ichargeid = ?", item.ID];
            while ([rs next]) {
                item.fundName = [rs stringForColumn:@"cacctname"];
                item.booksName = [rs stringForColumn:@"cbooksname"];
            }
            [rs close];
            
            rs = [db executeQuery:@"select a.* , b.* from bk_member_charge as a , bk_member as b where a.ichargeid = ? and a.cmemberid = b.cmemberid and b.cuserid = ?", chargeId, SSJUSERID()];
            if (!rs) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            NSMutableArray *memberItems = [NSMutableArray arrayWithCapacity:0];
            while ([rs next]) {
                SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
                memberItem.memberId = [rs stringForColumn:@"cmemberId"];
                memberItem.memberName = [rs stringForColumn:@"cname"];
                memberItem.memberColor = [rs stringForColumn:@"ccolor"];
                [memberItems addObject:memberItem];
            }
            [rs close];
            
            if (!memberItems.count) {
                SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
                item.memberId = [NSString stringWithFormat:@"%@-0",SSJUSERID()];
                item.memberName = @"我";
                item.memberColor = @"#fc7a60";
                [memberItems addObject:item];
            }
            item.membersItem = memberItems;
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^(){
                success(item);
            })
        }
    }];
}

+ (void)deleteChargeWithItem:(SSJBillingChargeCellItem *)item
                     success:(nullable void(^)())success
                     failure:(nullable void(^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db , BOOL *rollback) {
        NSString *userId = SSJUSERID();
        NSString *booksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        if (!booksId.length) {
            booksId = userId;
        }
        
        if (![db executeUpdate:@"UPDATE BK_USER_CHARGE SET OPERATORTYPE = 2 , CWRITEDATE = ? , IVERSION = ? WHERE ICHARGEID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.ID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
                
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (void)queryShareBookStateWithBooksId:(NSString *)booksId
                              memberId:(NSString *)memberId
                               success:(void(^)(SSJShareBooksMemberState state))success
                               failure:(nullable void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select istate from bk_share_books_member where cmemberid = ? and cbooksid = ?", memberId, booksId];
        if (!rs) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJShareBooksMemberState state = SSJShareBooksMemberStateNormal;
        BOOL existed = NO;
        while ([rs next]) {
            existed = YES;
            state = [rs intForColumn:@"istate"];
        }
        [rs close];
        
        if (!existed) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"不存在查询的记录"}]);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(state);
            });
        }
    }];
}

@end
