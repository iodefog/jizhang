
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
#import "SSJUserChargePeriodConfigMergeTable.h"
#import "SSJUserBillTypeTableMerge.h"


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
                             [SSJUserBillTypeTableMerge class],
                             [SSJMemberTableMerge class],
                             [SSJImageSyncTableMerge class], nil];
        
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
                         mergeType:(SSJMergeDataType)type
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure {
    @weakify(self);
    [self.db runTransaction:^BOOL{
        @strongify(self);
        if (![self dropAllTempleTableInDataBase:self.db]) {
            dispatch_main_async_safe(^{
                if (failure) {
                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并开始删除临时表失败"}]);
                }
            });
        };
        
        if (![self creatAllTempleTableInDataBase:self.db]) {
            dispatch_main_async_safe(^{
                if (failure) {
                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并开始创建临时表失败"}]);
                }
            });
        };
        
        // 需要一个字典存下同名的id,key为相应的表的表明(不是临时表)
        NSMutableDictionary *sameNameIdDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        // 首先将所有数据取出存入临时表
        for (NSSet *layer in self.mergeTableClasses) {
            for (Class mergeTable in layer) {
                NSDictionary *result = [mergeTable queryDatasWithSourceUserId:sourceUserId TargetUserId:targetUserId mergeType:type FromDate:startDate ToDate:endDate inDataBase:self.db];
                
                NSError *error = [result objectForKey:@"error"];
                
                if (error) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure(error);
                        }
                    });
                    return NO;
                }
                
                NSArray *datas = [result objectForKey:@"results"];
                
                if (datas.count) {
                    if (![self.db insertOrReplaceObjects:datas into:[mergeTable tempTableName]]) {
                        dispatch_main_async_safe(^{
                            if (failure) {
                                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"合并%@表失败",[mergeTable tempTableName]]}]);
                            }
                        });
                        return NO;
                    }
                }
                
                NSDictionary *sameNameDic = [mergeTable getSameNameIdsWithSourceUserId:sourceUserId                                              TargetUserId:targetUserId withDatas:datas inDataBase:self.db];
                
                if (sameNameDic) {
                    [sameNameIdDic setObject:sameNameDic forKey:[mergeTable mergeTableName]];
                }
            }
        }
        
        // 处理每个表所关联的表,并把合并来源标的userid改为目标表的userid
        for (NSSet *layer in self.mergeTableClasses) {
            for (Class mergeTable in layer) {
                NSDictionary *sameNameIds = [sameNameIdDic objectForKey:[mergeTable mergeTableName]];
                if (![mergeTable updateRelatedTableWithSourceUserId:sourceUserId TargetUserId:targetUserId withDatas:sameNameIds inDataBase:self.db]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"更新%@关联表失败",[mergeTable tempTableName]]}]);
                        }
                    });
                    
                    return NO;
                }
            }
        }
    
        if (![self copyAllValuesFromTempDbInDataBase:self.db]) {
            dispatch_main_async_safe(^{
                if (failure) {
                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"从临时表拷贝数据失败"}]);
                }
            });
            return NO;
        }
        
        if (![self dropAllTempleTableInDataBase:self.db]) {
            dispatch_main_async_safe(^{
                if (failure) {
                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"或合并结束删除临时表失败"}]);
                }
            });
            return NO;
        };
        
//        if (type == SSJMergeDataTypeByWriteDate) {
//            if (![self.db updateRowsInTable:@"BK_USER" onProperty:SSJUserBaseTable.lastMergeTime withValue:[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] where:SSJUserBaseTable.userId == targetUserId]) {
//                dispatch_main_async_safe(^{
//                    if (failure) {
//                        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"修改资金用户最后合并时间失败"}]);
//                    }
//                });
//                return NO;
//            }
//        }
        
        dispatch_main_async_safe(^{
            if (success) {
                success();
            }
        });
        
        return YES;
    }];
    
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

