//
//  SSJFixedFinanceProductStore.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductStore.h"

#import "SSJFixedFinanceProductItem.h"
#import "SSJFixedFinanceProductChargeItem.h"
#import "SSJReminderItem.h"
#import "SSJFixedFinanceProductCompoundItem.h"
#import "SSJLoanFundAccountSelectionViewItem.h"

#import "SSJDatabaseQueue.h"
#import "SSJLocalNotificationStore.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJRecycleHelper.h"
#import "SSJFixedFinanceProductHelper.h"

@implementation SSJFixedFinanceProductStore

/**
 根据状态查询固定理财产品列表
 
 @param fundID    所属的账户ID
 @param state 状态：未结算，已结算，全部
 @param success 成功
 @param failure 失败
 */
+ (void)queryFixedFinanceProductWithFundID:(NSString *)fundID
                                      Type:(SSJFixedFinanceState)state
                                   success:(void (^)(NSArray <SSJFixedFinanceProductItem *>* resultList))success
                                   failure:(void (^)(NSError * error))failure {
    NSString *userId = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableString *sqlStr = [[NSString stringWithFormat:@"select l.*, fi.cicoin as productIcon from bk_fixed_finance_product as l, bk_fund_info as fi where l.cthisfundid = fi.cfundid and l.cuserid = ? and l.cthisfundid = ? and l.operatortype <> 2"] mutableCopy];
        switch (state) {
            case SSJFixedFinanceStateNoSettlement:
                case SSJFixedFinanceStateSettlemented:
                [sqlStr appendFormat:@" and isend = %ld ", state];
                break;
                case SSJFixedFinanceStateAll:
                break;
            default:
                break;
        }
        [sqlStr appendString:@" order by l.cstartdate desc, l.isend asc, l.imoney desc"];
        
        FMResultSet *result = [db executeQuery:sqlStr, userId, fundID ,@(state)];
        if (!result) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        while ([result next]) {
            SSJFixedFinanceProductItem *model = [SSJFixedFinanceProductItem modelWithResultSet:result];
        
            [list addObject:model];
        }
        
            [result close];
            
            if (success) {
                SSJDispatchMainAsync(^{
                    success(list);
                });
            }

    }];
}
     
#pragma mark - 编辑理财产品，新建
/**
 保存固收理财产品（新建，编辑）
 
 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)saveFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model
                            chargeModels:(NSArray <SSJFixedFinanceProductCompoundItem *>*)chargeModels
                             remindModel:(nullable SSJReminderItem *)remindModel success:(void (^)(void))success
                                 failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        // 如果当前的固定收益账户已经删除，就当作成功处理（这种情况发生在查询记录后在另一个客户端上删除了）
        int operatorType = [db intForQuery:@"select operatortype from bk_fixed_finance_product where cproductid = ?", model.productid];
        if (operatorType == 2) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
            return;
        }
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSError *error = nil;
        //是否是编辑
        BOOL isEdit = [db boolForQuery:@"select count(*) from bk_fixed_finance_product where cproductid = ? and cuserid = ? and operatortype != 2",model.productid,SSJUSERID()];
        
        //如果是编辑则删除以前的派发流水，重新生成新的历史派发流水
        if (isEdit) {
            if (![self deleteDistributedInterestWithModel:model untilDate:nil inDatabase:db error:&error]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        
        //重新生成新的历史派发流水
        NSDate *endDate;
        if ([[NSDate date] compare:[[model.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]] == NSOrderedAscending) {
            endDate = [NSDate date];
        } else {
            endDate = [[model.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1];
        }
        
        if (![self interestRecordWithModel:model investmentDate:model.startDate endDate:endDate newMoney:0 type:1 inDatabase:db error:&error]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        
        
            //存储固定理财记录
            NSMutableArray *objectArr = [NSMutableArray array];
            [objectArr addObject:model.productid];
            [objectArr addObject:model.userid.length ? model.userid : SSJUSERID()];
            [objectArr addObject:model.productName?:@""];
            [objectArr addObject: model.memo.length ? model.memo:@""];
            [objectArr addObject:model.thisfundid?:@""];
            [objectArr addObject:model.targetfundid?:@""];
            [objectArr addObject:model.etargetfundid.length ? model.etargetfundid : @""];
            [objectArr addObject:model.money?:@""];
            [objectArr addObject:@(model.rate)];
            [objectArr addObject:@(model.ratetype)];
            [objectArr addObject:@(model.time)];
            [objectArr addObject:@(model.timetype)];
            [objectArr addObject:@(model.interesttype)];
            [objectArr addObject:model.startdate?:@""];
            [objectArr addObject:model.enddate.length ? model.enddate : @""];
            [objectArr addObject:@(model.isend)];
            [objectArr addObject: model.remindid.length ? model.remindid : @""];
            [objectArr addObject:writeDate];
            [objectArr addObject:@(SSJSyncVersion())];
            
            NSArray *keyArr = @[@"cproductid",@"cuserid",@"cproductname",@"cmemo",@"cthisfundid",@"ctargetfundid",@"cetargetfundid",@"imoney",@"irate",@"iratetype",@"itime",@"itimetype",@"interesttype",@"cstartdate",@"cenddate",@"isend",@"cremindid",@"cwritedate",@"iversion"];
            
            NSMutableDictionary *modelInfo = [NSMutableDictionary dictionaryWithObjects:objectArr forKeys:keyArr];
            
            if (isEdit) {
                //编辑
                [modelInfo setObject:@(SSJOperatorTypeModify) forKey:@"operatortype"];
            } else {
                //插入
                [modelInfo setObject:@(SSJOperatorTypeCreate) forKey:@"operatortype"];
            }
            if (![db executeUpdate:@"replace into bk_fixed_finance_product (cproductid, cuserid, cproductname, cremindid, cthisfundid, ctargetfundid, cetargetfundid, imoney, cmemo, irate, iratetype, itime, itimetype, interesttype, cstartdate, cenddate, isend, cwritedate, iversion, operatortype) values (:cproductid, :cuserid, :cproductname, :cremindid, :cthisfundid, :ctargetfundid, :cetargetfundid, :imoney, :cmemo, :irate, :iratetype, :itime, :itimetype, :interesttype, :cstartdate, :cenddate, :isend, :cwritedate, :iversion, :operatortype)" withParameterDictionary:modelInfo]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        
        BOOL hasNoAddOrRed = [self queryIsChangeMoneyWithProductModel:model inDatabase:db error:&error];
        
        //是编辑并且没有追加或者删除的情况则删除掉原来的重新生成
        //更新第一条本金的billdate
        if (isEdit && hasNoAddOrRed) {// && hasNoAddOrRed && [model.money doubleValue] != [model.oldMoney doubleValue
            if (![db executeUpdate:@"update bk_user_charge set iversion = ?, operatortype = 2, cwritedate = ? where cid like (? || '_%') and (ibillid = 3 or ibillid = 4) ",@(SSJSyncVersion()),writeDate,model.productid]) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        }
        //如果是编辑并且有追加或者删除的情况则不跟新金额其他都更新
        if (isEdit && !hasNoAddOrRed) {
            //更新本账户
            if (![db executeUpdate:@"update bk_user_charge set cbilldate = ?,cmemo = ?, iversion = ?, operatortype = 1, cwritedate = ? where cid like (? || '_%') and ibillid = 3",model.startdate,model.memo,@(SSJSyncVersion()),writeDate,model.productid]) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
            //更新目标账户
            if (![db executeUpdate:@"update bk_user_charge set ifunsid = ?, cbilldate = ?,cmemo = ?, iversion = ?, operatortype = 1, cwritedate = ? where cid like (? || '_%') and ibillid  = 4",model.targetfundid,model.startdate,model.memo,@(SSJSyncVersion()),writeDate,model.productid]) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        }
        
        //存储流水记录
        if (!isEdit || (isEdit && hasNoAddOrRed)) {//新建或者没有追加或者赎回的时候
            NSDate *lastDate = [NSDate date];
            for (SSJFixedFinanceProductCompoundItem *cmodel in chargeModels) {
                NSDate *writeDate = [lastDate dateByAddingSeconds:1];
                cmodel.chargeModel.writeDate = writeDate;
                cmodel.targetChargeModel.writeDate = writeDate;
                cmodel.interestChargeModel.writeDate = writeDate;
                lastDate = writeDate;
                
                if (![self saveFixedFinanceProductChargeWithModel:cmodel item:model inDatabase:db error:&error]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure(error);
                        });
                    }
                    return;
                }
            }
        }
        
        // 存储提醒记录
        if (remindModel) {
            remindModel.fundId = model.productid;
            NSError *error = [SSJLocalNotificationStore saveReminderWithReminderItem:remindModel inDatabase:db];
            if (error) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        
        // 修改固定理财账户的可见状态
        if (![db executeUpdate:@"update bk_fund_info set idisplay = 1, iversion = ?, operatortype = 1, cwritedate = ? where cfundid = ?", @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], [NSString stringWithFormat:@"%@-8",SSJUSERID()]]) {
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

/**
 *  查询固收理财产品详情
 *
 *  @param fixedFinanceProductID    理财产品id
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryForFixedFinanceProduceWithProductID:(NSString *)fixedFinanceProductID
                            success:(void (^)(SSJFixedFinanceProductItem *model))success
                            failure:(void (^)(NSError *error))failure {
    if (!fixedFinanceProductID.length) {
        SSJDispatchMainAsync(^{
            NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"借贷ID不能为空"}];
            failure(error);
        });
        return;
    }
    
    NSString *userId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select l.* , fi.cstartcolor, fi.cendcolor from bk_fixed_finance_product l, bk_fund_info fi where l.cproductid = ? and l.cuserid = ? and l.cthisfundid = fi.cfundid",fixedFinanceProductID,userId];
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJFixedFinanceProductItem *item = [[SSJFixedFinanceProductItem alloc] init];
        while ([resultSet next]) {
            item = [SSJFixedFinanceProductItem modelWithResultSet:resultSet];
        }
        [resultSet close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(item);
            });
        }
        
    }];
}

/**
 查询当前本金
 
 *  @param fixedFinanceProductID    理财产品id
 @return 本金
 */
