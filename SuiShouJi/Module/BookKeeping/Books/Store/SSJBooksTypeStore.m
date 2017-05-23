//
//  SSJBooksTypeStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJDailySumChargeTable.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJFinancingGradientColorItem.h"
#import "SSJUserTableManager.h"
#import "SSJShareBookMemberItem.h"
#import "SSJUserItem.h"

@implementation SSJBooksTypeStore

#pragma mark - 个人账本
+ (void)queryForBooksListWithSuccess:(void(^)(NSMutableArray<SSJBooksTypeItem *> *result))success
                                  failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSMutableArray *booksList = [NSMutableArray array];
        FMResultSet *booksResult = [db executeQuery:@"select * from bk_books_type where cuserid = ? and operatortype <> 2 order by iorder asc , cwritedate asc",userid];
        int order = 1;
        if (!booksResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([booksResult next]) {
            SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
            item.booksId = [booksResult stringForColumn:@"cbooksid"];
            item.booksName = [booksResult stringForColumn:@"cbooksname"];
            
            //处理渐变色
            SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
            NSArray *colorArray = [[booksResult stringForColumn:@"cbookscolor"] componentsSeparatedByString:@","];
            if (colorArray.count > 1) {
                colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                colorItem.endColor = [colorArray ssj_safeObjectAtIndex:1];
            } else if (colorArray.count == 1) {
                colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                colorItem.endColor = [colorArray ssj_safeObjectAtIndex:0];
            }
            item.booksColor = colorItem;
            
            item.userId = [booksResult stringForColumn:@"cuserid"];
            item.booksIcoin = [booksResult stringForColumn:@"cicoin"];
            item.booksOrder = [booksResult intForColumn:@"iorder"];
            item.booksParent = [booksResult intForColumn:@"iparenttype"];
            if (item.booksOrder == 0) {
                item.booksOrder = order;
            }
            [booksList addObject:item];
            order ++;
        }
        SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
        item.booksName = @"添加账本";
        SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
        colorItem.startColor = colorItem.endColor = @"#FFFFFF";
        item.booksColor = colorItem;
        [booksList addObject:item];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(booksList);
            });
        }
    }];
}

