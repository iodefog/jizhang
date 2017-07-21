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
 将图片保存到bk_wish表中
 
 @param imageName 图片名称
 @param type 保存图片类型
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)saveImageToWishTable:(NSString *)imageName
                    saveType:(SSJSaveImgType)type
                     success:(void(^)(NSString *imageName))success
                     failure:(void(^)(NSError *error))failure {
    if (type == SSJSaveImgTypeLocal) {
        
    } else if (type == SSJSaveImgTypeCustom) {
        
    }
}

/**
 将图片保存到bk_img_sync表中
 
 @param imageName 图片名称
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)saveImageToImgSyncTable:(NSString *)imageName
                        success:(void(^)(NSString *imageName))success
                        failure:(void(^)(NSError *error))failure {
    
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
        NSMutableDictionary * typeInfo = [NSMutableDictionary dictionaryWithDictionary:[self fieldMapWithTypeItem:wishModel]];
        [typeInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
        NSString *sqlStr = @"";
        if ([db boolForQuery:@"select count(1) from bk_wish where cuserid = ? and wishid = ?",SSJUSERID(),wishId]) {
            //更新
            [typeInfo setObject:@(1) forKey:@"operatortype"];
            sqlStr = [self updateSQLStatementWithTypeInfo:typeInfo tableName:@"bk_wish"];
            sqlStr = @"";
        } else {
            //新增
            [typeInfo setObject:@(0) forKey:@"operatortype"];
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
 查询心愿列表
 
 @param state 已完成或者未完成
 @param success 成功
 @param failure 失败
 */
+ (void)queryIngWishWithState:(SSJWishState)state
                      success:(void(^)(NSMutableArray <SSJWishModel *>*resultArr))success
                      failure:(void(^)(NSError *error))failure {
    
    NSMutableString *queryStr;
    
    if (state == SSJWishStateFinish) {
        queryStr = [NSMutableString stringWithFormat:@"select bw.*,(select sum(bwc.money) from bk_wish_charge bwc where bw.wishid = bwc.wishid) as savemoney from bk_wish  as bw where bw.cuserid = '%@' and bw.operatortype <> 2 and status = 1 order by bw.startdate asc",SSJUSERID()];

    } else if (state == SSJWishStateNormalIng) {
        queryStr = [NSMutableString stringWithFormat:@"select bw.*,(select sum(bwc.money) from bk_wish_charge bwc where bw.wishid = bwc.wishid) as savemoney from bk_wish  as bw where bw.cuserid = '%@' and bw.operatortype <> 2 and status <> 1 order by bw.startdate asc",SSJUSERID()];
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
            wishModel.wishMoney = [result stringForColumn:@"wishmoney"];
            wishModel.wishImage = [result stringForColumn:@"wishimage"];
            wishModel.cwriteDate = [result stringForColumn:@"cwritedate"];
            wishModel.operatorType = [result intForColumn:@"operatortype"];
            wishModel.remindId = [result stringForColumn:@"remindid"];
            wishModel.status = [result intForColumn:@"status"];
            wishModel.startDate = [result stringForColumn:@"startdate"];
            wishModel.endDate = [result stringForColumn:@"enddate"];
            wishModel.wishType = [result intForColumn:@"wishtype"];
            wishModel.wishSaveMoney = [NSString stringWithFormat:@"%ld",[result longForColumn:@"savemoney"]];
            [relultArray addObject:wishModel];
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(relultArray);
            });
        }
        
    }];

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
