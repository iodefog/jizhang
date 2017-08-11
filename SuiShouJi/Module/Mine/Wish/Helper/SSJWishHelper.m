//
//  SSJWishHelper.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishHelper.h"

#import "SSJWishModel.h"

#import "SSJDatabaseQueue.h"

@implementation SSJWishHelper

/**
 查询用户是否新建过愿望
 */
+ (BOOL)queryHasWishsWithError:(NSError **)error {
    __block BOOL hasWish = NO;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
       hasWish = [db boolForQuery:@"select count(1) from bk_wish where cuserid = ? and operatortype <> 2", SSJUSERID()];
    }];
    return hasWish;
}

/**
 通过提醒id查找心愿id
 
 @param remindId 提醒id
 @return 心愿id
 */
+ (NSString *)queryWishIdWithRemindId:(NSString *)remindId {
    __block NSString *wishId = @"";
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
       wishId = [db stringForQuery:@"select wishid from bk_wish where remindid = ? and cuserid = ?",remindId,SSJUSERID()];
    }];
    return wishId;
}


/**
 保存心愿
 
 @param wishModel 心愿model
 @param success 成功
 @param failure 失败
 */
+ (void)saveWishWithWishModel:(SSJWishModel *)wishModel
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *wishId = wishModel.wishId;
        if (!wishId.length) {
            wishModel.wishId = SSJUUID();
        }
        if (!wishModel.cuserId.length) {
            wishModel.cuserId = SSJUSERID();
        }
        
        wishModel.cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSMutableDictionary *typeInfo = [NSMutableDictionary dictionaryWithDictionary:[self fieldMapWithTypeItem:wishModel]];
        [typeInfo removeObjectForKey:@"wishSaveMoney"];
        [typeInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
        NSString *sqlStr = @"";
        if ([db boolForQuery:@"select count(1) from bk_wish where cuserid = ? and wishid = ?",SSJUSERID(),wishId]) {
            //更新
            [typeInfo setObject:@(1) forKey:@"operatortype"];
            sqlStr = [self updateSQLStatementWithTypeInfo:typeInfo tableName:@"bk_wish"];
        } else {
            //新增
            [typeInfo setObject:@(0) forKey:@"operatortype"];
            [typeInfo setObject:[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"startdate"];
            sqlStr = [self insertSQLStatementWithTypeInfo:typeInfo tableName:@"bk_wish"];
        }
        
        if (![db executeUpdate:sqlStr withParameterDictionary:typeInfo]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return ;
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
        
    }];
}

/**
 终止心愿
 
 @param wishModel 心愿model
 @param success 成功
 @param failure 失败
 */
+ (void)termWishWithWishModel:(SSJWishModel *)wishModel
                              success:(void(^)())success
                              failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_wish set status = 2, cwritedate = ? ,enddate = ? ,iversion = ? where cuserid = ? and wishid = ?",writeDateStr,writeDateStr,@(SSJSyncVersion()),SSJUSERID(),wishModel.wishId]) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
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
 查询心愿列表
 
 @param state 已完成或者未完成
 @param success 成功
 @param failure 失败
 */
