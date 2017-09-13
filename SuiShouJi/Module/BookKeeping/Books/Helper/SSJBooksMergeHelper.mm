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
#import "SSJOrmDatabaseQueue.h"


@implementation SSJBooksMergeHelper

+ (void)startMergeWithSourceBooksId:(NSString *)sourceBooksId
                      targetBooksId:(NSString *)targetBooksId
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure {
    @weakify(self);
    
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        [db runTransaction:^BOOL{
            @strongify(self);
            
            NSString *userId = SSJUSERID();
            
            NSNumber *targetSharebookCount = [db getOneValueOnResult:SSJShareBooksTable.AnyProperty.count() fromTable:@"BK_SHARE_BOOKS"
                                                                    where:SSJShareBooksTable.booksId == targetBooksId
                                              && SSJShareBooksTable.operatorType != 2];
            
            NSNumber *sourceShareBookCount = [db getOneValueOnResult:SSJShareBooksTable.AnyProperty.count() fromTable:@"BK_SHARE_BOOKS"
                                                                    where:SSJShareBooksTable.booksId == sourceBooksId
                                              && SSJShareBooksTable.operatorType != 2];
            
            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            
            NSMutableIndexSet *sameNameIndexs = [NSMutableIndexSet indexSet];
            
            NSMutableDictionary *sameNameDic = [NSMutableDictionary dictionaryWithCapacity:0];
            
            NSMutableArray *billIds = [NSMutableArray arrayWithCapacity:0];
            
            NSArray *userChargeBillIds = [db getOneDistinctColumnOnResult:SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE")
                                                                     fromTable:@"BK_USER_CHARGE"
                                                                         where:SSJUserChargeTable.userId.inTable(@"bk_user_charge") == userId
                                          && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2
                                          && SSJUserChargeTable.booksId == sourceBooksId];
            
            NSArray *periodConfigBillIds = [db getOneDistinctColumnOnResult:SSJChargePeriodConfigTable.billId fromTable:@"BK_CHARGE_PERIOD_CONFIG"
                                                                           where:SSJChargePeriodConfigTable.userId.inTable(@"BK_CHARGE_PERIOD_CONFIG") == userId
                                            && SSJChargePeriodConfigTable.operatorType.inTable(@"BK_CHARGE_PERIOD_CONFIG") != 2
                                            && SSJChargePeriodConfigTable.booksId == sourceBooksId];
            
            [billIds addObjectsFromArray:userChargeBillIds];
            
            [billIds addObjectsFromArray:periodConfigBillIds];
            
            // 取出所有用到的记账类型
            NSMutableArray *userBillTypeArr = [[db getObjectsOfClass:SSJUserBillTypeTable.class fromTable:@"BK_USER_BILL_TYPE" where:SSJUserBillTypeTable.billId.in(billIds)
                                                && SSJUserBillTypeTable.billId.notIn([db getOneDistinctColumnOnResult:SSJUserBillTypeTable.billId.inTable(@"BK_USER_BILL_TYPE") fromTable:@"BK_USER_BILL_TYPE"
                                                                                                                     where:SSJUserBillTypeTable.userId.inTable(@"BK_USER_BILL_TYPE") == userId
                                                                                      && SSJUserBillTypeTable.operatorType.inTable(@"BK_USER_BILL_TYPE") != 2
                                                                                      && SSJUserBillTypeTable.booksId == targetBooksId])
                                                && SSJUserChargeTable.booksId == sourceBooksId] mutableCopy];
            
            for (SSJUserBillTypeTable *userBill in userBillTypeArr) {
                NSInteger currentIndex = [userBillTypeArr indexOfObject:userBill];
                userBill.booksId = targetBooksId;
                userBill.writeDate = writeDate;
                userBill.version = SSJSyncVersion();
                userBill.operatorType = 1;
                SSJUserBillTypeTable *sameNameBill = [db getOneObjectOfClass:SSJUserBillTypeTable.class fromTable:@"BK_USER_BILL_TYPE"
                                                                            where:SSJUserBillTypeTable.billName == userBill.billName
                                                      && SSJUserBillTypeTable.booksId == targetBooksId];
                if (sameNameBill) {
                    [sameNameDic setObject:sameNameBill.billId forKey:userBill.billId];
                    [sameNameIndexs addIndex:currentIndex];
                }
                
            }
            
            [userBillTypeArr removeObjectsAtIndexes:sameNameIndexs];
            
            if (userBillTypeArr.count) {
                if (![db insertOrReplaceObjects:userBillTypeArr into:@"BK_USER_BILL_TYPE"]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并记账类型失败"}]);
                        }
                    });
                    return NO;
                };
            }
            
            
            // 取出账本中所有的流水
            NSArray *chargeArr = [db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"BK_USER_CHARGE"
                                                      where:SSJUserChargeTable.userId == userId
                                  && SSJUserChargeTable.booksId == sourceBooksId
                                  && SSJUserChargeTable.operatorType != 2
                                  && (SSJUserChargeTable. chargeType != SSJChargeIdTypeLoan || SSJUserChargeTable.chargeType != SSJChargeIdTypeRepayment || SSJUserChargeTable.chargeType != SSJChargeIdTypeTransfer)];
            
            for (SSJUserChargeTable *userCharge in chargeArr) {
                userCharge.booksId = targetBooksId;
                userCharge.writeDate = writeDate;
                userCharge.version = SSJSyncVersion();
                userCharge.operatorType = 1;
                if ([targetSharebookCount integerValue] > 0) {
                    userCharge.chargeType = SSJChargeIdTypeShareBooks;
                    userCharge.cid = targetBooksId;
                }
                if ([sameNameDic objectForKey:userCharge.billId]) {
                    userCharge.billId = [sameNameDic objectForKey:userCharge.billId];
                }
                
                // 如果是从共享账本迁入个人账本,那吧共享账本中的那条流水删除,然后拷一份到目标账本
                if ([sourceShareBookCount integerValue] > 0 && ![targetSharebookCount integerValue]) {
                    userCharge.operatorType = 2;
                    if (![db updateRowsInTable:@"BK_USER_CHARGE" onProperties:{
                        SSJUserChargeTable.operatorType,
                        SSJUserChargeTable.writeDate,
                        SSJUserChargeTable.version
                    } withObject:userCharge
                                              where:SSJUserChargeTable.chargeId == userCharge.chargeId]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并流水失败"}]);
                            }
                        });
                        return NO;
                    }
                    userCharge.chargeId = SSJUUID();
                    userCharge.operatorType = 1;
                    userCharge.chargeType = SSJChargeIdTypeNormal;
                    if (![db insertOrReplaceObject:userCharge into:@"BK_USER_CHARGE"]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并流水失败"}]);
                            }
                        });
                    }
                } else {
                    if (![db updateRowsInTable:@"BK_USER_CHARGE"
                                       onProperties:{
                                           SSJUserChargeTable.booksId,
                                           SSJUserChargeTable.writeDate,
                                           SSJUserChargeTable.version,
                                           SSJUserChargeTable.billId,
                                           SSJUserChargeTable.chargeType,
                                           SSJUserChargeTable.operatorType,
                                           SSJUserChargeTable.cid
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
                
            }
            
            // 取出账本中所有的周期记账
            NSArray *periodChargeArr = [db getObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:@"BK_CHARGE_PERIOD_CONFIG"
                                                            where:SSJChargePeriodConfigTable.userId == userId
                                        && SSJChargePeriodConfigTable.booksId == sourceBooksId
                                        && SSJChargePeriodConfigTable.operatorType != 2];
            
            for (SSJChargePeriodConfigTable *chargePeriod in periodChargeArr) {
                
                // 如果转入共享账本则把这个周期记账关掉把留在原来的账本中
                if ([targetSharebookCount integerValue] > 0) {
                    chargePeriod.writeDate = writeDate;
                    chargePeriod.version = SSJSyncVersion();
                    chargePeriod.state = 0;
                    chargePeriod.operatorType = 1;
                    if (![db updateRowsInTable:@"BK_CHARGE_PERIOD_CONFIG"
                                       onProperties:{
                                           SSJChargePeriodConfigTable.writeDate,
                                           SSJChargePeriodConfigTable.version,
                                           SSJChargePeriodConfigTable.state,
                                           SSJChargePeriodConfigTable.operatorType
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
                    if (![db insertOrReplaceObject:chargePeriod into:@"BK_CHARGE_PERIOD_CONFIG"]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并周期记账失败"}]);
                            }
                        });
                        return NO;
                    }
                    
                }
            }
            
            
            dispatch_main_async_safe(^{
                if (success) {
                    success();
                }
            });
            
            return YES;

        }];
    }];
}