- (BOOL)creatAllTempleTableInDataBase:(WCTDatabase *)db {
    if (![db createTableAndIndexesOfName:@"temp_books_type" withClass:SSJBooksTypeTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_charge_period_config" withClass:SSJChargePeriodConfigTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_user_charge" withClass:SSJUserChargeTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_user_remind" withClass:SSJUserRemindTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_fund_info" withClass:SSJFundInfoTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_loan" withClass:SSJLoanTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_member" withClass:SSJMemberTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_member_charge" withClass:SSJMembereChargeTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_user_credit" withClass:SSJUserCreditTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_credit_repayment" withClass:SSJCreditRepaymentTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_img_sync" withClass:SSJImageSyncTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_transfer_cycle" withClass:SSJTransferCycleTable.class]) {
        return NO;
    };
    
    if (![db createTableAndIndexesOfName:@"temp_user_bill_type" withClass:SSJUserBillTypeTable.class]) {
        return NO;
    };
    
    return YES;
}

- (BOOL)dropAllTempleTableInDataBase:(WCTDatabase *)db {
    if (![db dropTableOfName:@"temp_books_type"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_charge_period_config"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_user_charge"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_user_remind"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_fund_info"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_loan"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_member"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_member_charge"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_user_credit"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_credit_repayment"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_img_sync"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_transfer_cycle"]) {
        return NO;
    };
    
    if (![db dropTableOfName:@"temp_user_bill_type"]) {
        return NO;
    };
    
    return YES;
}

- (BOOL)copyAllValuesFromTempDbInDataBase:(WCTDatabase *)db {
    if ([db getAllObjectsOfClass:SSJBooksTypeTable.class fromTable:@"temp_books_type"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJBooksTypeTable.class fromTable:@"temp_books_type"] into:@"BK_BOOKS_TYPE"]) {
            return NO;
        };
    }
    
    if ([db getAllObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:@"temp_charge_period_config"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:@"temp_charge_period_config"] into:@"BK_CHARGE_PERIOD_CONFIG"]) {
            return NO;
        };

    }
    
    if ([db getAllObjectsOfClass:SSJUserChargeTable.class fromTable:@"temp_user_charge"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJUserChargeTable.class fromTable:@"temp_user_charge"] into:@"BK_USER_CHARGE"]) {
            return NO;
        };
    }
    
    if ([db getAllObjectsOfClass:SSJUserRemindTable.class fromTable:@"temp_user_remind"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJUserRemindTable.class fromTable:@"temp_user_remind"] into:@"BK_USER_REMIND"]) {
            return NO;
        };
    }
    
    if ([db getAllObjectsOfClass:SSJFundInfoTable.class fromTable:@"temp_fund_info"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJFundInfoTable.class fromTable:@"temp_fund_info"] into:@"BK_FUND_INFO"]) {
            return NO;
        };
    }
    
    if ([db getAllObjectsOfClass:SSJLoanTable.class fromTable:@"temp_loan"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJLoanTable.class fromTable:@"temp_loan"] into:@"BK_LOAN"]) {
            return NO;
        };
    }
    
    if ([db getAllObjectsOfClass:SSJMemberTable.class fromTable:@"temp_member"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJMemberTable.class fromTable:@"temp_member"] into:@"BK_MEMBER"]) {
            return NO;
        };

    }
    
    if ([db getAllObjectsOfClass:SSJMembereChargeTable.class fromTable:@"temp_member_charge"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJMembereChargeTable.class fromTable:@"temp_member_charge"] into:@"BK_MEMBER_CHARGE"]) {
            return NO;
        };

    }
    
    if ([db getAllObjectsOfClass:SSJUserCreditTable.class fromTable:@"temp_user_credit"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJUserCreditTable.class fromTable:@"temp_user_credit"] into:@"BK_USER_CREDIT"]) {
            return NO;
        };

    }

    if ([db getAllObjectsOfClass:SSJTransferCycleTable.class fromTable:@"temp_transfer_cycle"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJTransferCycleTable.class fromTable:@"temp_transfer_cycle"] into:@"BK_TRANSFER_CYCLE"]) {
            return NO;
        };

    }

    if ([db getAllObjectsOfClass:SSJImageSyncTable.class fromTable:@"temp_img_sync"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJImageSyncTable.class fromTable:@"temp_img_sync"] into:@"BK_IMG_SYNC"]) {
            return NO;
        };
    }

    if ([db getAllObjectsOfClass:SSJUserBillTypeTable.class fromTable:@"temp_user_bill_type"].count) {
        if (![db insertOrReplaceObjects:[db getAllObjectsOfClass:SSJUserBillTypeTable.class fromTable:@"temp_user_bill_type"] into:@"BK_USER_BILL_TYPE"]) {
            return NO;
        };

    }
    
    return YES;
}

