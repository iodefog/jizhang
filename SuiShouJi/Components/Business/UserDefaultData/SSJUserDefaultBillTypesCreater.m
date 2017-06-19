//
//  SSJUserDefaultBillTypesCreater.m
//  SuiShouJi
//
//  Created by old lang on 17/5/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserDefaultBillTypesCreater.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefaultBillTypesCreater


/**
 创建哪些账本的收支类别，目前只创建日常账本的类别，如果要创建其它账本的类别，就在返回的集合中添加

 @return
 */
+ (NSSet *)booksTypesNeedToCreateBillTypes {
    return [NSSet setWithObjects:@(SSJBooksTypeDaily), nil];
}

+ (void)createDefaultDataTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet *billTypeResult = [db executeQuery:@"select id, istate, defaultOrder, ibookstype from BK_BILL_TYPE where istate <> 2 and icustom = 0 and (cparent isnull or cparent <> 'root')"];
    if (!billTypeResult) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    BOOL successfull = YES;
    NSString *date = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSSet *booksTypes = [self booksTypesNeedToCreateBillTypes];
    
    while ([billTypeResult next]) {
        NSString *billId = [billTypeResult stringForColumn:@"id"];
        int state = [billTypeResult intForColumn:@"istate"];
        NSString *order = [billTypeResult stringForColumn:@"defaultOrder"];
        NSString *booksIds = [billTypeResult stringForColumn:@"ibookstype"];
        NSArray *booksIdArr = [booksIds componentsSeparatedByString:@","];
        
        for (NSString *bkId in booksIdArr) {
            SSJBooksType type = [bkId integerValue];
            if (![booksTypes containsObject:@(type)]) {
                continue;
            }
            
            NSString *booksId = nil;
            if (type == SSJBooksTypeDaily) {
                booksId = userId;
            } else {
                booksId = [NSString stringWithFormat:@"%@-%@", userId, bkId];
                state = 1;
            }
            
            BOOL executeSuccessfull = [db executeUpdate:@"insert into bk_user_bill (cuserid, cbillid, istate, iorder, cwritedate, iversion, operatortype, cbooksid) select ?, ?, ?, ?, ?, ?, 1, ? where not exists (select * from bk_user_bill where cbillid = ? and cuserid = ? and cbooksid = ?)", userId, billId, @(state), order, date, @(SSJSyncVersion()), booksId, billId, userId, booksId];
            successfull = successfull && executeSuccessfull;
        }
    }
    
    [billTypeResult close];
    
    if (!successfull) {
        if (error) {
            *error = [db lastError];
        }
    }
}

@end