+ (double)queryForFixedFinanceProduceCurrentMoneyWothWithProductID:(NSString *)fixedFinanceProductID {
    __block double money = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        money = [db doubleForQuery:@"select imoney from bk_fixed_finance_product where cproductid = ? and cuserid = ? and operatortype != 2",fixedFinanceProductID,SSJUSERID()];
    }];
    return money;
}

/**
 查询当前利息和
 
 *  @param fixedFinanceProductID    理财产品id
 @return 利息
 */
+ (double)queryForFixedFinanceProduceInterestiothWithProductID:(NSString *)fixedFinanceProductID {
    __block double interest = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        interest = [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ?",fixedFinanceProductID,@(SSJChargeIdTypeFixedFinance),@"19",SSJUSERID()];
    }];
    return interest;
}

/**
 查询一定时间内利息和
 
 *  @param fixedFinanceProductID    理财产品id
 @return 利息
 */
+ (double)queryForFixedFinanceProduceInterestiothWithProductID:(NSString *)fixedFinanceProductID startDate:(NSString *)startDate endDate:(NSString *)endDate {
    __block double interest = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        interest = [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ? and cbilldate between ? and ?",fixedFinanceProductID,@(SSJChargeIdTypeFixedFinance),@"19",SSJUSERID(),startDate,endDate];
    }];
    return interest;
}

+ (double)queryForFixedFinanceProduceLixiWithProductID:(NSString *)fixedFinanceProductID inDatabase:(FMDatabase *)db {
    double interest = 0;
        interest = [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ?",fixedFinanceProductID,@(SSJChargeIdTypeFixedFinance),@"19",SSJUSERID()];
    return interest;
}

+ (double)queryForFixedFinanceProduceJieSuanInterestiothWithProductID:(NSString *)fixedFinanceProductID {
    __block double interest = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        double money1 = [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ?",fixedFinanceProductID,@(SSJChargeIdTypeFixedFinance),@"19",SSJUSERID()];

        //+—平账利息
        double money2 = [db doubleForQuery:@"select imoney from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ?",fixedFinanceProductID,@(SSJChargeIdTypeFixedFinance),@"21",SSJUSERID()];
        
       double money3 = [db doubleForQuery:@"select imoney from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ?",fixedFinanceProductID,@(SSJChargeIdTypeFixedFinance),@"22",SSJUSERID()];
        interest = money1 + money2 - money3;
    }];
    
    return interest;
}

//查询说有手续费和
+ (double)querySettmentInterestWithProductID:(NSString *)fixedFinanceProductID {
    double interest = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ?",fixedFinanceProductID,@(SSJChargeIdTypeFixedFinance),@"20",SSJUSERID()];
    }];
    return interest;
}

+ (double)queryForFixedFinanceProduceInterestiothWithProductID:(NSString *)fixedFinanceProductID inDatabase:(FMDatabase *)db {
    double interest = 0;
        interest = [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ?",fixedFinanceProductID,@(SSJChargeIdTypeFixedFinance),@"19",SSJUSERID()];
    return interest;
}


+ (NSString *)queryFixedFinanceProductNewChargeBillDateWithModel:(SSJFixedFinanceProductItem *)model {
    __block NSString *date;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        date = [db stringForQuery:@"select max(cbilldate) from bk_user_charge where operatortype != 2 and ichargetype = ? and cuserid = ? and cid like (? || '%')",@(SSJChargeIdTypeFixedFinance),SSJUSERID(),model.productid];
    }];
    return date;
}


/**
 删除固收理财账户
 
 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)deleteFixedFinanceProductAccountWithModel:(NSArray <SSJFixedFinanceProductItem *> *)model success:(void (^)(void))success
                                          failure:(void (^)(NSError *error))failure {
    NSString *userId = SSJUSERID();
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        NSError *error = nil;
        for (SSJFixedFinanceProductItem *item in model) {
            if (![self deleteFixedFinanceProductWithModel:item inDatabase:db success:nil failure:nil]) {
                if (failure) {
                    *rollback = YES;
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return ;
            }
        }
        // 将固定理财的operatortype改为2
        if (![db executeUpdate:@"update bk_fund_info set idisplay = 0， operatortype = ?, iversion = ?, cwritedate = ? where cfundid = ?", @1, @(SSJSyncVersion()), writeDate, [NSString stringWithFormat:@"%@-8",SSJUSERID()]]) {
            if (failure) {
                *rollback = YES;
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return ;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

/**
 删除固收理财产品
 
 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)deleteFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model success:(void (^)(void))success
                                   failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        //将理财产品operator = 2
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSError *error = nil;
        if (![db executeUpdate:@"update bk_fixed_finance_product set operatortype = ?, iversion = ?, cwritedate = ? where cproductid = ? and cuserid = ?", @(SSJOperatorTypeDelete), @(SSJSyncVersion()), writeDate, model.productid,SSJUSERID()]) {
            if (failure) {
                *rollback = YES;
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return ;
        }
        
        //删除所有流水
        if (![self deleteFixedFinanceProductModel:model inDatabase:db forUserId:SSJUSERID() writeDate:writeDate needcreateRecycleRecord:NO error:&error]) {
            if (failure) {
                *rollback = YES;
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return ;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (BOOL)deleteFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model
                                inDatabase:(FMDatabase *)db
                                   success:(void (^)(void))success
                                   failure:(void (^)(NSError *error))failure {
    //将理财产品operator = 2
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSError *error = nil;
    if (![db executeUpdate:@"update bk_fixed_finance_product set operatortype = ?, iversion = ?, cwritedate = ? where cproductid = ? and cuserid = ?", @(SSJOperatorTypeDelete), @(SSJSyncVersion()), writeDate, model.productid,SSJUSERID()]) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure(error);
            });
        }
        return NO;
    }
    
    //删除所有流水
    if (![self deleteFixedFinanceProductModel:model inDatabase:db forUserId:SSJUSERID() writeDate:writeDate needcreateRecycleRecord:NO error:&error]) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure(error);
            });
        }
        return NO;
    }
    return YES;
}


/**
 删除某个固定理财账户的所有流水

 @param model <#model description#>
 @param db <#db description#>
 @param userId <#userId description#>
 @param writeDate <#writeDate description#>
 @param needcreateRecycleRecord <#needcreateRecycleRecord description#>
 @param error <#error description#>
 @return <#return value description#>
 */