- (NSString *)getCurrentUnloggedUserId {
    NSString *unLoggedUserId;
    SSJUserBaseTable *unloggedUser = [self.db getOneObjectOfClass:SSJUserBaseTable.class fromTable:@"BK_USER" where:SSJUserBaseTable.registerState == 0];
    unLoggedUserId = unloggedUser.userId;
    return unLoggedUserId;
}

- (BOOL)needToMergeOrNot {
    NSString *unloggedUserid = [self getCurrentUnloggedUserId];
    
    SSJUserBaseTable *currentUser = [self.db getOneObjectOfClass:SSJUserBaseTable.class fromTable:@"BK_USER" where:SSJUserBaseTable.userId == SSJUSERID()];
    
    // 取出未登录账户上最后一次流水修改的时间
    
    NSString *maxDateStr = [self.db getOneValueOnResult:SSJUserChargeTable.writeDate.max()
                                              fromTable:@"BK_USER_CHARGE"
                                                  where:SSJUserChargeTable.userId == unloggedUserid
                            && SSJUserChargeTable.operatorType != 2];
    
    NSDate *maxDate = [NSDate dateWithString:maxDateStr formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSDate *lastMergeDate = [NSDate dateWithString:currentUser.lastMergeTime formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    if ((!currentUser.lastMergeTime || [maxDate isLaterThan:lastMergeDate]) && SSJIsUserLogined()) {
        return YES;
    } else {
        return NO;
    }
    
}

- (SSJUserBaseTable *)getCurrentUser {
    SSJUserBaseTable *currentUser = [self.db getOneObjectOfClass:SSJUserBaseTable.class fromTable:@"BK_USER" where:SSJUserBaseTable.userId == SSJUSERID()];

    return currentUser;
}

- (void)saveLastMergeTime {
    NSString *currentDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [self.db updateRowsInTable:@"BK_USER" onProperty:SSJUserBaseTable.lastMergeTime withValue:currentDate
                         where:SSJUserBaseTable.userId == SSJUSERID()];
}

- (NSDictionary *)getStartAndEndChargeDataForUnloggedUser {
    NSMutableDictionary *dateDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *unLoggedUserId = [self getCurrentUnloggedUserId];
    
    NSString *maxDate = [self.db getOneValueOnResult:SSJUserChargeTable.billDate.max() fromTable:@"BK_USER_CHARGE"
                                               where:SSJUserChargeTable.operatorType != 2
                         && SSJUserChargeTable.userId == unLoggedUserId
                         && SSJUserChargeTable.writeDate <= [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]];
    
    NSString *minDate = [self.db getOneValueOnResult:SSJUserChargeTable.billDate.min() fromTable:@"BK_USER_CHARGE"
                                               where:SSJUserChargeTable.operatorType != 2
                         && SSJUserChargeTable.userId == unLoggedUserId
                         && SSJUserChargeTable.writeDate <= [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]];
    
    [dateDic setObject:maxDate forKey:@"maxDate"];
    
    [dateDic setObject:minDate forKey:@"minDate"];
    
    return dateDic;
    
}



@end