+ (void)queryIngWishWithState:(SSJWishState)state
                      success:(void(^)(NSMutableArray <SSJWishModel *>*resultArr))success
                      failure:(void(^)(NSError *error))failure {
    
    NSMutableString *queryStr;
    
    if (state == SSJWishStateFinish || state == SSJWishStateTermination) {//已完成
        queryStr = [NSMutableString stringWithFormat:@"select bw.* from bk_wish as bw where bw.cuserid = '%@' and bw.operatortype <> 2 and bw.status <> 0 order by bw.startdate desc",SSJUSERID()];

    } else if (state == SSJWishStateNormalIng) {//未完成
        queryStr = [NSMutableString stringWithFormat:@"select bw.* from bk_wish as bw where bw.cuserid = '%@' and bw.operatortype <> 2 and status = 0 order by bw.startdate desc",SSJUSERID()];
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
       FMResultSet *result = [db executeQuery:queryStr];
        if (!result) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return ;
        }
        NSMutableArray *relultArray = [NSMutableArray array];
        while (result.next) {
            SSJWishModel *wishModel = [[SSJWishModel alloc] init];
            wishModel.wishId = [result stringForColumn:@"wishid"];
            wishModel.cuserId = [result stringForColumn:@"cuserid"];
            wishModel.wishName = [result stringForColumn:@"wishname"];
            wishModel.wishMoney = [NSString stringWithFormat:@"%.2f",[[result stringForColumn:@"wishmoney"] doubleValue]];
            wishModel.wishImage = [result stringForColumn:@"wishimage"];
            wishModel.cwriteDate = [result stringForColumn:@"cwritedate"];
            wishModel.operatorType = [result intForColumn:@"operatortype"];
            wishModel.remindId = [result stringForColumn:@"remindid"];
            wishModel.status = [result intForColumn:@"status"];
            wishModel.startDate = [result stringForColumn:@"startdate"];
            wishModel.endDate = [result stringForColumn:@"enddate"];
            wishModel.wishType = [result intForColumn:@"wishtype"];
            [relultArray addObject:wishModel];
        }
        
        for (SSJWishModel *wishModel in relultArray) {
            double inmoney = [db doubleForQuery:@"select sum(bwc.money) from bk_wish_charge bwc where bwc.itype = 0 and bwc.operatortype <> 2 and bwc.cuserid = ? and bwc.wishid = ?",SSJUSERID(),wishModel.wishId];
            double outmoney = [db doubleForQuery:@"select sum(bwc.money) from bk_wish_charge bwc where bwc.itype = 1 and bwc.operatortype <> 2 and bwc.cuserid = ? and bwc.wishid = ?",SSJUSERID(),wishModel.wishId];
            double savemoney = inmoney - outmoney;
            wishModel.wishSaveMoney = [NSString stringWithFormat:@"%.2f",savemoney];
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(relultArray);
            });
        }
    }];
}

/**
 根据心愿ID查询心愿详情
 
 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)queryWishWithWisId:(NSString *)wishId
                   Success:(void(^)(SSJWishModel *resultItem))success
                   failure:(void(^)(NSError *error))failure {
    if (!wishId.length) return ;
    
     [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
         
         FMResultSet *result = [db executeQuery:@"select bw.* from bk_wish as bw where bw.cuserid = ? and bw.wishid = ?",SSJUSERID(),wishId];
         
         if (!result) {
             SSJDispatch_main_async_safe(^{
                 failure([db lastError]);
             });
             return ;
         }
         double inmoney = [db doubleForQuery:@"select sum(bwc.money) from bk_wish_charge bwc where bwc.itype = 0 and bwc.operatortype <> 2 and bwc.cuserid = ? and bwc.wishid = ?",SSJUSERID(),wishId];
         double outmoney = [db doubleForQuery:@"select sum(bwc.money) from bk_wish_charge bwc where bwc.itype = 1 and bwc.operatortype <> 2 and bwc.cuserid = ? and bwc.wishid = ?",SSJUSERID(),wishId];
         double savemoney = inmoney - outmoney;
         
         SSJWishModel *wishModel = [[SSJWishModel alloc] init];
         while ([result next]) {
             wishModel.wishId = [result stringForColumn:@"wishid"];
             wishModel.cuserId = [result stringForColumn:@"cuserid"];
             wishModel.wishName = [result stringForColumn:@"wishname"];
             wishModel.wishMoney = [result stringForColumn:@"wishmoney"];
             wishModel.wishImage = [result stringForColumn:@"wishimage"];
             wishModel.cwriteDate = [result stringForColumn:@"cwritedate"];
             wishModel.operatorType = [result intForColumn:@"operatortype"];
             wishModel.remindId = [result stringForColumn:@"remindid"];
             wishModel.status = [result intForColumn:@"status"];
             wishModel.startDate = [result stringForColumn:@"startdate"];
             wishModel.endDate = [result stringForColumn:@"enddate"];
             wishModel.wishType = [result intForColumn:@"wishtype"];
             wishModel.wishSaveMoney = [NSString stringWithFormat:@"%.2lf",savemoney];
         }
         
         if (success) {
             SSJDispatchMainAsync(^{
                 success(wishModel);
             });
         }
     }];
}


/**
 根据心愿ID完成某个心愿
 
 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)finishWishWithWisId:(NSString *)wishId
                    Success:(void(^)())success
                    failure:(void(^)(NSError *error))failure {
    NSString *date = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        if (![db executeUpdate:@"update bk_wish set operatortype = 1,status = 1,enddate = ? ,iversion = ? ,cwritedate = ? where wishid = ? and cuserid = ?",date,@(SSJSyncVersion()),date,wishId,SSJUSERID()]) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
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
 根据心愿ID删除某个心愿
 
 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)deleteWishWithWisId:(NSString *)wishId
                    Success:(void(^)())success
                    failure:(void(^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_wish set operatortype = 2,iversion = ?,cwritedate = ? where wishid = ? and cuserid = ?",@(SSJSyncVersion()), writeDateStr, wishId, SSJUSERID()]) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
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
 根据心愿ID终止某个心愿
 
 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)terminateWishWithWisId:(NSString *)wishId
                       Success:(void(^)())success
                       failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        NSString *date = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_wish set operatortype = 1, status = 2, enddate = ?,cwritedate = ?, iversion = ? where wishid = ? and cuserid = ?",date, date, @(SSJSyncVersion()),wishId,SSJUSERID()]) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return ;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
        
    }];
}

#pragma mark - 流水操作
/**
 查询某个心愿的所有流水
 
 @param wishId 流水id
 @param success 成功
 @param failure 失败
 */
