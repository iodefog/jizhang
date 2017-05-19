//
//  SSJShareBooksMemberStore.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMemberStore.h"
#import "SSJDatabaseQueue.h"

@implementation SSJShareBooksMemberStore

+ (void)queryMemberItemWithMemberId:(NSString *)memberId
                            booksId:(NSString *)booksId
                            Success:(void(^)(SSJUserItem * memberItem))success
                            failure:(void(^)(NSError *error))failure 
 {
    if (memberId.length) {
        SSJPRINT(@"memberid不正确");
    }
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select bm.cicon, bf.cmark from bk_share_books_member bm,bk_share_books_friends_mark bf where bm.cmemberid = ? and bm.cmemberid = bf.cfriendid and bm.cbooksid = ? and bm.cbooksid = bf.cbooksid",memberId,booksId];
        if (!rs) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        SSJUserItem *memberItem = [[SSJUserItem alloc] init];
        
        while ([rs next]) {
            memberItem.nickName = [rs stringForColumn:@"cmark"];
            memberItem.icon = [rs stringForColumn:@"cicon"];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(memberItem);
            });
        }
    }];
}

+ (void)queryForPeriodListWithIncomeOrPayType:(SSJBillType)type
                                     memberId:(NSString *)memberId
                                      booksId:(NSString *)booksId
                                      success:(void (^)(NSArray<SSJDatePeriod *> *))success
                                      failure:(void (^)(NSError *))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        // 查询有数据的月份
        FMResultSet *result = nil;
        switch (type) {
            case SSJBillTypeIncome:
            case SSJBillTypePay: {
                NSString *incomeOrPayType = type == SSJBillTypeIncome ? @"0" : @"1";
                result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cid = ? and ichargetype = ? and b.itype = ? and b.istate <> 2 order by a.cbilldate", memberId, booksId, incomeOrPayType, SSJChargeIdTypeShareBooks];
                
            }   break;
                
            case SSJBillTypeSurplus: {
                result = [db executeQuery:@"select distinct strftime('%Y-%m', a.cbilldate) from bk_user_charge as a, bk_bill_type as b where a.cuserid = ? and a.ibillid = b.id and a.cbilldate <= datetime('now', 'localtime') and a.operatortype <> 2 and a.cid = ? and ichargetype = ? and b.istate <> 2 order by a.cbilldate", SSJUSERID(), booksId, SSJChargeIdTypeShareBooks];
                
            }   break;
                
            case SSJBillTypeUnknown:
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure(nil);
                    });
                }
                break;
        }
        
        if (!result) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *list = [NSMutableArray array];
        
        while ([result next]) {
            
            NSString *dateStr = [result stringForColumnIndex:0];
            NSDate *date = [NSDate dateWithString:dateStr formatString:@"yyyy-MM"];
            SSJDatePeriod *currentPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeMonth date:date];
            
            if (list.count) {
                // 计算当前和上次之间的周期列表
                SSJDatePeriod *lastPeriod = [list lastObject];
                NSArray *periods = [currentPeriod periodsFromPeriod:lastPeriod];
                
                for (SSJDatePeriod *period in periods) {
                    // 比较每个相邻的月周期之间的年份是否相同，不同就插入一条上个月周期的年周期
                    if (period.startDate.year != lastPeriod.startDate.year) {
                        SSJDatePeriod *yearPeriod = [SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeYear date:lastPeriod.startDate];
                        [list addObject:yearPeriod];
                    }
                    
                    [list addObject:period];
                    lastPeriod = period;
                }
            } else {
                [list addObject:currentPeriod];
            }
        }
        
        [result close];
        
        if (list.count) {
            SSJDatePeriod *firstPeriod = [list firstObject];
            SSJDatePeriod *lastPeriod = [list lastObject];
            
            // 增加最后一个年周期
            [list addObject:[SSJDatePeriod datePeriodWithPeriodType:SSJDatePeriodTypeYear date:lastPeriod.startDate]];
            
            // 增加合计（即最开始的日期到当前日期）
            [list addObject:[SSJDatePeriod datePeriodWithStartDate:firstPeriod.startDate endDate:lastPeriod.endDate]];
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(list);
            });
        }
    }];

}


@end
