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
        
        // 取出所有用到的记账类型
        NSArray *userBillTypeArr = [self.db getObjectsOfClass:SSJUserBillTypeTable.class fromTable:@"BK_USER_BILL_TYPE" where:SSJUserBillTypeTable.billId.in([self.db getOneDistinctColumnOnResult:SSJUserChargeTable.billId
                                                                                                                                                                                         fromTable:@"BK_USER_CHARGE"
                                                                                                                                                                                             where:SSJUserChargeTable.userId.inTable(@"bk_user_charge") == userId
                                                                                                                                                              && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2
                                                                                                                                                              && SSJUserChargeTable.booksId == sourceBooksId])];
        
        for (SSJUserBillTypeTable *userBill in userBillTypeArr) {
            userBill.booksId = targetBooksId;
        }

        
        // 取出账本中所有的流水
        NSArray *chargeArr = [self.db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"BK_USER_CHARGE"
                                                  where:SSJUserChargeTable.userId == userId
                                                  && SSJUserChargeTable.booksId == sourceBooksId
                                                  && SSJUserChargeTable.operatorType != 2];
        
        for (SSJUserChargeTable *userCharge in chargeArr) {
            userCharge.booksId = targetBooksId;
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