+ (void)queryWishChargeListWithWishid:(NSString *)wishId
                              success:(void(^)(NSMutableArray <SSJWishChargeItem *> *chargeArray))success
                              failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select * from bk_wish_charge where wishid = ? and cuserid = ? and operatortype <> 2 order by cbilldate desc",wishId,SSJUSERID()];
        if (!result) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return ;
        }
        
        NSMutableArray *chargeArr = [NSMutableArray array];
        while ([result next]) {
            SSJWishChargeItem *item = [[SSJWishChargeItem alloc] init];
            item.chargeId = [result stringForColumn:@"chargeid"];
            item.money = [result stringForColumn:@"money"];
            item.wishId = [result stringForColumn:@"wishid"];
            item.memo = [result stringForColumn:@"memo"];
            item.itype = [result intForColumn:@"itype"];
            item.cbillDate = [result stringForColumn:@"cbilldate"];
            [chargeArr addObject:item];
        }
        if (success) {
            SSJDispatchMainAsync(^{
                success(chargeArr);
            });
        }
    }];
}

/**
 保存心愿流水(新建，修改)
 
 @param wishModel 心愿model
 @param type    0存1取
 @param success 成功
 @param failure 失败
 */
+ (void)saveWishChargeWithWishChargeModel:(SSJWishChargeItem *)wishModel
                                     type:(SSJWishChargeBillType)type
                                  success:(void(^)())success
                                  failure:(void(^)(NSError *error))failure {
    if (!wishModel.wishId) return;
    NSString *chargeId = wishModel.chargeId;
    if (!chargeId) {
        wishModel.chargeId = SSJUUID();
    }
    
    NSString *dateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *billDate = wishModel.cbillDate?: dateStr;
    wishModel.itype = type;
    NSString *money;
    NSArray *keysArr = @[@"chargeid",@"money",@"wishid",@"cuserid",@"iversion",@"cwritedate",@"memo",@"itype",@"cbilldate"];
    NSArray *objectsArr = @[wishModel.chargeId,wishModel.money,wishModel.wishId,SSJUSERID(),@(SSJSyncVersion()),dateStr,wishModel.memo.length?wishModel.memo:@"",@(wishModel.itype),billDate];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:objectsArr forKeys:keysArr];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *sqlStr;
        if ([db boolForQuery:@"select count(1) from bk_wish_charge where cuserid = ? and wishid = ? and chargeid = ?",SSJUSERID(),wishModel.wishId,chargeId]) {
            //更新
            [dict setObject:@(1) forKey:@"operatortype"];
            sqlStr = [self updateChargeSQLStatementWithTypeInfo:dict tableName:@"bk_wish_charge"];
        } else {
            //添加
            [dict setObject:@(0) forKey:@"operatortype"];
            sqlStr = [self insertSQLStatementWithTypeInfo:dict tableName:@"bk_wish_charge"];
        }
        
        
        if (![db executeUpdate:sqlStr withParameterDictionary:dict]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return ;
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }

    }];
}