+ (void)saveBooksTypeItem:(SSJBooksTypeItem *)item
                   sucess:(void(^)())success
                  failure:(void (^)(NSError *error))failure{
    NSString * booksid = item.booksId;
    if (!booksid.length) {
        item.booksId = SSJUUID();
    }
    if (!item.userId.length) {
        item.userId = SSJUSERID();
    }
    item.cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableDictionary * typeInfo = [NSMutableDictionary dictionaryWithDictionary:[self fieldMapWithTypeItem:item]];
    [typeInfo removeObjectForKey:@"selectToEdite"];
    [typeInfo removeObjectForKey:@"editeModel"];
    if (![[typeInfo allKeys] containsObject:@"iversion"]) {
        [typeInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
    }
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString * sql;
        NSString *userId = SSJUSERID();
        if ([db intForQuery:@"select count(1) from BK_BOOKS_TYPE where cbooksname = ? and cuserid = ? and cbooksid <> ? and operatortype <> 2",item.booksName,userId,item.booksId]) {
            SSJDispatch_main_async_safe(^{
                [CDAutoHideMessageHUD showMessage:@"已有相同账本名称了，换一个吧"];
            });
            return;
        }
        int booksOrder = [db intForQuery:@"select max(iorder) from bk_books_type where cuserid = ?",userId] + 1;
        if ([item.booksId isEqualToString:userId]) {
            booksOrder = 1;
        }
        if (![db boolForQuery:@"select count(*) from BK_BOOKS_TYPE where CBOOKSID = ?", booksid]) {
            [typeInfo setObject:@(booksOrder) forKey:@"iorder"];
            [typeInfo setObject:@(0) forKey:@"operatortype"];
            sql = [self inertSQLStatementWithTypeInfo:typeInfo tableName:@"BK_BOOKS_TYPE"];
        } else {
            [typeInfo setObject:@(1) forKey:@"operatortype"];
            sql = [self updateSQLStatementWithTypeInfo:typeInfo tableName:@"BK_BOOKS_TYPE"];
        }
        if (![db executeUpdate:sql withParameterDictionary:typeInfo]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        if (![db boolForQuery:@"select count(*) from BK_BOOKS_TYPE where CBOOKSID = ?", booksid]) {
            if (![self generateBooksTypeForBooksItem:item indatabase:db forUserId:userId]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (void)saveBooksOrderWithItems:(NSArray *)items
                         sucess:(void(^)())success
                             failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        for (SSJBooksTypeItem *item in items) {
            NSInteger order = [items indexOfObject:item] + 1;
            NSString *userid = SSJUSERID();
            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            if (![db executeUpdate:@"update bk_books_type set iorder = ?, iversion = ?, cwritedate = ? ,operatortype = 1 where cbooksid = ? and cuserid = ? and operatortype <> 2",@(order),@(SSJSyncVersion()),writeDate,item.booksId,userid]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (NSDictionary *)fieldMapWithTypeItem:(SSJBooksTypeItem *)item {
    [SSJBooksTypeItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return [SSJBooksTypeItem propertyMapping];
    }];
    return item.mj_keyValues;
}


+ (NSString *)inertSQLStatementWithTypeInfo:(NSDictionary *)typeInfo tableName:(NSString *)tableName {
    NSMutableArray *keys = [[typeInfo allKeys] mutableCopy];
    //处理渐变
    if ([keys containsObject:@"cbookscolor"]) {
       id bookColorDic = [typeInfo objectForKey:@"cbookscolor"];
        if ([bookColorDic isKindOfClass:[NSDictionary class]]) {
          NSString *startColor = [(NSDictionary *)bookColorDic objectForKey:@"startColor"];
          NSString *endColor = [(NSDictionary *)bookColorDic objectForKey:@"endColor"];
            NSString *colorStr = [NSString stringWithFormat:@"%@,%@",startColor,endColor];
            [typeInfo setValue:colorStr forKey:@"cbookscolor"];
        }
    }
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *key in keys) {
        [values addObject:[NSString stringWithFormat:@":%@", key]];
    }
    
    return [NSString stringWithFormat:@"insert into %@ (%@) values (%@)",tableName, [keys componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
}

+ (NSString *)updateSQLStatementWithTypeInfo:(NSDictionary *)typeInfo tableName:(NSString *)tableName {
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:[typeInfo count]];
    for (NSString *key in [typeInfo allKeys]) {
        [keyValues addObject:[NSString stringWithFormat:@"%@ =:%@", key, key]];
    }
    
    return [NSString stringWithFormat:@"update %@ set %@ where cbooksid = :cbooksid",tableName, [keyValues componentsJoinedByString:@", "]];
}

+(SSJBooksTypeItem *)queryCurrentBooksTypeForBooksId:(NSString *)booksid{
    __block SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_books_type where cbooksid = ?",booksid];
        while ([resultSet next]) {
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.booksName = [resultSet stringForColumn:@"cbooksname"];
//            item.booksColor = [resultSet stringForColumn:@"cbookscolor"];
            //处理渐变色
            SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
            NSArray *colorArray = [[resultSet stringForColumn:@"cbookscolor"] componentsSeparatedByString:@","];
            if (colorArray.count > 1) {
                colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                colorItem.endColor = [colorArray ssj_safeObjectAtIndex:1];
            } else if (colorArray.count == 1) {
                colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                colorItem.endColor = [colorArray ssj_safeObjectAtIndex:0];
            }
            item.booksColor = colorItem;
            item.booksIcoin = [resultSet stringForColumn:@"cicoin"];
        }
    }];
    return item;
}

+ (void)deleteBooksTypeWithbooksItems:(NSArray *)items
                           deleteType:(BOOL)type
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userId = SSJUSERID();
        if (!type) {
            for (SSJBooksTypeItem *item in items) {
                if (![db executeUpdate:@"update bk_books_type set operatortype = 2 ,cwritedate = ? ,iversion = ? where cbooksid = ?",[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.booksId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
            }
        }else{
            for (SSJBooksTypeItem *item in items) {
                if (![db executeUpdate:@"update bk_books_type set operatortype = 2 ,cwritedate = ? ,iversion = ? where cbooksid = ?",[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.booksId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
                if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 ,cwritedate = ? ,iversion = ? where cbooksid = ?",[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.booksId]) {
                    *rollback = YES;
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
                //更新日常统计表
                if (![SSJDailySumChargeTable updateDailySumChargeForUserId:userId inDatabase:db]) {
                    if (failure) {
                        *rollback = YES;
                        SSJDispatchMainAsync(^{
                            failure([db lastError]);
                        });
                    }
                    return;
                }
                
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (BOOL)generateBooksTypeForBooksItem:(__kindof SSJBaseCellItem *)item
                           indatabase:(FMDatabase *)db
                               forUserId:(NSString *)userId{
    if ([item isKindOfClass:[SSJBooksTypeItem class]]) { //个人账本
        SSJBooksTypeItem *privateBookItem = (SSJBooksTypeItem *)item;
        
        // 补充每个账本独有的记账类型
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.sss"];
        if (![db intForQuery:@"select count(1) from bk_user_bill where cbooksid = ?",privateBookItem.booksId]) {
            if (![db executeUpdate:@"insert into bk_user_bill select ?, id, istate, ?, ?, 1, defaultorder,? from bk_bill_type where ibookstype = ? and icustom = 0",userId,writeDate,@(SSJSyncVersion()),privateBookItem.booksId,@(privateBookItem.booksParent)]) {
                return NO;
            }
        }
        
        // 补充账本公用的记账类型
        FMResultSet *result = [db executeQuery:@"select id ,defaultorder ,ibookstype from bk_bill_type where length(ibookstype) > 1"];
        
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        
        while ([result next]) {
            NSString *cbillid = [result stringForColumn:@"id"];
            NSString *defualtOrder = [result stringForColumn:@"defaultorder"];
            NSString *iparenttype = [result stringForColumn:@"ibookstype"];
            NSDictionary *dic = @{@"kBillIdKey":cbillid,
                                  @"kDefualtOrderKey":defualtOrder,
                                  @"kParentTypeKey":iparenttype};
            [tempArr addObject:dic];
        };
        
        for (NSDictionary *dict in tempArr) {
            NSString *cbillid = [dict objectForKey:@"kBillIdKey"];
            NSString *defualtOrder = [dict objectForKey:@"kDefualtOrderKey"];
            NSString *iparenttype = [dict objectForKey:@"kParentTypeKey"];
            NSArray *parentArr = [iparenttype componentsSeparatedByString:@","];
            for (NSString *parenttype in parentArr) {
                if ([parenttype integerValue] == privateBookItem.booksParent) {
                    if (![db executeUpdate:@"insert into bk_user_bill values (?,?,1,?,?,1,?,?)",userId,cbillid,writeDate,@(SSJSyncVersion()),defualtOrder,privateBookItem.booksId]) {
                        return NO;
                    }
                }
            }
        }
    } else if ([item isKindOfClass:[SSJShareBookItem class]]) {//共享账本
        
    }
    return YES;
}

+ (void)getTotalIncomeAndExpenceWithSuccess:(void(^)(double income,double expenture))success
                                    failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        double income = [db doubleForQuery:@"select sum(uc.imoney) from bk_user_charge uc, bk_bill_type bt where uc.ibillid = bt.id and bt.itype = 0 and uc.cuserid = ? and bt.istate <> 2 and uc.operatortype <> 2 and uc.cbilldate <= date('now', 'localtime')",userId];
        double expenture = [db doubleForQuery:@"select sum(uc.imoney) from bk_user_charge uc, bk_bill_type bt where uc.ibillid = bt.id and bt.itype = 1 and uc.cuserid = ? and bt.istate <> 2 and uc.operatortype <> 2 and uc.cbilldate <= date('now', 'localtime')",userId];
        if (success) {
            SSJDispatchMainAsync(^{
                success(income,expenture);
            });
        }
    }];
}

#pragma mark - 共享账本
+ (void)queryForShareBooksListWithSuccess:(void(^)(NSMutableArray<SSJShareBookItem *> *result))success failure:(void(^)(NSError *error))failure {
    NSMutableArray *shareBooksList = [NSMutableArray array];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
       FMResultSet *result = [db executeQuery:@"select t.*,(select count(*) from bk_share_books_member t1 where t1.cbooksid = t.cbooksid and t1.istate = 1) as memberCount from bk_share_books t where t.cbooksid in (select s.cbooksid from bk_share_books_member s where s.cmemberid = ? and s.istate = 1) and t.operatortype <> 2 order by t.iorder asc, t.cwritedate asc",SSJUSERID()];//select * from bk_share_books where operatortype <> 2 order by iorder asc, cwritedate asc
        if (!result) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return ;
        }
        while ([result next]) {
            SSJShareBookItem *shareBookItem = [[SSJShareBookItem alloc] init];
            shareBookItem.booksId = [result stringForColumn:@"cbooksid"];
            shareBookItem.booksName = [result stringForColumn:@"cbooksname"];
//            shareBookItem.booksColor = [result stringForColumn:@"cbookscolor"];
            shareBookItem.parentType = [result intForColumn:@"iparenttype"];
            shareBookItem.booksOrder = [result intForColumn:@"iorder"];
            shareBookItem.memberCount = [result intForColumn:@"memberCount"];
            //处理渐变色
            SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
            NSArray *colorArray = [[result stringForColumn:@"cbookscolor"] componentsSeparatedByString:@","];
            if (colorArray.count > 1) {
                colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                colorItem.endColor = [colorArray ssj_safeObjectAtIndex:1];
            } else if (colorArray.count == 1) {
                colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                colorItem.endColor = [colorArray ssj_safeObjectAtIndex:0];
            }
            shareBookItem.booksColor = colorItem;
            
            [shareBooksList addObject:shareBookItem];
        }
        //最后一个添加账本
        SSJShareBookItem *lastItem = [[SSJShareBookItem alloc]init];
        lastItem.booksName = @"添加账本";
        SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
        colorItem.startColor = colorItem.endColor = @"#FFFFFF";
        lastItem.booksColor = colorItem;
        [shareBooksList addObject:lastItem];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(shareBooksList);
            });
        }
    }];
}


/**
 *  保存账本类型
 *
 *  @return (BOOL) 是否保存成功
 */
+ (void)saveShareBooksTypeItem:(SSJShareBookItem *)item
                        sucess:(void(^)())success
                       failure:(void (^)(NSError *error))failure {
    NSString * booksid = item.booksId;
    if (!item.booksId.length) {
       booksid = item.booksId = SSJUUID();
    }
    if (!item.creatorId.length) {
        item.creatorId = SSJUSERID();
    }
    if (!item.adminId.length) {
        item.adminId = SSJUSERID();
    }
    
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSMutableDictionary *shareBookInfo = [NSMutableDictionary dictionaryWithDictionary:[self fieldMapWithShareBookItem:item]];
    [shareBookInfo removeObjectForKey:@"editing"];
    [shareBookInfo removeObjectForKey:@"memberCount"];
    [shareBookInfo setObject:cwriteDate forKey:@"CADDDATE"];
    if (![[shareBookInfo allKeys] containsObject:@"iversion"]) {
        [shareBookInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
    }
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *sqlStr;
        NSString *userId = SSJUSERID();
        if ([db intForQuery:@"select count(1) from bk_share_books where cbooksname = ?  and ccreator = ? and cadmin = ?and cbooksid <> ?",item.booksName,item.creatorId,item.adminId,item.booksId]) {
            SSJDispatch_main_async_safe(^{
                [CDAutoHideMessageHUD showMessage:@"已有相同账本名称了，换一个吧"];
            });
            return;
        }
        
        item.booksOrder = [db intForQuery:@"select max(iorder) from bk_share_books where ccreator = ?",item.creatorId] + 1;
        
        if ([item.booksId isEqualToString:userId]) {
            item.booksOrder = 0;
        }
        if (![db boolForQuery:@"select count(*) from bk_share_books where CBOOKSID = ?", booksid]) {
            [shareBookInfo setObject:@(item.booksOrder) forKey:@"iorder"];
            [shareBookInfo setObject:@(0) forKey:@"operatortype"];
            sqlStr = [self inertSQLStatementWithTypeInfo:shareBookInfo tableName:@"bk_share_books"];
        } else {
            [shareBookInfo setObject:@(1) forKey:@"operatortype"];
            sqlStr = [self updateSQLStatementWithTypeInfo:shareBookInfo tableName:@"bk_share_books"];
        }
        
        if (![db executeUpdate:sqlStr withParameterDictionary:shareBookInfo]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        
        //账本类别
//        if (![db boolForQuery:@"select count(*) from bk_share_books where CBOOKSID = ?", booksid]) {
//            if (![self generateBooksTypeForBooksItem:item indatabase:db forUserId:userId]) {
//                if (failure) {
//                    SSJDispatch_main_async_safe(^{
//                        failure([db lastError]);
//                    });
//                }
//                return;
//            }
//        }
        
        //成员信息
        
        if (success) {
            [self saveShareBooksMemberWithBookId:booksid success:nil failure:nil];
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (void)saveShareBooksOrderWithItems:(NSArray<SSJShareBookItem *> *)items sucess:(void (^)())success failure:(void (^)(NSError *))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        for (SSJShareBookItem *item in items) {
            NSInteger order = [items indexOfObject:item] + 1;
            NSString *creatorId = item.creatorId;
            if (!creatorId) {
                creatorId = SSJUSERID();
            }
            if (!item.booksId) return ;
            NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSString *sqlStr = [NSString stringWithFormat:@"update bk_share_books set iorder = %@, iversion = %@, cadddate = '%@' where cbooksid = '%@' and ccreator = '%@'",@(order),@(SSJSyncVersion()),writeDate,item.booksId,creatorId];
            if (![db executeUpdate:sqlStr]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return ;
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}


+ (void)saveShareBooksMemberWithBookId:(NSString *)bookId
                       success:(void(^)())success
                       failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        SSJShareBookMemberItem *memberItem = [[SSJShareBookMemberItem alloc] init];
        memberItem.memberId = SSJUSERID();
        memberItem.booksId = bookId;
        memberItem.joinDate = [[NSDate date] formattedDateWithFormat:@"yyyy-mm-dd"];
        memberItem.state = 1;
        
        if (SSJIsUserLogined()) {//登录
            //查询当前用户信息
            [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull item) {
                if (!item.icon) {
                    item.icon = @"defualt_portrait";
                }
                memberItem.icon = item.icon;

            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
            
        } else {
            memberItem.icon = @"defualt_portrait";
        }
        if (![db executeUpdate:@"insert into BK_SHARE_BOOKS_MEMBER values (?,?,?,?,?)",memberItem.memberId,memberItem.booksId,memberItem.joinDate,@(memberItem.state),memberItem.icon]) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return ;
        }
        SSJDispatch_main_sync_safe(^{
            if (success) {
                success();
            }
        });
    }];
}


+ (NSDictionary *)fieldMapWithShareBookItem:(SSJShareBookItem *)item {
    [SSJShareBookItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return [SSJShareBookItem propertyMapping];
    }];
    return item.mj_keyValues;
}



@end
