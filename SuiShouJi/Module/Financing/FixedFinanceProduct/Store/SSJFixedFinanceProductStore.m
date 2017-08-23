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
                [sqlStr appendFormat:@" and isend = %ld", SSJFixedFinanceStateNoSettlement];
                break;
                case SSJFixedFinanceStateAll:
                break;
            default:
                break;
        }
        [sqlStr appendString:@"order by l.cstartdate desc, l.isend asc, l.imoney desc"];
        
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
        [objectArr addObject:model.productName?:@"ff"];
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

@end