/**
 删除心愿流水
 
 @param wishId 心愿id
 @param success 成功
 @param failure 失败
 */
+ (void)deleteWishChargeWithWishChargeItem:(SSJWishChargeItem *)wishItem
                                   success:(void(^)())success
                                   failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *dateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_wish_charge set operatortype = 2, cwritedate = ?, iversion =? where cuserid = ? and chargeid = ? and wishid = ?",dateStr,@(SSJSyncVersion()),SSJUSERID(),wishItem.chargeId,wishItem.wishId]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return ;
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}


#pragma mark - 图片操作
/**
 将图片保存到bk_img_sync表中
 
 @param imageName 图片名称
 @param failure 失败回调
 */
+ (BOOL)saveImageToImgSyncTable:(NSString *)imageName
                            rId:(NSString *)rid
                        failure:(void(^)(NSError *error))failure {
    __block BOOL success = NO;
    NSString *dateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        if ([db boolForQuery:@"select count(1) from bk_img_sync where rid = ? and cimgname = ?",rid,imageName]) {
            //更新
           success = [db executeUpdate:@"update bk_img_sync set cwritedate = ?,operatortype = 1"];
        } else {
            //添加
           success = [db executeUpdate:@"insert into bk_img_sync(rid,cimgname,cwritedate,operatortype,isynctype,isyncstate) values(?,?,?,0,2,0)",rid,imageName,dateStr];
        }
        
        if (!success) {
            if (failure) {
                failure(db.lastError);
            }
        }
        
    }];
    
    return success;
}


/**
 将图片从bk_img_sync表中删除
 
 @param imageName 图片名称
 @param failure 失败回调
 */
+ (BOOL)deleteImageFromImgSyncTable:(NSString *)imageName
                                rId:(NSString *)rid
                            failure:(void(^)(NSError *error))failure {
    __block BOOL success = NO;
    NSString *dateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
       success = [db executeUpdate:@"update bk_img_sync set cwitedate = ?,operatortype = 2",dateStr];
    }];
    return success;
}



#pragma mark - Private

+ (NSDictionary *)fieldMapWithTypeItem:(SSJWishModel *)item {
    [SSJWishModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return [SSJWishModel propertyMapping];
    }];
    return item.mj_keyValues;
}

//更新表
+ (NSString *)updateSQLStatementWithTypeInfo:(NSDictionary *)typeInfo tableName:(NSString *)tableName {
    NSMutableArray *keyValues = [NSMutableArray array];
    
    for (NSString *key in [typeInfo allKeys]) {
        [keyValues addObject:[NSString stringWithFormat:@"%@ =:%@", key, key]];
    }
    
    return [NSString stringWithFormat:@"update %@ set %@ where wishid = :wishid and cuserid = :cuserid",tableName, [keyValues componentsJoinedByString:@", "]];
}

//更新流水表
+ (NSString *)updateChargeSQLStatementWithTypeInfo:(NSDictionary *)typeInfo tableName:(NSString *)tableName {
    NSMutableArray *keyValues = [NSMutableArray array];
    
    for (NSString *key in [typeInfo allKeys]) {
        [keyValues addObject:[NSString stringWithFormat:@"%@ =:%@", key, key]];
    }
    
    return [NSString stringWithFormat:@"update %@ set %@ where wishid = :wishid and cuserid = :cuserid and chargeid = :chargeid",tableName, [keyValues componentsJoinedByString:@", "]];
}

//插入表
+ (NSString *)insertSQLStatementWithTypeInfo:(NSDictionary *)typeInfo tableName:(NSString *)tableName {
    NSMutableArray *keys = [[typeInfo allKeys] mutableCopy];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *key in keys) {
        [values addObject:[NSString stringWithFormat:@":%@", key]];
    }
    
    return [NSString stringWithFormat:@"insert into %@ (%@) values (%@)",tableName, [keys componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
}
@end