+ (BOOL)deleteFixedFinanceProductModel:(SSJFixedFinanceProductItem *)model
                            inDatabase:(FMDatabase *)db
                             forUserId:(NSString *)userId
                             writeDate:(NSString *)writeDate
               needcreateRecycleRecord:(BOOL)needcreateRecycleRecord
                                 error:(NSError **)error {
    // 将和固定理财相关的流水operatortype改为2
    if (![db executeUpdate:@"update bk_user_charge set operatortype = ?, iversion = ?, cwritedate = ? where cid like (? || '%') and ichargetype = ?", @(SSJOperatorTypeDelete), @(SSJSyncVersion()), writeDate, model.productid, @(SSJChargeIdTypeFixedFinance)]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    // 如果有提醒将提醒的operatortype改为2
    if (model.remindid.length) {
        if (![db executeUpdate:@"update bk_user_remind set operatortype = ?, iversion = ?, cwritedate = ? where cremindid = ?", @2, @(SSJSyncVersion()), writeDate, model.remindid]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        //取消提醒
        SSJReminderItem *remindItem = [[SSJReminderItem alloc]init];
        remindItem.remindId = model.remindid;
        remindItem.userId = model.userid;
        [SSJLocalNotificationHelper cancelLocalNotificationWithremindItem:remindItem];
    }
    
    if (needcreateRecycleRecord) {
        if (![SSJRecycleHelper createRecycleRecordWithID:model.productid recycleType:SSJRecycleTypeFund writeDate:writeDate database:db error:error]) {
            return NO;
        }
    }

    return YES;
}


/**
 通过一条chareitem查找对应的另外几条流水
 @param oneChargeItem <#oneChargeItem description#>
 @return <#return value description#>
 */
+ (void)queryOtherFixedFinanceProductChargeItemWithChareItem:(SSJFixedFinanceProductChargeItem *)oneChargeItem success:(void (^)(NSArray <SSJFixedFinanceProductChargeItem *> * charegItemArr))success failure:(void (^)(NSError *error))failure {
    NSString *uuid = [[oneChargeItem.chargeId componentsSeparatedByString:@"_"] firstObject];
    if (!uuid.length) return;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
       FMResultSet *result = [db executeQuery:@"select * from bk_user_charge where ichargeid like (? || '_%') and cuserid = ? and cid = ? and operatortype != 2",uuid,SSJUSERID(),oneChargeItem.cid];
        if (!result) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        NSMutableArray *tempArr = [NSMutableArray array];
        while ([result next]) {
            SSJFixedFinanceProductChargeItem *item = [SSJFixedFinanceProductChargeItem modelWithResultSet:result];
            [tempArr addObject:item];
        }
        [result close];
        if (success) {
            SSJDispatchMainAsync(^{
                success(tempArr);
            });
        }
    }];
}

+ (BOOL)queryOtherFixedFinanceProductChargeItemWithChareItem:(SSJFixedFinanceProductChargeItem *)oneChargeItem inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    return YES;
}

/**
 根据一条流水查找对应流水chargeid
 */
+ (NSString *)queryChargeIdWithChargeItem:(SSJFixedFinanceProductChargeItem *)oneChargeItem inDatabase:(FMDatabase *)db error:(NSError **)error {
    __block NSString *charegid;
    NSString *uuid = [[oneChargeItem.chargeId componentsSeparatedByString:@"_"] firstObject];
    if (!uuid.length) return @"";
       charegid = [db stringForQuery:@"select ichargeid from bk_user_charge where ichargeid like (? || '_%') and cuserid = ? and cid = ? and operatortype != 2",uuid,SSJUSERID(),oneChargeItem.cid];
    return charegid;
}

#pragma mark - 固定理财流水

/**
 查询某个固定理财所有的流水列表
 
 @param model 固定理财模型
 @param resultList 返回的流水列表
 @param success 成功的回调
 @param failure 失败的回调
 */
+ (void)queryFixedFinanceProductChargeListWithModel:(SSJFixedFinanceProductItem *)model
                                            success:(void (^)(NSArray <SSJFixedFinanceProductChargeItem *>*resultList))success
                                            failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select ichargeid, ifunsid, ibillid, imoney, cmemo, cbilldate, cwritedate, cid from bk_user_charge as uc where cuserid = ? and ifunsid = ? and cid like (? || '%') and ichargetype = ? and operatortype <> 2 order by cbilldate, cwritedate", model.userid, model.thisfundid, model.productid, @(SSJChargeIdTypeFixedFinance)];
        NSMutableArray *chargeModels = [NSMutableArray array];
        
        while ([resultSet next]) {
            SSJFixedFinanceProductChargeItem *item = [SSJFixedFinanceProductChargeItem modelWithResultSet:resultSet];
            [chargeModels addObject:item];
//            item.cid
        }
        
        [resultSet close];
        
        //分类
        NSArray *compModels = [self updateFinanceChargeTypeWithModel:chargeModels];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(compModels);
            });
        }
    }];
}

/**
 删除固定理财的某个流水
 
 @param model 流水模型
 @param success 删除成功的回调
 @param failure 删除失败的回调，error code为1代表删除流水后借贷剩余金额会小于0
 */
