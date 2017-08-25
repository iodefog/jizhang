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

#import "SSJDatabaseQueue.h"
#import "SSJLocalNotificationStore.h"

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
        
        //存储固定理财记录
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
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
        
        if ([db boolForQuery:@"select count(*) from bk_fixed_finance_product where cproductid = ? and cuserid = ? and operatortype != 2",model.productid,SSJUSERID()]) {
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
        
        //存储流水记录
        NSError *error = nil;
        NSDate *lastDate = [NSDate date];
        for (SSJFixedFinanceProductCompoundItem *model in chargeModels) {
            
            NSDate *writeDate = [lastDate dateByAddingSeconds:1];
            model.chargeModel.writeDate = writeDate;
            model.targetChargeModel.writeDate = writeDate;
            model.interestChargeModel.writeDate = writeDate;
            lastDate = writeDate;
            
            if (![self saveFixedFinanceProductChargeWithModel:model inDatabase:db error:&error]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure(error);
                    });
                }
                return;
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
        
        // 修改借贷账户的可见状态
        if (![db executeUpdate:@"update bk_fund_info set idisplay = 1, iversion = ?, operatortype = 1, cwritedate = ? where cfundid = ?", @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], @(17)]) {
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
        FMResultSet *resultSet = [db executeQuery:@"select ichargeid, ifunsid, ibillid, imoney, cmemo, cbilldate, cwritedate from bk_user_charge as uc where cuserid = ? and ifunsid = ? and cid like (? || '_%') and ichargetype = ? and operatortype <> 2 order by cbilldate, cwritedate", model.userid, model.thisfundid, model.productid, @(SSJChargeIdTypeFixedFinance)];
        NSMutableArray *chargeModels = [NSMutableArray array];
        while ([resultSet next]) {
            SSJFixedFinanceProductChargeItem *item = [[SSJFixedFinanceProductChargeItem alloc] init];
            item.chargeId = [resultSet stringForColumn:@"ichargeid"];
            item.fundId = [resultSet stringForColumn:@"ifunsid"];
            item.billId = [resultSet stringForColumn:@"ibillid"];
            item.userId = model.userid;
            item.memo = [resultSet stringForColumn:@"cmemo"];
            item.billDate = [NSDate dateWithString:[resultSet stringForColumn:@"cbilldate"] formatString:@"yyyy-MM-dd"];
            item.writeDate = [NSDate dateWithString:[resultSet stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
            item.money = [resultSet doubleForColumn:@"imoney"];
            [chargeModels addObject:item];
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

#pragma mark - Other

/**
 查询流水cid后缀最大值
 
 @param productid <#productid description#>
 */
+ (NSInteger)queryMaxChargeChargeIdSuffixWithProductId:(NSString *)productid {
    //查询是否有流水没有为1，否则+1
    __block NSInteger chargeSuffixNum = 0;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
       BOOL chargeExisted = [db boolForQuery:@"select count(1) from bk_user_charge where cuserid = ? and cid like (? || '_%') and ichargetype = 7", SSJUSERID(), productid];
        if (!chargeExisted) {
            chargeSuffixNum = [db intForQuery:@"select max(cast(substr(uc.cid, length(tc.cproductid) + 2) as int)) from bk_user_charge as uc, bk_fixed_finance_product as tc where uc.cuserid = ? and uc.ichargetype = 7 and uc.cid like (? || '_%')", SSJUSERID(), productid] + 1;
        }
    }];
    return chargeSuffixNum;
}


/**
 计算已产生利息
 
 @param model model
 @return 利息
 */
+ (double)caculateGenerateRateWithModel:(SSJFixedFinanceProductItem *)model {
    return 10;
}


/**
 计算预期利息
 
 @param model model
 @return 利息
 */
+ (double)caculateExpectedRateWithModel:(SSJFixedFinanceProductItem *)model {
    return 20;
}

#pragma mark - Private
+ (BOOL)saveFixedFinanceProductChargeWithModel:(SSJFixedFinanceProductCompoundItem *)model inDatabase:(FMDatabase *)db error:(NSError **)error {
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
    if (model.chargeModel) {
        NSString *billDateStr = [model.chargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDateStr = [model.chargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSArray *keyArr = @[@"ichargeid",@"cuserid",@"ibillid",@"ifunsid",@"cbilldate",@"cid",@"imoney",@"cmemo",@"iversion",@"operatortype",@"cwritedate",@"ichargetype"];
        NSMutableArray *valueArr = [NSMutableArray array];
        [valueArr addObject:model.chargeModel.chargeId];
        [valueArr addObject:model.chargeModel.userId];
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
    if (model.targetChargeModel) {
        NSString *billDateStr = [model.targetChargeModel.billDate formattedDateWithFormat:@"yyyy-MM-dd"];
        NSString *writeDateStr = [model.targetChargeModel.writeDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSArray *keyArr = @[@"ichargeid",@"cuserid",@"ibillid",@"ifunsid",@"cbilldate",@"cid",@"imoney",@"cmemo",@"iversion",@"operatortype",@"cwritedate",@"ichargetype"];
        NSMutableArray *valueArr = [NSMutableArray array];
        [valueArr addObject:model.targetChargeModel.chargeId];
        [valueArr addObject:model.targetChargeModel.userId];
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
    
    // 利息流水
    if (model.interestChargeModel) {
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
        NSDictionary *interestChargeInfo = [NSDictionary dictionaryWithObjects:[valueArr copy] forKeys:keyArr];
        
        if (![db executeUpdate:@"replace into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cbilldate, cid, imoney, cmemo, iversion, operatortype, cwritedate, ichargetype) values (:ichargeid, :cuserid, :ibillid, :ifunsid, :cbilldate, :cid, :imoney, :cmemo, :iversion, :operatortype, :cwritedate, :ichargetype)" withParameterDictionary:interestChargeInfo]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }

    return YES;
}

+ (NSArray *)updateFinanceChargeTypeWithModel:(NSMutableArray *)chargeArr {
    NSMutableArray *compArr = [NSMutableArray array];
    for (SSJFixedFinanceProductChargeItem *item in chargeArr) {
        if ([item.billId isEqualToString:@"4"]) {// 创建
            item.chargeType = SSJFixedFinCompoundChargeTypeCreate;
        } else if ([item.billId isEqualToString:@"3"]) {//全部赎回
            item.chargeType = SSJFixedFinCompoundChargeTypeCloseOut;
        } else if ([item.billId isEqualToString:@"15"]) {//固收理财变更转入（对固收理财账户而言，是追加投资）
            item.chargeType = SSJFixedFinCompoundChargeTypeAdd;
        } else if ([item.billId isEqualToString:@"16"]) {//固收理财变更转出（对固收理财账户而言，是部分赎回）
            item.chargeType = SSJFixedFinCompoundChargeTypeRedemption;
        } else if ([item.billId isEqualToString:@"17"]) {
            item.chargeType = SSJFixedFinCompoundChargeTypeBalanceIncrease;
        } else if ([item.billId isEqualToString:@"18"]) {
            item.chargeType = SSJFixedFinCompoundChargeTypeBalanceDecrease;
        } else if ([item.billId isEqualToString:@"19"]) {
            item.chargeType = SSJFixedFinCompoundChargeTypeBalanceInterestIncrease;
        } else if ([item.billId isEqualToString:@"20"]) {
            item.chargeType = SSJFixedFinCompoundChargeTypeBalanceInterestDecrease;
        } else if ([item.billId isEqualToString:@"21"]) {
            item.chargeType = SSJFixedFinCompoundChargeTypeInterest;
        } else if ([item.billId isEqualToString:@"22"]) {
            item.chargeType = SSJFixedFinCompoundChargeTypeCloseOutInterest;
        }
        
        [compArr addObject:item];
    }
    return [compArr copy];
}

@end
