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

@implementation SSJFixedFinanceProductStore
/**
 保存固收理财产品（新建，编辑）
 
 @param model 模型
 @param success 成功
 @param failure 失败
 */
+ (void)saveFixedFinanceProductWithModel:(SSJFixedFinanceProductItem *)model
                            chargeModels:(NSArray <SSJFixedFinanceProductChargeItem *>*)chargeModels
                             remindModel:(nullable SSJReminderItem *)remindModel success:(void (^)(void))success
                                 failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        // 如果当前的固定收益账户已经删除，就当作成功处理（这种情况发生在查询记录后在另一个客户端上删除了）
        int operatorType = [db intForQuery:@"select operatortype from bk_fixed_finance_product where loanid = ?", model.productid];
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
        [objectArr addObject:model.productName];
        [objectArr addObject: model.memo.length ? model.memo:@""];
        [objectArr addObject:model.thisfundid];
        [objectArr addObject:model.targetfundid];
        [objectArr addObject:model.etargetfundid.length ? model.etargetfundid : @""];
        [objectArr addObject:model.money];
        [objectArr addObject:@(model.rate)];
        [objectArr addObject:@(model.ratetype)];
        [objectArr addObject:@(model.time)];
        [objectArr addObject:@(model.timetype)];
        [objectArr addObject:@(model.interesttype)];
        [objectArr addObject:model.startdate];
        [objectArr addObject:model.enddate.length ? model.enddate : @""];
        [objectArr addObject:@(model.isend)];
        [objectArr addObject: model.remindid.length ? model.remindid : @""];
        [objectArr addObject:writeDate];
        [objectArr addObject:@(SSJSyncVersion())];
        
        NSArray *keyArr = @[@"cproductid",@"cuserid",@"cproductname",@"cmemo",@"cthisfundid",@"ctargetfundid",@"cetargetfundid",@"imoney",@"irate",@"iratetype",@"itime",@"itimetype",@"interestype",@"cstartdate",@"cenddate",@"isend",@"cremindid",@"cwritedate",@"iversion",@"operatorype"];
        
        NSMutableDictionary *modelInfo = [NSMutableDictionary dictionaryWithObjects:objectArr forKeys:keyArr];
        
        if ([db boolForQuery:@"select count(*) from bk_fixed_finance_product where cproductid = ? and cuserid = ? and operatortype != 2",model.productid,SSJUSERID()]) {
            //编辑
            [modelInfo setObject:@(SSJOperatorTypeModify) forKey:@"operatortype"];
        } else {
            //插入
            [modelInfo setObject:@(SSJOperatorTypeCreate) forKey:@"operatortype"];
        }
        if (![db executeUpdate:@"replace into bk_fixed_finance_product (cproductid, cuserid, cproductname, cremindid, cthisfundid, ctargetfundid, cetargetfundid, imoney, cmemo, irate, iratetype, itime, itimetype, interesttype, cstartdate, cenddate, isend, cwritedate, iversion, operatortype) values (:cproductid, :cuserid, cproductname, :cremindid, :cthisfundid, :ctargetfundid, :cetargetfundid, :imoney, :cmemo, :irate, :iratetype, :itime, :itimetype, :interesttype, :cstartdate, :cenddate, :isend, :cwritedate, :iversion, :operatortype)" withParameterDictionary:modelInfo]) {
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
        for (SSJFixedFinanceProductChargeItem *model in chargeModels) {
            
            NSDate *writeDate = [lastDate dateByAddingSeconds:1];
            model.writeDate = writeDate;
//            model.targetChargeModel.writeDate = writeDate;
//            model.interestChargeModel.writeDate = writeDate;
            lastDate = writeDate;
            
//            if (![self saveLoanCompoundChargeModel:model inDatabase:db error:&error]) {
//                *rollback = YES;
//                if (failure) {
//                    SSJDispatchMainAsync(^{
//                        failure(error);
//                    });
//                }
//                return;
//            }
        }

    }];
    
}




#pragma mark - Private

@end