+ (void)deleteFixedFinanceProductChargeWithModel:(SSJFixedFinanceProductChargeItem *)model
                                    productModel:(SSJFixedFinanceProductItem *)productModel
                                         success:(void (^)(void))success
                                         failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSError *error = nil;

        //派发利息，平账情况
        if (model.chargeType == SSJFixedFinCompoundChargeTypeInterest || model.chargeType == SSJFixedFinCompoundChargeTypePinZhangBalanceIncrease || model.chargeType == SSJFixedFinCompoundChargeTypePinZhangBalanceDecrease) {
            //单向面流水
            if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, operatortype = 2 where cuserid = ? and ichargeid = ?",writeDateStr,SSJUSERID(),model.chargeId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        } else if (model.chargeType == SSJFixedFinCompoundChargeTypeAdd) {//追加
        //删除追加流水
            if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, operatortype = 2 where cuserid = ? and ichargeid = ?",writeDateStr,SSJUSERID(),model.chargeId]) {
                 *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        //删除追加对应的流水
            //1,查询对应流水的chargeid
            NSString *charegId = [self queryChargeIdWithChargeItem:model inDatabase:db error:&error];
            if (!charegId.length) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
            if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, operatortype = 2 where cuserid = ? and ichargeid = ?",writeDateStr,SSJUSERID(),charegId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        //删除派发流水
            
        //重新生成派发流水
            
        //修改本金
            //删除以前派发的利息流水//重新派发利息流水
            if (![self deleteDistributedInterestWithModel:productModel untilDate:[model.billDate dateByAddingDays:1] inDatabase:db error:&error]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            //重新生成新的历史派发流水
            NSDate *endDate;
            if ([[NSDate date] compare:[[productModel.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]] == NSOrderedAscending) {
                endDate = [NSDate date];
            } else {
                endDate = [[productModel.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1];
            }
            //按照新的金额重新派发流水
            //查询原始本金
            double oldMoney = [db doubleForQuery:@"select imoney from bk_fixed_finance_product where cuserid = ? and cproductid = ? and operatortype != 2",SSJUSERID(),productModel.productid];
            double newMoney = oldMoney;
            newMoney = oldMoney - model.money;
            
            if (![self interestRecordWithModel:productModel investmentDate:model.billDate endDate:endDate newMoney:newMoney type:2 inDatabase:db error:&error]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            //修改本金
            if (![db executeUpdate:@"update bk_fixed_finance_product set cwritedate = ?, imoney = ? where cuserid = ? and cproductid = ? and operatortype != 2",writeDateStr,@(newMoney),productModel.userid,productModel.productid]) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        } else if (model.chargeType == SSJFixedFinCompoundChargeTypeRedemption) {//赎回
            
        }  else {//手续费，利息，追加，赎回（手续费1赎回，2结算）
            //双向流水
            
        }

        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}


/**
 删除赎回流水
 
 @param model 流水模型
 @param success 删除成功的回调
 @param failure 删除失败的回调，error code为1代表删除流水后借贷剩余金额会小于0
 */
+ (void)deleteFixedFinanceProductRedemChargeWithModel:(NSArray<SSJFixedFinanceProductChargeItem *> *)modelArr
                                    productModel:(SSJFixedFinanceProductItem *)productModel
                                         success:(void (^)(void))success
                                              failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        NSError *error = nil;
        NSDate *billDate;
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        double shouxufeiMoney = 0;
        for (SSJFixedFinanceProductChargeItem *item in modelArr) {
            billDate = item.billDate;
            if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, operatortype = 2 where cuserid = ? and ichargeid = ?",writeDateStr,SSJUSERID(),item.chargeId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
            if ([item.billId isEqualToString:@"20"]) {
                shouxufeiMoney = item.money;
            }
        }
        //删除派发流水
        //重新生成派发流水
        //修改本金
        //删除以前派发的利息流水//重新派发利息流水
        if (![self deleteDistributedInterestWithModel:productModel untilDate:[billDate dateByAddingDays:1] inDatabase:db error:&error]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        //重新生成新的历史派发流水
        NSDate *endDate;
        if ([[NSDate date] compare:[[productModel.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]] == NSOrderedAscending) {
            endDate = [NSDate date];
        } else {
            endDate = [[productModel.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1];
        }
        //按照新的金额重新派发流水
        //查询原始本金
        double oldMoney = [db doubleForQuery:@"select imoney from bk_fixed_finance_product where cuserid = ? and cproductid = ? and operatortype != 2",SSJUSERID(),productModel.productid];
        
        
        double newMoney = oldMoney;
        newMoney = oldMoney + [productModel.oldMoney doubleValue] + shouxufeiMoney;
        
        if (![self interestRecordWithModel:productModel investmentDate:billDate endDate:endDate newMoney:newMoney type:2 inDatabase:db error:&error]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        //修改本金
        if (![db executeUpdate:@"update bk_fixed_finance_product set cwritedate = ?, imoney = ? where cuserid = ? and cproductid = ? and operatortype != 2",writeDateStr,@(newMoney),productModel.userid,productModel.productid]) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
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


/**
 追加或赎回投资
 
 @param model model
 param type 1追加2赎回
 @param chargeModels 追加产生的流水
 @param success 成功
 @param failure 失败
 */
+ (void)addOrRedemptionInvestmentWithProductModel:(SSJFixedFinanceProductItem *)productModel
                                             type:(NSInteger)type
                                     chargeModels:(NSArray <SSJFixedFinanceProductCompoundItem *>*)chargeModels
                                          success:(void (^)(void))success
                                          failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        NSError *error = nil;
        NSDate *lastDate = [NSDate date];
        for (SSJFixedFinanceProductCompoundItem *model in chargeModels) {
            NSDate *writeDate = [lastDate dateByAddingSeconds:1];
            model.chargeModel.writeDate = writeDate;
            model.targetChargeModel.writeDate = writeDate;
            model.interestChargeModel.writeDate = writeDate;
            lastDate = writeDate;
                //修改投资金额
                //查询原来金额
                double oldMoney = [db doubleForQuery:@"select imoney from bk_fixed_finance_product where cuserid = ? and cproductid = ? and operatortype != 2",productModel.userid,productModel.productid];
                double newMoney = oldMoney;
                if (type == 1) {//追加
                    newMoney = oldMoney + model.chargeModel.oldMoney;
                    
                } else if (type == 2) {//赎回
                    newMoney = oldMoney - model.chargeModel.oldMoney - model.interestChargeModel.oldMoney;
                }
            
            if (type != 0) {
                //删除以前派发的利息流水//重新派发利息流水
                    if (![self deleteDistributedInterestWithModel:productModel untilDate:[model.chargeModel.billDate dateByAddingDays:1] inDatabase:db error:&error]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatchMainAsync(^{
                                failure([db lastError]);
                            });
                        }
                        return;
                    }
                
                //重新生成新的历史派发流水
                NSDate *endDate;
                if ([[NSDate date] compare:[[productModel.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]] == NSOrderedAscending) {
                    endDate = [NSDate date];
                } else {
                    endDate = [[productModel.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1];
                }
                
                if (![self interestRecordWithModel:productModel investmentDate:model.chargeModel.billDate endDate:endDate newMoney:newMoney type:1 inDatabase:db error:&error]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }
            //更新固定理财金额
                NSString *writeDateStr = [writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                if (![db executeUpdate:@"update bk_fixed_finance_product set cwritedate = ?, imoney = ? where cuserid = ? and cproductid = ? and operatortype != 2",writeDateStr,@(newMoney),productModel.userid,productModel.productid]) {
                    if (failure) {
                        SSJDispatchMainAsync(^{
                            failure(error);
                        });
                    }
                    return;
                }
            
            //保存流水//存储流水记录
            if (![self saveFixedFinanceProductChargeWithModel:model item:productModel inDatabase:db error:&error]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
        }
        
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
  
    }];
}



//结算
+ (void)settlementWithProductModel:(SSJFixedFinanceProductItem *)productModel
                      chargeModels:(NSArray <SSJFixedFinanceProductCompoundItem *>*)chargeModels
                           success:(void (^)(void))success
                           failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        NSError *error = nil;
        NSDate *lastDate = [NSDate date];
         NSInteger i = 0;
        double newMoney = 0;
        NSString *billDate;
        for (SSJFixedFinanceProductCompoundItem *model in chargeModels) {
            NSDate *writeDate = [lastDate dateByAddingSeconds:1];
            model.chargeModel.writeDate = writeDate;
            model.targetChargeModel.writeDate = writeDate;
            model.interestChargeModel.writeDate = writeDate;
            lastDate = writeDate;
            billDate = [model.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
            
            //保存流水//存储流水记录
            if (![self saveFixedFinanceProductChargeWithModel:model item:productModel inDatabase:db error:&error]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
            }
            
            //原来金额+利息+手续费
            newMoney += model.chargeModel.money;
            newMoney -= model.interestChargeModel.money;
            
            double interest = [SSJFixedFinanceProductStore queryForFixedFinanceProduceInterestiothWithProductID:productModel.productid inDatabase:db];//所有派发利息的和
            //如果有利息时并且利息和派发利息不同的时候
            if (i == 0 && model.chargeModel && model.chargeModel.money != interest) {
                //如果利息收入大于预期利息：利息平账收入
                if (model.chargeModel.money > interest) {
                    if (![self liXiPingzhangShouRuWithModel:productModel chargeModel:model money:model.chargeModel.money - interest fundid:model.chargeModel.fundId inDatabase:db error:&error]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatchMainAsync(^{
                                failure(error);
                            });
                        }
                        return;
                    }
                } else if (model.chargeModel.money < interest) {//如果利息收入小于预期利息：利息平账支出
                    if (![self liXiPingzhangZhiChuWithModel:productModel chargeModel:model money:model.chargeModel.money - interest fundid:model.chargeModel.fundId inDatabase:db error:&error]) {
                        *rollback = YES;
                        if (failure) {
                            SSJDispatchMainAsync(^{
                                failure(error);
                            });
                        }
                        return;
                    }
                }
            }
            
            i++;
        }
        
        NSString *writeDateStr = [[lastDate dateByAddingSeconds:1] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_fixed_finance_product set cwritedate = ?, imoney = ?, isend = 1, cetargetfundid = ?,cenddate = ? where cuserid = ? and cproductid = ? and operatortype != 2",writeDateStr,@(newMoney),productModel.etargetfundid,billDate,productModel.userid,productModel.productid]) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
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

+ (BOOL)addChargeModel:(SSJFixedFinanceProductChargeItem *)chargeItem inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    return YES;
}


#pragma mark - Other

+ (BOOL)liXiPingzhangShouRuWithModel:(SSJFixedFinanceProductItem *)productModel chargeModel:(SSJFixedFinanceProductCompoundItem *)model money:(double)money fundid:(NSString *)fundid inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *billDateStr = [model.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *writeDateStr = [model.chargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *cid = productModel.productid;
    NSArray *keyArr = @[@"ichargeid",@"cuserid",@"ibillid",@"ifunsid",@"cbilldate",@"cid",@"imoney",@"cmemo",@"iversion",@"operatortype",@"cwritedate",@"ichargetype"];
    NSMutableArray *valueArr = [NSMutableArray array];
    [valueArr addObject:SSJUUID()];
    [valueArr addObject:model.chargeModel.userId];
    [valueArr addObject:@"21"];
    [valueArr addObject:model.chargeModel.fundId];
    [valueArr addObject:billDateStr];
    [valueArr addObject:cid];
    [valueArr addObject:@(money)];
    [valueArr addObject:model.chargeModel.memo.length ? model.chargeModel.memo : @""];
    [valueArr addObject:@(SSJSyncVersion())];
    [valueArr addObject:@(SSJOperatorTypeCreate)];
    [valueArr addObject:writeDateStr];
    [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
    NSDictionary *chargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];

    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:chargeInfo]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }

    return YES;
}

+ (BOOL)liXiPingzhangZhiChuWithModel:(SSJFixedFinanceProductItem *)productModel chargeModel:(SSJFixedFinanceProductCompoundItem *)model money:(double)money fundid:(NSString *)fundid inDatabase:(FMDatabase *)db error:(NSError **)error{
    NSString *billDateStr = [model.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
    NSString *writeDateStr = [model.chargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *cid = productModel.productid;
    NSArray *keyArr = @[@"ichargeid",@"cuserid",@"ibillid",@"ifunsid",@"cbilldate",@"cid",@"imoney",@"cmemo",@"iversion",@"operatortype",@"cwritedate",@"ichargetype"];
    NSMutableArray *valueArr = [NSMutableArray array];
    [valueArr addObject:SSJUUID()];
    [valueArr addObject:model.chargeModel.userId];
    [valueArr addObject:@"22"];
    [valueArr addObject:model.chargeModel.fundId];
    [valueArr addObject:billDateStr];
    [valueArr addObject:cid];
    [valueArr addObject:@(money)];
    [valueArr addObject:model.chargeModel.memo.length ? model.chargeModel.memo : @""];
    [valueArr addObject:@(SSJSyncVersion())];
    [valueArr addObject:@(SSJOperatorTypeCreate)];
    [valueArr addObject:writeDateStr];
    [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
    NSDictionary *chargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
    
    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:chargeInfo]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    return YES;
}

/**
 查询流水cid后缀最大值
 
 @param productid <#productid description#>
 */
+ (NSInteger)queryMaxChargeChargeIdSuffixWithProductId:(NSString *)productid {
    //查询是否有流水没有为1，否则+1
    __block NSInteger chargeSuffixNum = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
       BOOL chargeExisted = [db boolForQuery:@"select count(1) from bk_user_charge where cuserid = ? and cid like (? || '_%') and ichargetype = 7", SSJUSERID(), productid];
            chargeSuffixNum = [db intForQuery:@"select max(cast(substr(uc.cid, length(tc.cproductid) + 2) as int)) from bk_user_charge as uc, bk_fixed_finance_product as tc where uc.cuserid = ? and uc.ichargetype = 7 and uc.cid like (? || '_%')", SSJUSERID(), productid] + 1;
    }];
    return chargeSuffixNum;
}

+ (NSInteger)queryMaxChargeChargeIdSuffixWithProductId:(NSString *)productid  inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSInteger chargeSuffixNum = 0;
    BOOL chargeExisted = [db boolForQuery:@"select count(1) from bk_user_charge where cuserid = ? and cid like (? || '_%') and ichargetype = 7", SSJUSERID(), productid];
    chargeSuffixNum = [db intForQuery:@"select max(cast(substr(uc.cid, length(tc.cproductid) + 2) as int)) from bk_user_charge as uc, bk_fixed_finance_product as tc where uc.cuserid = ? and uc.ichargetype = 7 and uc.cid like (? || '_%')", SSJUSERID(), productid] + 1;
    return chargeSuffixNum;
}

+ (SSJLoanFundAccountSelectionViewItem *)queryfundNameWithFundid:(NSString *)fundid {
    __block SSJLoanFundAccountSelectionViewItem *funditem = [[SSJLoanFundAccountSelectionViewItem alloc] init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        funditem.title = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ? and cuserid = ?",fundid,SSJUSERID()];
        funditem.image = [db stringForQuery:@"select cicoin from bk_fund_info where cfundid = ? and cuserid = ?",fundid,SSJUSERID()];
        funditem.ID = [db stringForQuery:@"select cfundid from bk_fund_info where cfundid = ? and cuserid = ?",fundid,SSJUSERID()];
    }];
    return funditem;
}

/**
 通过remindid查找
 
 @param remindid <#remindid description#>
 @return <#return value description#>
 */
+ (NSString *)queryProductIdWithRemindId:(NSString *)remindid {
    __block NSString *productid;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        productid = [db stringForQuery:@"select cproductid from bk_fixed_finance_product where cremindid = ? and cuserid = ?",remindid,SSJUSERID()];
    }];
    return productid;
}

+ (NSString *)queryRemindDateWithRemindid:(NSString *)remindid {
    __block NSString *remindDate;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        remindDate = [db stringForQuery:@"select cstartdate from bk_user_remind where cremindid = ? and cuserid = ?",remindid,SSJUSERID()];
    }];
    return remindDate;
}


#pragma mark - Private
+ (BOOL)saveFixedFinanceProductChargeWithModel:(SSJFixedFinanceProductCompoundItem *)model item:(SSJFixedFinanceProductItem *)item inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    if (!model.chargeModel || !model.targetChargeModel) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"chargeModel和targetChargeModel不能为nil"}];
        }
        return NO;
    }
    
    if (model.chargeModel.money != model.targetChargeModel.money) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"chargeModel和targetChargeModel的金额必须相等"}];
        }
        return NO;
    }

    
    // 所属账户转账流水
    if (model.chargeModel.money > 0) {
        NSString *billDateStr = [model.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDateStr = [model.chargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSArray *keyArr = @[@"ichargeid",@"cuserid",@"ibillid",@"ifunsid",@"cbilldate",@"cid",@"imoney",@"cmemo",@"iversion",@"operatortype",@"cwritedate",@"ichargetype"];
        NSMutableArray *valueArr = [NSMutableArray array];
        [valueArr addObject:model.chargeModel.chargeId];
        [valueArr addObject:SSJUSERID()];
        [valueArr addObject:model.chargeModel.billId];
        [valueArr addObject:model.chargeModel.fundId];
        [valueArr addObject:billDateStr];
        [valueArr addObject:model.chargeModel.cid];
        [valueArr addObject:@(model.chargeModel.money)];
        [valueArr addObject:model.chargeModel.memo.length ? model.chargeModel.memo : @""];
        [valueArr addObject:@(SSJSyncVersion())];
        [valueArr addObject:@(SSJOperatorTypeCreate)];
        [valueArr addObject:writeDateStr];
        [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
        NSDictionary *chargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
        if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:chargeInfo]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }

        // 目标账户转账流水
    if (model.targetChargeModel.money > 0) {
        NSString *billDateStr = [model.targetChargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDateStr = [model.targetChargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSArray *keyArr = @[@"ichargeid",@"cuserid",@"ibillid",@"ifunsid",@"cbilldate",@"cid",@"imoney",@"cmemo",@"iversion",@"operatortype",@"cwritedate",@"ichargetype"];
        NSMutableArray *valueArr = [NSMutableArray array];
        [valueArr addObject:model.targetChargeModel.chargeId];
        [valueArr addObject:SSJUSERID()];
        [valueArr addObject:model.targetChargeModel.billId];
        [valueArr addObject:model.targetChargeModel.fundId];
        [valueArr addObject:billDateStr];
        [valueArr addObject:model.targetChargeModel.cid];
        [valueArr addObject:@(model.targetChargeModel.money)];
        [valueArr addObject:model.targetChargeModel.memo.length ? model.targetChargeModel.memo : @""];
        [valueArr addObject:@(SSJSyncVersion())];
        [valueArr addObject:@(SSJOperatorTypeCreate)];
        [valueArr addObject:writeDateStr];
        [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
        NSDictionary *targetChargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
        
        if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:targetChargeInfo]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    
    // 手续费
    if (model.interestChargeModel && model.interestChargeModel.money > 0) {
        NSString *billDateStr = [model.interestChargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDateStr = [model.interestChargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSArray *keyArr = @[@"ichargeid",@"cuserid",@"ibillid",@"ifunsid",@"cbilldate",@"cid",@"imoney",@"cmemo",@"iversion",@"operatortype",@"cwritedate",@"ichargetype"];
        NSMutableArray *valueArr = [NSMutableArray array];
        [valueArr addObject:model.interestChargeModel.chargeId];
        [valueArr addObject:model.interestChargeModel.userId];
        [valueArr addObject:model.interestChargeModel.billId];
        [valueArr addObject:model.interestChargeModel.fundId];
        [valueArr addObject:billDateStr];
        [valueArr addObject:model.interestChargeModel.cid];
        [valueArr addObject:@(model.interestChargeModel.money)];
        [valueArr addObject:model.interestChargeModel.memo.length ? model.interestChargeModel.memo : @""];
        [valueArr addObject:@(SSJSyncVersion())];
        [valueArr addObject:@(SSJOperatorTypeCreate)];
        [valueArr addObject:writeDateStr];
        [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
        NSDictionary *interestChargeInfo = [NSDictionary dictionaryWithObjects:valueArr forKeys:keyArr];

        if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:interestChargeInfo]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    return YES;
}


/**
 删除每日派发的利息流水

 @param model <#model description#>
 @param db <#db description#>
 @param error <#error description#>
 */
+ (BOOL)deleteDistributedInterestWithModel:(SSJFixedFinanceProductItem *)model untilDate:(NSDate *)untilDate inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    if (untilDate) {
        if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, operatortype = ? where ibillid = ? and cuserid = ? and cbilldate >= ? and cid = ?",writeDateStr,@(SSJOperatorTypeDelete),@(19),SSJUSERID(),[untilDate formattedDateWithFormat:@"yyyy-MM-dd"],model.productid]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }

    } else {
        if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, operatortype = ? where ibillid = ? and cuserid = ? and cid = ?",writeDateStr,@(SSJOperatorTypeDelete),@(19),SSJUSERID(),model.productid]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    return YES;
}


/**
 删除当前账户和目标账户的流水

 @param model <#model description#>
 @param db <#db description#>
 @param error <#error description#>
 @return <#return value description#>
 */
//+ (BOOL)deleteRecordWithModel:(SSJFixedFinanceProductItem *)model inDatabase:(FMDatabase *)db error:(NSError **)error {
//    if (![db executeUpdate:@""]) {
//        if (error) {
//            *error = [db lastError];
//        }
//        return NO;
//    }
//    return YES;
//}

+ (NSArray *)updateFinanceChargeTypeWithModel:(NSMutableArray *)chargeArr {
    NSMutableArray *compArr = [NSMutableArray array];
    for (SSJFixedFinanceProductChargeItem *item in chargeArr) {
        if ([item.billId isEqualToString:@"3"]) {// 创建
            item.chargeType = SSJFixedFinCompoundChargeTypeCreate;
        } else if ([item.billId isEqualToString:@"4"]) {//结算
            item.chargeType = SSJFixedFinCompoundChargeTypeCloseOut;
        } else if ([item.billId isEqualToString:@"15"]) {//固收理财变更转入（对固收理财账户而言，是追加投资）
            item.chargeType = SSJFixedFinCompoundChargeTypeAdd;
        } else if ([item.billId isEqualToString:@"16"]) {//固收理财变更转出（对固收理财账户而言，是部分赎回）
            item.chargeType = SSJFixedFinCompoundChargeTypeRedemption;
        } else if ([item.billId isEqualToString:@"17"]) {//固收理财结算利息转入
            item.chargeType = SSJFixedFinCompoundChargeTypeBalanceInterestIncrease;
        } else if ([item.billId isEqualToString:@"18"]) {//固收理财结算利息转出
            item.chargeType = SSJFixedFinCompoundChargeTypeBalanceInterestDecrease;
        } else if ([item.billId isEqualToString:@"19"]) {// 固收理财派发利息流水
            item.chargeType = SSJFixedFinCompoundChargeTypeInterest;
        } else if ([item.billId isEqualToString:@"20"]) {//固收理财手续费率（部分赎回，结算）
            item.chargeType = SSJFixedFinCompoundChargeTypeCloseOutInterest;
        } else if ([item.billId isEqualToString:@"21"]) {//固收理财平账收入
            item.chargeType = SSJFixedFinCompoundChargeTypePinZhangBalanceIncrease;
        } else if ([item.billId isEqualToString:@"22"]) {//固收理财平账支出
            item.chargeType = SSJFixedFinCompoundChargeTypePinZhangBalanceDecrease;
        }
        
        [compArr addObject:item];
    }
    return [compArr copy];
}

+ (double)fenduanlixiWithProductItem:(SSJFixedFinanceProductItem *)item newMoney:(NSString *)money interestDate:(NSDate *)investmentDate {
    NSDate *dayJixiDate ;
    //生成利息
    double interest = 0;
    if (item.interesttype == SSJMethodOfInterestEveryDay) {
        dayJixiDate = [investmentDate dateByAddingDays:1];
        NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:item.time timetype:item.timetype money:[money doubleValue] interestType:item.interesttype startDate:@""];
        interest = [[interestDic objectForKey:@"interest"] doubleValue];
    } else if (item.interesttype == SSJMethodOfInterestEveryMonth) {
        
        if ([investmentDate isSameDay:item.startDate]) {//新建
            dayJixiDate = [item.startDate dateByAddingMonths:1];
            interest = [[[SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:item.time timetype:item.timetype money:[money doubleValue] interestType:item.interesttype startDate:@""] objectForKey:@"interest"] doubleValue];
        } else {//编辑，追加或者赎回等
            NSInteger months = [investmentDate monthsFrom:item.startDate];
            NSInteger days = [investmentDate daysFrom:item.startDate];
            if (months > 1) {
                dayJixiDate = [item.startDate dateByAddingMonths:(months + 1)];
                NSDate *begDate = [item.startDate dateByAddingMonths:months];
                NSDate *centerDate = investmentDate;
                NSDate *endDate = dayJixiDate;
                NSInteger begDays = [centerDate daysFrom:begDate];
                NSInteger endDays = [endDate daysFrom:centerDate];
                interest = [[[SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:begDays timetype:SSJMethodOfRateOrTimeDay money:[item.money doubleValue] interestType:SSJMethodOfInterestOncePaid startDate:@""] objectForKey:@"interest"] doubleValue] + [[[SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:endDays timetype:SSJMethodOfRateOrTimeDay money:[money doubleValue] interestType:SSJMethodOfInterestOncePaid startDate:@""] objectForKey:@"interest"] doubleValue];
            } else if(months == 1) {
                dayJixiDate = [item.startDate dateByAddingMonths:(months + 1)];
                NSDate *begDate = [item.startDate dateByAddingMonths:months];
                NSDate *centerDate = investmentDate;
                NSDate *endDate = dayJixiDate;
                NSInteger begDays = [centerDate daysFrom:begDate];
                NSInteger endDays = [endDate daysFrom:centerDate];
                interest = [[[SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:begDays timetype:SSJMethodOfRateOrTimeDay money:[item.money doubleValue] interestType:SSJMethodOfInterestOncePaid startDate:@""] objectForKey:@"interest"] doubleValue] + [[[SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:endDays timetype:SSJMethodOfRateOrTimeDay money:[money doubleValue] interestType:SSJMethodOfInterestOncePaid startDate:@""] objectForKey:@"interest"] doubleValue];
            } else if (months < 1) {
                dayJixiDate = [item.startDate dateByAddingMonths:1];
                NSDate *begDate = [item.startDate dateByAddingMonths:months];
                NSDate *centerDate = investmentDate;
                NSDate *endDate = dayJixiDate;
                NSInteger begDays = [centerDate daysFrom:begDate];
                NSInteger endDays = [endDate daysFrom:centerDate];
                interest = [[[SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:begDays timetype:SSJMethodOfRateOrTimeDay money:[item.money doubleValue] interestType:SSJMethodOfInterestOncePaid startDate:@""] objectForKey:@"interest"] doubleValue] + [[[SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:endDays timetype:SSJMethodOfRateOrTimeDay money:[money doubleValue] interestType:SSJMethodOfInterestOncePaid startDate:@""] objectForKey:@"interest"] doubleValue];
                
            }
        }
        
    } else if (item.interesttype == SSJMethodOfInterestOncePaid) {
        dayJixiDate = [investmentDate dateByAddingYears:1];
    }
    return interest;
}


/**
 生成某个理财产品在起止时间内的利息派发流水  每日流水

 @param item <#item description#>
 @param startDate <#startDate description#>
 @param type 3:追加  2：赎回  1：每日派息以及新建时候派息
 delete 2:删除（追加或者赎回） 2正常
 @param endDate <#endDate description#>
 */
+ (BOOL)interestRecordWithModel:(SSJFixedFinanceProductItem *)item investmentDate:(NSDate *)investmentDate endDate:(NSDate *)endDate newMoney:(double)newMoney type:(NSInteger)delete inDatabase:(FMDatabase *)db error:(NSError **)error {
    if ([investmentDate isLaterThanOrEqualTo:endDate]) {
        return YES;
    }
    BOOL isMoneyChange = NO;
    NSInteger type = 1;
    NSString *money  = item.money;
    if (newMoney > 0) {
        money = [NSString stringWithFormat:@"%.2f",newMoney];
        isMoneyChange = YES;
        if ([item.money doubleValue] > newMoney) {
            type = 2;
        } else {
            type = 3;
        }
    }

    //endDate当前日期
    //投资时间，计息时间：投资时间+1，产生利息时间：计息时间+1
    NSDate *startDate = [investmentDate dateByAddingDays:2];
    if ([startDate isLaterThanOrEqualTo:endDate]) {
//        [CDAutoHideMessageHUD showMessage:@"如果开始时间晚于结束时间则返回"];
        return YES;
    } //如果开始时间晚于结束时间则返回
    
    
    NSInteger moneyChangeMonth = 0;
    NSDate *dayJixiDate ;
    //生成利息
    double interest = 0;
    if (item.interesttype == SSJMethodOfInterestEveryDay) {
        dayJixiDate = [investmentDate dateByAddingDays:1];
    } else if (item.interesttype == SSJMethodOfInterestEveryMonth) {
        dayJixiDate = [item.startDate dateByAddingMonths:1];
        if ([investmentDate isSameDay:item.startDate]) {//新建
            isMoneyChange = NO;
        } else {//编辑，追加或者赎回等
            NSInteger months = [investmentDate monthsFrom:item.startDate];
            if (months > 1) {
                dayJixiDate = [item.startDate dateByAddingMonths:(months + 1)];
            } else if(months == 1) {
                dayJixiDate = [item.startDate dateByAddingMonths:(months + 1)];

            } else if (months < 1) {
                dayJixiDate = [item.startDate dateByAddingMonths:1];
            }
            moneyChangeMonth = months;
        }
        
    } else if (item.interesttype == SSJMethodOfInterestOncePaid) {
        dayJixiDate = [investmentDate dateByAddingYears:1];
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger days = [endDate daysFrom:dayJixiDate calendar:gregorian];
    
    NSDate *currentDate = [NSDate date];
    
    NSString *billId = @"19";
    NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *fundid = item.thisfundid;
    NSArray *keyArr = @[@"ichargeid",@"cuserid",@"ibillid",@"ifunsid",@"cbilldate",@"cid",@"imoney",@"cmemo",@"iversion",@"operatortype",@"cwritedate",@"ichargetype"];
    
    
    NSString *cid = item.productid;
    
    switch (item.interesttype) {//计息方式
        case SSJMethodOfInterestOncePaid://一次性
            switch (item.timetype) {
                case SSJMethodOfRateOrTimeDay:
                {
                    if ([[dayJixiDate dateByAddingDays:item.time] isLaterThanOrEqualTo:currentDate]) return YES;//如果没到时间返回
                    NSDate *writeDate = [dayJixiDate dateByAddingDays:(item.time + 1)];
                    NSDate *billDate = [dayJixiDate dateByAddingDays:item.time];
                    //如果已经到了结束日期了就返回
                    if ([billDate isLaterThan:[[item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]]) {
                        return 0;
                    }
                    if ([writeDate isLaterThanOrEqualTo:currentDate]) return YES;
                    
                    NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
                    NSMutableArray *valueArr = [NSMutableArray array];
                    NSString *chargeid = [NSString stringWithFormat:@"%@_%@",item.productid,[billDate formattedDateWithFormat:@"yyyyMMdd"]];
                    [valueArr addObject:chargeid];
                    [valueArr addObject:SSJUSERID()];
                    [valueArr addObject:billId];
                    [valueArr addObject:fundid];
                    [valueArr addObject:billDateStr];
                    [valueArr addObject:cid];
                    [valueArr addObject:@(interest)];
                    [valueArr addObject:item.memo.length ? item.memo : @""];
                    [valueArr addObject:@(SSJSyncVersion())];
                    [valueArr addObject:@(SSJOperatorTypeCreate)];
                    [valueArr addObject:writeDateStr];
                    [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
                    NSDictionary *interestChargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
                    
                    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:interestChargeInfo]) {
                        return NO;
                    }
                }
                    break;

                case SSJMethodOfRateOrTimeMonth:
                {
                    if ([[dayJixiDate dateByAddingMonths:item.time] isLaterThanOrEqualTo:currentDate]) return YES;//如果没到时间返回
                    NSDate *writeDate = [[dayJixiDate dateByAddingMonths:(item.time)] dateByAddingDays:1];
                    if ([writeDate isLaterThanOrEqualTo:currentDate]) return YES;
                    
                    NSDate *billDate = [writeDate dateBySubtractingDays:1];
                    //如果一定到了结束日期了就返回
                    if ([billDate isLaterThan:[[item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]]) {
                        return 0;
                    }
                    NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
                    //生成利息
                    NSMutableArray *valueArr = [NSMutableArray array];
                    [valueArr addObject:SSJUUID()];
                    [valueArr addObject:SSJUSERID()];
                    [valueArr addObject:billId];
                    [valueArr addObject:fundid];
                    [valueArr addObject:billDateStr];
                    [valueArr addObject:cid];
                    [valueArr addObject:@(interest)];
                    [valueArr addObject:item.memo.length ? item.memo : @""];
                    [valueArr addObject:@(SSJSyncVersion())];
                    [valueArr addObject:@(SSJOperatorTypeCreate)];
                    [valueArr addObject:writeDateStr];
                    [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
                    NSDictionary *interestChargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
                    
                    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:interestChargeInfo]) {
                        return NO;
                    }
                }
                    break;

                case SSJMethodOfRateOrTimeYear:
                {
                    if ([[dayJixiDate dateByAddingYears:item.time] isLaterThanOrEqualTo:currentDate]) return YES;//如果没到时间返回
                    NSDate *writeDate = [[dayJixiDate dateByAddingYears:(item.time)] dateByAddingDays:1];
                    if ([writeDate isLaterThanOrEqualTo:currentDate]) return YES;

                    NSDate *billDate = [writeDate dateBySubtractingDays:1];
                    //如果一定到了结束日期了就返回
                    if ([billDate isLaterThan:[[item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]]) {
                        return 0;
                    }
                    NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
                    //生成利息
                    NSMutableArray *valueArr = [NSMutableArray array];
                    [valueArr addObject:SSJUUID()];
                    [valueArr addObject:SSJUSERID()];
                    [valueArr addObject:billId];
                    [valueArr addObject:fundid];
                    [valueArr addObject:billDateStr];
                    [valueArr addObject:cid];
                    [valueArr addObject:@(interest)];
                    [valueArr addObject:item.memo.length ? item.memo : @""];
                    [valueArr addObject:@(SSJSyncVersion())];
                    [valueArr addObject:@(SSJOperatorTypeCreate)];
                    [valueArr addObject:writeDateStr];
                    [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
                    NSDictionary *interestChargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
                    
                    if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:interestChargeInfo]) {
                        return NO;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            break;
        case SSJMethodOfInterestEveryDay://每日付息
//            switch (item.timetype) {
//                case SSJMethodOfRateOrTimeDay://期限日
//                case SSJMethodOfRateOrTimeMonth://期限月
//                case SSJMethodOfRateOrTimeYear://期限年
        {
            NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:item.time timetype:item.timetype money:[money doubleValue] interestType:item.interesttype startDate:@""];
            interest = [[interestDic objectForKey:@"interest"] doubleValue];

        }
                    //每日计息
                    for (NSInteger i=0; i<days; i++) {
                        NSDate *billDate = [dayJixiDate dateByAddingDays:i];
                        //如果一定到了结束日期了就返回
                        if ([billDate isLaterThan:[[item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]]) {
                            return 0;
                        }
                        if ([billDate isLaterThanOrEqualTo:endDate]) return YES;//如果开始时间晚于结束时间则返回
                        NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
                        //生成利息
                        
                        NSMutableArray *valueArr = [NSMutableArray array];
                        [valueArr addObject:SSJUUID()];
                        [valueArr addObject:SSJUSERID()];
                        [valueArr addObject:billId];
                        [valueArr addObject:fundid];
                        [valueArr addObject:billDateStr];
                        [valueArr addObject:cid];
                        [valueArr addObject:@(interest)];
                        [valueArr addObject:item.memo.length ? item.memo : @""];
                        [valueArr addObject:@(SSJSyncVersion())];
                        [valueArr addObject:@(SSJOperatorTypeCreate)];
                        [valueArr addObject:writeDateStr];
                        [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
                        NSDictionary *interestChargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
                        
                        if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:interestChargeInfo]) {
                            return NO;
                        }
            }
            
            break;
        case SSJMethodOfInterestEveryMonth://每月付息
        {
            NSInteger months = 0;
            switch (item.timetype) {
                    
                case SSJMethodOfRateOrTimeMonth:
                    months = item.time;
                    break;
                case SSJMethodOfRateOrTimeYear: //一年12个月一共12*n个月
                    months = item.time * 12;
                    break;
                    
                default:
                    break;
            }
            for (NSInteger i = 0; i<months; i++) {
                NSDate *monthJiXiDate = [dayJixiDate dateByAddingMonths:i];
                if ([monthJiXiDate isLaterThanOrEqualTo:endDate] && monthJiXiDate ) return YES;
                NSDate *billDate = monthJiXiDate;
                if (newMoney == 0 || delete == 2) {//如果资金没有变动或者是删除的时候按照变更前的金额计算利息
                    NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:item.time timetype:item.timetype money:[money doubleValue] interestType:item.interesttype startDate:@""];
                    interest = [[interestDic objectForKey:@"interest"] doubleValue];
                    //如果是追加或者赎回那么当月的利息将分段计算
                } else if (i == 0 && isMoneyChange == YES) {//本金有变动(追加或者赎回)
                    interest = [self fenduanlixiWithProductItem:item newMoney:money interestDate:investmentDate];
                    
                } else {//没有变动
                    NSDictionary *interestDic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:item.rate rateType:item.ratetype time:item.time timetype:item.timetype money:[money doubleValue] interestType:item.interesttype startDate:@""];
                    interest = [[interestDic objectForKey:@"interest"] doubleValue];
                }
                
                //如果一定到了结束日期了就返回
                if ([billDate isLaterThan:[[item.enddate ssj_dateWithFormat:@"yyyy-MM-dd"] dateByAddingDays:1]]) {
                    return 0;
                }
                if ([billDate isLaterThanOrEqualTo:endDate]) return YES;//如果开始时间晚于结束时间则返回
                NSString *billDateStr = [billDate formattedDateWithFormat:@"yyyy-MM-dd"];
                //生成利息
                NSMutableArray *valueArr = [NSMutableArray array];
                [valueArr addObject:SSJUUID()];
                [valueArr addObject:SSJUSERID()];
                [valueArr addObject:billId];
                [valueArr addObject:fundid];
                [valueArr addObject:billDateStr];
                [valueArr addObject:cid];
                [valueArr addObject:@(interest)];
                [valueArr addObject:item.memo.length ? item.memo : @""];
                [valueArr addObject:@(SSJSyncVersion())];
                [valueArr addObject:@(SSJOperatorTypeCreate)];
                [valueArr addObject:writeDateStr];
                [valueArr addObject:@(SSJChargeIdTypeFixedFinance)];
                NSDictionary *interestChargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
                
                if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:interestChargeInfo]) {
                    return NO;
                }
            }
        }
            break;
        default:
            break;
    }
    return YES;
}


/**
 查询某个理财账户最新一条派发流水时间

 @param model <#model description#>
 @return <#return value description#>
 */
+ (NSDate *)queryPaiFalLastBillDateWithPorductModel:(SSJFixedFinanceProductItem *)model inDatabase:(SSJDatabase *)db {
    __block NSString *newDate;
    newDate = [db stringForQuery:@"select max(cbilldate) from bk_user_charge where ichargetype = ? and cuserid = ? and cid = ? and ibillid = 19",@(SSJChargeIdTypeFixedFinance),SSJUSERID(),model.productid];
    if (!newDate.length) {//如果不存在派发则是model的billdate
        return model.startDate;
    }
    return [newDate ssj_dateWithFormat:@"yyyy-MM-dd"];
}


+ (BOOL)queryIsChangeMoneyWithProductModel:(SSJFixedFinanceProductItem *)model {
    __block BOOL allow = NO;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
       allow = [db boolForQuery:@"select count(*) from bk_user_charge where (ibillid = 15 or ibillid = 16) and cid like (? || '_%') and cuserid = ? and operatortype != 2",model.productid,SSJUSERID()];
    }];
    return !allow;
}

+ (BOOL)queryIsChangeMoneyWithProductModel:(SSJFixedFinanceProductItem *)model inDatabase:(FMDatabase *)db error:(NSError **)error {
    return ![db boolForQuery:@"select count(*) from bk_user_charge where (ibillid = 15 or ibillid = 16) and cid like (? || '_%') and cuserid = ? and operatortype != 2",model.productid,SSJUSERID()];
}

/**
 查询最早一条赎回时间
 
 @param model <#model description#>
 @return <#return value description#>
 */
+ (NSDate *)queryFirstRedemDateWithProductModel:(SSJFixedFinanceProductItem *)model {
    return nil;
}


/**
 查询最早一条添加时间
 
 @param model <#model description#>
 @return <#return value description#>
 */
+ (NSDate *)queryFirstAddDateWithProductModel:(SSJFixedFinanceProductItem *)model {
    return nil;
}

/**
 查询最早一条添加或者赎回时间
 
 @param model <#model description#>
 @return <#return value description#>
 */
+ (NSDate *)queryFirstAddOrRedemDateWithProductModel:(SSJFixedFinanceProductItem *)model {
    __block NSDate *lastDate;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        NSString *lastdate = [db stringForQuery:@"select min(cbilldate) from bk_user_charge where (ibillid = 15 or ibillid = 16) and cid like (? || '_%') and cuserid = ? and operatortype != 2",model.productid,SSJUSERID()];
        if (lastdate.length) {
            lastDate = [lastdate ssj_dateWithFormat:@"yyyy-MM-dd"];
        } else {
            lastDate = [NSDate date];
        }
    }];
    return lastDate;
}

/**
 查询最晚一条添加或者赎回时间
 
 @param model <#model description#>
 @return <#return value description#>
 */
+ (NSDate *)queryLastAddOrRedemDateWithProductModel:(SSJFixedFinanceProductItem *)model {
    __block NSDate *lastDate;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        NSString *lastdate = [db stringForQuery:@"select max(cbilldate) from bk_user_charge where (ibillid = 15 or ibillid = 16) and cid like (? || '_%') and cuserid = ? and operatortype != 2",model.productid,SSJUSERID()];
        if (lastdate.length) {
            lastDate = [lastdate ssj_dateWithFormat:@"yyyy-MM-dd"];
        } 
    }];
    return lastDate;
}

