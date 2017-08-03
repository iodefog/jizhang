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
#import "SSJBooksTypeTable.h"
#import "SSJShareBooksTable.h"
#import "SSJShareBooksMemberTable.h"
#import "SSJBooksTypeItem.h"
#import "SSJShareBookItem.h"
#import "SSJShareBooksTable.h"


@interface SSJBooksMergeHelper()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJBooksMergeHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        [WCTStatistics SetGlobalSQLTrace:^(NSString *sql) {

        }];
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

        NSNumber *targetSharebookCount = [self.db getOneValueOnResult:SSJShareBooksTable.AnyProperty.count() fromTable:@"BK_SHARE_BOOKS"
                                                       where:SSJShareBooksTable.booksId == targetBooksId
                                 && SSJShareBooksTable.operatorType != 2];

        
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSMutableIndexSet *sameNameIndexs = [NSMutableIndexSet indexSet];
        
        NSMutableDictionary *sameNameDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        // 取出所有用到的记账类型
        NSMutableArray *userBillTypeArr = [[self.db getObjectsOfClass:SSJUserBillTypeTable.class fromTable:@"BK_USER_BILL_TYPE" where:SSJUserBillTypeTable.billId.in([self.db getOneDistinctColumnOnResult:SSJUserChargeTable.billId
                                                                                                                                                                                         fromTable:@"BK_USER_CHARGE"
                                                                                                                                                                                             where:SSJUserChargeTable.userId.inTable(@"bk_user_charge") == userId
                                                                                                                                                              && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2
                                                                                                                                                              && SSJUserChargeTable.booksId == sourceBooksId])
                                    && SSJUserBillTypeTable.billId.notIn([self.db getOneDistinctColumnOnResult:SSJUserBillTypeTable.billId fromTable:@"BK_USER_BILL_TYPE"
                                                                                                         where:SSJUserBillTypeTable.userId.inTable(@"BK_USER_BILL_TYPE") == userId
                                                                                                                                                                                                                                                     && SSJUserBillTypeTable.operatorType.inTable(@"BK_USER_BILL_TYPE") != 2
                                                                                                                                                                                                                                                     && SSJUserBillTypeTable.booksId == targetBooksId])
                                            && SSJUserChargeTable.booksId == sourceBooksId] mutableCopy];
        
        for (SSJUserBillTypeTable *userBill in userBillTypeArr) {
            NSInteger currentIndex = [userBillTypeArr indexOfObject:userBill];
            userBill.booksId = targetBooksId;
            userBill.writeDate = writeDate;
            userBill.version = SSJSyncVersion();
            SSJUserBillTypeTable *sameNameBill = [self.db getOneObjectOfClass:SSJUserBillTypeTable.class fromTable:@"BK_USER_BILL_TYPE"
                                                                        where:SSJUserBillTypeTable.billName == userBill.billName
                                                  && SSJUserBillTypeTable.booksId == targetBooksId];
            if (sameNameBill) {
                [sameNameDic setObject:sameNameBill.billId forKey:userBill.billId];
                [sameNameIndexs addIndex:currentIndex];
            }
            
        }
        
        [userBillTypeArr removeObjectsAtIndexes:sameNameIndexs];
        
        if (userBillTypeArr.count) {
            if (![self.db insertOrReplaceObjects:userBillTypeArr into:@"BK_USER_BILL_TYPE"]) {
                dispatch_main_async_safe(^{
                    if (failure) {
                        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并记账类型失败"}]);
                    }
                });
                return NO;
            };
        }

        
        // 取出账本中所有的流水
        NSArray *chargeArr = [self.db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"BK_USER_CHARGE"
                                                  where:SSJUserChargeTable.userId == userId
                                                  && SSJUserChargeTable.booksId == sourceBooksId
                                                  && SSJUserChargeTable.operatorType != 2];
        
        for (SSJUserChargeTable *userCharge in chargeArr) {
            userCharge.booksId = targetBooksId;
            userCharge.writeDate = writeDate;
            userCharge.version = SSJSyncVersion();
            if ([targetSharebookCount integerValue] > 0) {
                userCharge.chargeType = SSJChargeIdTypeShareBooks;
            } else {
                userCharge.chargeType = SSJChargeIdTypeNormal;
            }
            if ([sameNameDic objectForKey:userCharge.billId]) {
                userCharge.billId = [sameNameDic objectForKey:userCharge.billId];
            }
            
            if (![self.db updateRowsInTable:@"BK_USER_CHARGE"
                               onProperties:{
                                   SSJUserChargeTable.booksId,
                                   SSJUserChargeTable.writeDate,
                                   SSJUserChargeTable.version,
                                   SSJUserChargeTable.billId,
                                   SSJUserChargeTable.chargeType
                               }
                                 withObject:userCharge
                                      where:SSJUserChargeTable.chargeId == userCharge.chargeId]) {
                dispatch_main_async_safe(^{
                    if (failure) {
                        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并流水失败"}]);
                    }
                });
                return NO;
            };
        }
        
        // 取出账本中所有的流水
        NSArray *periodChargeArr = [self.db getObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:@"BK_CHARGE_PERIOD_CONFIG"
                                                  where:SSJChargePeriodConfigTable.userId == userId
                              && SSJChargePeriodConfigTable.booksId == sourceBooksId
                              && SSJChargePeriodConfigTable.operatorType != 2];
        
        for (SSJChargePeriodConfigTable *chargePeriod in periodChargeArr) {

            // 如果转入共享账本则把这个周期记账关掉把留在原来的账本中
            if ([targetSharebookCount integerValue] > 0) {
                chargePeriod.writeDate = writeDate;
                chargePeriod.version = SSJSyncVersion();
                chargePeriod.state = 0;
                if (![self.db updateRowsInTable:@"BK_CHARGE_PERIOD_CONFIG"
                                   onProperties:{
                                       SSJChargePeriodConfigTable.writeDate,
                                       SSJChargePeriodConfigTable.version,
                                       SSJChargePeriodConfigTable.state
                                   }
                                     withObject:chargePeriod
                                          where:SSJChargePeriodConfigTable.configId == chargePeriod.configId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并周期记账失败"}]);
                        }
                    });
                    return NO;
                }
            } else {
                chargePeriod.booksId = targetBooksId;
                chargePeriod.writeDate = writeDate;
                chargePeriod.version = SSJSyncVersion();
                if ([sameNameDic objectForKey:chargePeriod.billId]) {
                    chargePeriod.billId = [sameNameDic objectForKey:chargePeriod.billId];
                }
                if (![self.db insertOrReplaceObject:chargePeriod into:@"BK_CHARGE_PERIOD_CONFIG"]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并周期记账失败"}]);
                        }
                    });
                    return NO;
                }

            }
        }
        
        
        if (success) {
            success();
        }
        
        return YES;

    }];
}


