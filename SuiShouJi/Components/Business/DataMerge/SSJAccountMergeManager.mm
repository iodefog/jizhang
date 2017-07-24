
//
//  SSJAccountMergeManager.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAccountMergeManager.h"
#import <WCDB/WCDB.h>
#import "SSJBooksTypeTableMerge.h"
#import "SSJUserChargeTableMerge.h"
#import "SSJUserReminderTableMerge.h"
#import "SSJFundInfoTableMerge.h"
#import "SSJLoanTableMerge.h"
#import "SSJMemberTableMerge.h"
#import "SSJUserCreditTableMerge.h"
#import "SSJCreditRepaymentTableMerge.h"
#import "SSJImageSyncTableMerge.h"
#import "SSJTrasferCycleTableMerge.h"
#import "SSJBaseTableMerge.h"
#import "SSJUserChargePeriodConfigMergeTable.h"

@interface SSJAccountMergeManager()

@property (nonatomic, strong) WCTDatabase *db;

@property (nonatomic, strong) NSArray *mergeTableClasses;

@end

@implementation SSJAccountMergeManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSSet *firstLayer = [NSSet setWithObjects:[SSJUserReminderTableMerge class],
                             [SSJBooksTypeTableMerge class],
                             [SSJMemberTableMerge class], nil];
        
        NSSet *secondLayer = [NSSet setWithObjects:[SSJFundInfoTableMerge class],
                              [SSJUserCreditTableMerge class],
                              [SSJCreditRepaymentTableMerge class], nil];
        
        NSSet *thirdLayer = [NSSet setWithObjects:[SSJUserChargePeriodConfigMergeTable class],
                             [SSJTrasferCycleTableMerge class],
                             [SSJLoanTableMerge class], nil];
        
        NSSet *fourthLayer = [NSSet setWithObjects:[SSJUserChargeTableMerge class], nil];
        
        NSSet *fifthLayer = [NSSet setWithObjects:[SSJMemberTableMerge class], nil];
        
        
        self.mergeTableClasses = @[firstLayer, secondLayer, thirdLayer, fourthLayer, fifthLayer];

    }
    return self;
}

- (void)startMergeWithSourceUserId:(NSString *)sourceUserId
                      targetUserId:(NSString *)targetUserId
                         startDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure {
    [self.db runTransaction:^BOOL{
        [self dropAllTempleTableInDataBase:self.db];
        [self creatAllTempleTableInDataBase:self.db];
        
        // 首先将所有数据取出存入临时表
        for (NSSet *layer in self.mergeTableClasses) {
            for (Class mergeTable in layer) {
                NSDictionary *result = [mergeTable queryDatasWithSourceUserId:sourceUserId
                                                                 TargetUserId:targetUserId
                                                                    mergeType:SSJMergeDataTypeByWriteDate
                                                                     FromDate:startDate
                                                                       ToDate:endDate
                                                                   inDataBase:self.db];
                
                NSError *error = [result objectForKey:@"error"];
                
                if (error) {
                    return NO;
                }
                
                NSArray *datas = [result objectForKey:@"results"];
                
                [self.db insertOrReplaceObjects:datas into:[mergeTable tempTableName]];
            }
        }
        
        return YES;
    }];
    
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

- (void)creatAllTempleTableInDataBase:(WCTDatabase *)db {
    [db createTableAndIndexesOfName:@"temp_books_type" withClass:SSJBooksTypeTable.class];
    [db createTableAndIndexesOfName:@"temp_charge_period_config" withClass:SSJChargePeriodConfigTable.class];
    [db createTableAndIndexesOfName:@"temp_user_charge" withClass:SSJUserChargeTable.class];
    [db createTableAndIndexesOfName:@"temp_user_remind" withClass:SSJUserRemindTable.class];
    [db createTableAndIndexesOfName:@"temp_fund_info" withClass:SSJFundInfoTable.class];
    [db createTableAndIndexesOfName:@"temp_loan" withClass:SSJLoanTable.class];
    [db createTableAndIndexesOfName:@"temp_member" withClass:SSJMemberTable.class];
    [db createTableAndIndexesOfName:@"temp_member_charge" withClass:SSJMembereChargeTable.class];
    [db createTableAndIndexesOfName:@"temp_user_credit" withClass:SSJUserCreditTable.class];
    [db createTableAndIndexesOfName:@"temp_credit_repayment" withClass:SSJCreditRepaymentTable.class];
    [db createTableAndIndexesOfName:@"temp_img_sync" withClass:SSJImageSyncTable.class];
    [db createTableAndIndexesOfName:@"temp_trasfer_cycle" withClass:SSJTransferCycleTable.class];
}

- (void)dropAllTempleTableInDataBase:(WCTDatabase *)db {
    [db dropTableOfName:@"temp_books_type"];
    [db dropTableOfName:@"temp_charge_period_config"];
    [db dropTableOfName:@"temp_user_charge"];
    [db dropTableOfName:@"temp_user_remind"];
    [db dropTableOfName:@"temp_fund_info"];
    [db dropTableOfName:@"temp_loan"];
    [db dropTableOfName:@"temp_member"];
    [db dropTableOfName:@"temp_member_charge"];
    [db dropTableOfName:@"temp_user_credit"];
    [db dropTableOfName:@"temp_credit_repayment"];
    [db dropTableOfName:@"temp_img_sync"];
    [db dropTableOfName:@"temp_trasfer_cycle"];
}

@end