+ (void)getChargeCountForBooksId:(NSString *)booksId
                               Success:(void(^)(NSNumber *chargeCount))success
                               failure:(void (^)(NSError *error))failure {
    
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        NSString *userId = SSJUSERID();
        NSNumber *chargeCount = [db getOneValueOnResult:SSJUserChargeTable.AnyProperty.count() fromTable:@"BK_USER_CHARGE"
                                                  where:SSJUserChargeTable.userId == userId
                                 && SSJUserChargeTable.booksId == booksId
                                 && SSJUserChargeTable.operatorType != 2
                                 && (SSJUserChargeTable. chargeType != SSJChargeIdTypeLoan || SSJUserChargeTable.chargeType != SSJChargeIdTypeRepayment || SSJUserChargeTable.chargeType != SSJChargeIdTypeTransfer)];
        SSJDispatch_main_async_safe(^{
            if (success) {
                success(chargeCount);
            }
        });
    }];
}

+ (void)getAllBooksItemWithExceptionId:(NSString *)exceptionId
                                    Success:(void(^)(NSArray * bookList))success
                                    failure:(void (^)(NSError *error))failure{
    
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        NSString *userId = SSJUSERID();
        
        NSMutableArray *booksItems = [NSMutableArray arrayWithCapacity:0];
        
        NSArray *normalBooksArr = [db getObjectsOfClass:SSJBooksTypeTable.class fromTable:@"BK_BOOKS_TYPE" where:SSJBooksTypeTable.userId == userId && SSJBooksTypeTable.operatorType != 2];
        
        for (SSJBooksTypeTable *booksType in normalBooksArr) {
            SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc] init];
            item.booksId = booksType.booksId;
            item.booksName = booksType.booksName;
            item.booksParent = booksType.parentType;
            item.booksCategory = SSJBooksCategoryPersional;
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
        
        NSArray *shareBooksArr = [db getObjectsOfClass:SSJShareBooksTable.class fromTable:@"BK_SHARE_BOOKS" where:SSJBooksTypeTable.booksId.in([db getOneDistinctColumnOnResult:SSJShareBooksMemberTable.booksId fromTable:@"BK_SHARE_BOOKS_MEMBER"
                                                                                                                                                                          where:SSJShareBooksMemberTable.memberId == userId
                                                                                                                                                && SSJShareBooksMemberTable.memberState == SSJShareBooksMemberStateNormal])];
        
        for (SSJShareBooksTable *shareBooksType in shareBooksArr) {
            SSJShareBookItem *item = [[SSJShareBookItem alloc] init];
            item.booksId = shareBooksType.booksId;
            item.booksName = shareBooksType.booksName;
            item.booksParent = shareBooksType.booksParent;
            item.booksCategory = SSJBooksCategoryPublic;
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
        
        SSJDispatch_main_async_safe(^{
            if (success) {
                success(booksItems);
            }
        });
    }];
    
}

@end