/**
 查询结算的时候是否有手续费
 
 @param productItem <#productItem description#>
 @param chargeItem <#chargeItem description#>
 @return <#return value description#>
 */
+ (BOOL)queryHasPoundageWithProduct:(SSJFixedFinanceProductItem *)productItem chargeItem:(SSJFixedFinanceProductChargeItem *)chargeItem {
    __block BOOL has = NO;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        has = [db boolForQuery:@"select count(*) from bk_user_charge where ibillid = 20 and cid = ? and cuserid = ? and operatortype != 2",chargeItem.cid,SSJUSERID()];
    }];

    return has;
}

+ (double)queryPoundageWithProduct:(SSJFixedFinanceProductItem *)productItem chargeItem:(SSJFixedFinanceProductChargeItem *)chargeItem {
    __block double poundage;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        poundage = [db doubleForQuery:@"select imoney from bk_user_charge where ibillid = 20 and cid = ? and cuserid = ? and operatortype != 2",chargeItem.cid,SSJUSERID()];
    }];
    
    return poundage;
}

/**
 计算当前余额
 
 @param productItem <#productItem description#>
 @return <#return value description#>
 */
+ (double)caluclateTheBalanceOfCurrentWithModel:(SSJFixedFinanceProductItem *)productItem {
    //本金 + 利息 - 赎回- 赎回手续费
    __block double money = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        //利息
       double money1 = [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '%') and ichargetype = ? and ibillid = ? and cuserid = ?",productItem.productid,@(SSJChargeIdTypeFixedFinance),@"19",SSJUSERID()];
        
        //赎回
        double money2 = [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '_%') and ichargetype = ? and ibillid = ? and cuserid = ?",productItem.productid,@(SSJChargeIdTypeFixedFinance),@"16",SSJUSERID()];
        
        //赎回手续费
        double money3 = [db doubleForQuery:@"select sum(imoney) from bk_user_charge where operatortype != 2 and cid like (? || '_%') and ichargetype = ? and ibillid = ? and cuserid = ?",productItem.productid,@(SSJChargeIdTypeFixedFinance),@"20",SSJUSERID()];
        money = [productItem.money doubleValue] + money1 - money2 - money3;
    }];
    
    return money;
}


@end
