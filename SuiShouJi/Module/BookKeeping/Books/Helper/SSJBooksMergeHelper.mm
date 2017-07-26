//
//  SSJBooksMergeHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksMergeHelper.h"
#import <WCDB/WCDB.h>
#import "SSJUserChargeTable.h"
#import "SSJUserBillTypeTable.h"
#import "SSJChargePeriodConfigTable.h"

@interface SSJBooksMergeHelper()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJBooksMergeHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startMergeWithSourceBooksId:(NSString *)sourceBooksId
                      targetBooksId:(NSString *)targetBooksId
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure {
    @weakify(self);
    [self.db runTransaction:^BOOL{
        @strongify(self);
        
        NSString *userId = SSJUSERID();
        
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSMutableArray *sameNameBillArr = [NSMutableArray arrayWithCapacity:0];
        
        NSMutableDictionary *sameNameDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        // 取出所有用到的记账类型
        NSArray *userBillTypeArr = [self.db getObjectsOfClass:SSJUserBillTypeTable.class fromTable:@"BK_USER_BILL_TYPE" where:SSJUserBillTypeTable.billId.in([self.db getOneDistinctColumnOnResult:SSJUserChargeTable.billId
                                                                                                                                                                                         fromTable:@"BK_USER_CHARGE"
                                                                                                                                                                                             where:SSJUserChargeTable.userId.inTable(@"bk_user_charge") == userId
                                                                                                                                                              && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2
                                                                                                                                                              && SSJUserChargeTable.booksId == sourceBooksId])
                                    && SSJUserBillTypeTable.billId.notIn([self.db getOneDistinctColumnOnResult:SSJUserChargeTable.billId fromTable:@"BK_USER_CHARGE"
                                                                                                         where:SSJUserChargeTable.userId.inTable(@"bk_user_charge") == userId
                                                                                                                                                                                                                                                     && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2
                                                                                                                                                                                                                                                     && SSJUserChargeTable.booksId == targetBooksId])];
        
        for (SSJUserBillTypeTable *userBill in userBillTypeArr) {
            userBill.booksId = targetBooksId;
            userBill.writeDate = writeDate;
            userBill.version = SSJSyncVersion();
            SSJUserBillTypeTable *sameNameBill = [self.db getOneObjectOfClass:SSJUserBillTypeTable.class fromTable:@""
                                                                        where:SSJUserBillTypeTable.billName == userBill.billName
                                                  && SSJUserBillTypeTable.booksId == sourceBooksId];
            if (sameNameBill) {
                [sameNameBillArr addObject:userBill.billId];
                [sameNameDic setObject:userBill.billId forKey:sameNameBill.billId];
            }
        }
        
        [self.db insertOrReplaceObjects:userBillTypeArr into:@"BK_USER_BILL_TYPE"];

        
        // 取出账本中所有的流水
        NSArray *chargeArr = [self.db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"BK_USER_CHARGE"
                                                  where:SSJUserChargeTable.userId == userId
                                                  && SSJUserChargeTable.booksId == sourceBooksId
                                                  && SSJUserChargeTable.operatorType != 2];
        
        for (SSJUserChargeTable *userCharge in chargeArr) {
            userCharge.booksId = targetBooksId;
            userCharge.writeDate = writeDate;
            userCharge.version = SSJSyncVersion();
            if ([sameNameBillArr containsObject:userCharge.billId]) {
                userCharge.billId = [sameNameDic objectForKey:userCharge.billId];
            }
            
            [self.db updateAllRowsInTable:@"BK_USER_CHARGE" onProperties:{
                SSJUserChargeTable.booksId,
                SSJUserChargeTable.writeDate,
                SSJUserChargeTable.version,
                SSJUserChargeTable.billId
            } withObject:userCharge];
        }
        
        
    }];
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

@end