- (NSNumber *)getChargeCountForBooksId:(NSString *)booksId {
    NSString *userId = SSJUSERID();
    NSNumber *chargeCount = [self.db getOneValueOnResult:SSJUserChargeTable.AnyProperty.count() fromTable:@"BK_USER_CHARGE"
                                                   where:SSJUserChargeTable.userId == userId
                             && SSJUserChargeTable.booksId == booksId
                             && SSJUserChargeTable.operatorType != 2];
    return chargeCount;
}

- (NSArray *)getAllBooksItemWithExceptionId:(NSString *)exceptionId {
    NSString *userId = SSJUSERID();
    
    NSMutableArray *booksItems = [NSMutableArray arrayWithCapacity:0];
    
    NSArray *normalBooksArr = [self.db getObjectsOfClass:SSJBooksTypeTable.class fromTable:@"BK_BOOKS_TYPE" where:SSJBooksTypeTable.userId == userId && SSJBooksTypeTable.operatorType != 2];
    
    for (SSJBooksTypeTable *booksType in normalBooksArr) {
        SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc] init];
        item.booksId = booksType.booksId;
        item.booksName = booksType.booksName;
        item.booksParent = booksType.parentType;
        NSString *startColor = [[booksType.booksColor componentsSeparatedByString:@","] firstObject];
        NSString *endColor = [[booksType.booksColor componentsSeparatedByString:@","] lastObject];
        SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
        colorItem.startColor = startColor;
        colorItem.endColor = endColor;
        item.booksColor = colorItem;
        if (![item.booksId isEqualToString:exceptionId]) {
            [booksItems addObject:item];
        }
    }
    
    NSArray *shareBooksArr = [self.db getObjectsOfClass:SSJShareBooksTable.class fromTable:@"BK_SHARE_BOOKS" where:SSJBooksTypeTable.booksId.in([self.db getOneDistinctColumnOnResult:SSJShareBooksMemberTable.booksId fromTable:@"BK_SHARE_BOOKS_MEMBER"
                                                                                                                                                                                where:SSJShareBooksMemberTable.memberId == userId
                                                                                                                                                 && SSJShareBooksMemberTable.memberState == SSJShareBooksMemberStateNormal])];
    
    for (SSJShareBooksTable *shareBooksType in shareBooksArr) {
        SSJShareBookItem *item = [[SSJShareBookItem alloc] init];
        item.booksId = shareBooksType.booksId;
        item.booksName = shareBooksType.booksName;
        item.booksParent = shareBooksType.booksParent;
        NSString *startColor = [[shareBooksType.booksColor componentsSeparatedByString:@","] firstObject];
        NSString *endColor = [[shareBooksType.booksColor componentsSeparatedByString:@","] lastObject];
        SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
        colorItem.startColor = startColor;
        colorItem.endColor = endColor;
        item.booksColor = colorItem;
        if (![item.booksId isEqualToString:exceptionId]) {
            [booksItems addObject:item];
        }
    }

    return booksItems;
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

@end
