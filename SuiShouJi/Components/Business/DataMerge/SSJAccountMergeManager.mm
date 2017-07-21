
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
        
        
        for (NSSet *layer in self.mergeTableClasses) {
            for (Class mergeTable in layer) {
                
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
    [db createTableAndIndexesOfName:@"temp_user_charge" withClass:SSJUserChargeTable.class];
    [db createTableAndIndexesOfName:@"temp_books_type" withClass:SSJBooksTypeTableMerge.class];
}

- (void)dropAllTempleTableInDataBase:(WCTDatabase *)db {

}

@end

