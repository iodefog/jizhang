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
#import "SSJUserChargeSyncTable.h"
#import "SSJUserDefaultBillTypesCreater.h"

@implementation SSJBooksTypeStore

+ (void)queryCurrentBooksItemWithSuccess:(void(^)(id<SSJBooksItemProtocol> booksItem))success
                                 failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        booksid = booksid.length > 0 ? booksid : SSJUSERID();
        
        FMResultSet *rs;
        id currentBooksItem;
        if ([db boolForQuery:@"select count(1) from bk_books_type where cbooksid = ?",booksid]) {
            rs = [db executeQuery:@"select * from bk_books_type where cbooksid = ?",booksid];
            if (!rs) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            while ([rs next]) {
                SSJBooksTypeItem *booksItem = [[SSJBooksTypeItem alloc] init];
                booksItem.booksId = [rs stringForColumn:@"cbooksid"];
                booksItem.booksName = [rs stringForColumn:@"cbooksname"];
                booksItem.booksOrder = [rs intForColumn:@"iorder"];
                booksItem.booksParent = [rs intForColumn:@"iparenttype"];
                SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
                NSArray *colorArray = [[rs stringForColumn:@"cbookscolor"] componentsSeparatedByString:@","];
                if (colorArray.count > 1) {
                    colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                    colorItem.endColor = [colorArray ssj_safeObjectAtIndex:1];
                } else if (colorArray.count == 1) {
                    colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                    colorItem.endColor = [colorArray ssj_safeObjectAtIndex:0];
                }
                booksItem.booksColor = colorItem;
                currentBooksItem = booksItem;

            }
        } else {
            rs = [db executeQuery:@"select sb.*, count(bm.cmemberid) as memberCount from bk_share_books sb, bk_share_books_member bm where sb.cbooksid = ? and sb.cbooksid = bm.cbooksid and bm.istate = 0",booksid];
            if (!rs) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            while ([rs next]) {
                SSJShareBookItem *shareBookItem = [[SSJShareBookItem alloc] init];
                shareBookItem.booksId = [rs stringForColumn:@"cbooksid"];
                shareBookItem.booksName = [rs stringForColumn:@"cbooksname"];
                shareBookItem.booksParent = [rs intForColumn:@"iparenttype"];
                shareBookItem.booksOrder = [rs intForColumn:@"iorder"];
                shareBookItem.memberCount = [rs intForColumn:@"memberCount"];
                shareBookItem.adminId = [rs stringForColumn:@"cadmin"];
                //处理渐变色
                SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
                NSArray *colorArray = [[rs stringForColumn:@"cbookscolor"] componentsSeparatedByString:@","];
                if (colorArray.count > 1) {
                    colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                    colorItem.endColor = [colorArray ssj_safeObjectAtIndex:1];
                } else if (colorArray.count == 1) {
                    colorItem.startColor = [colorArray ssj_safeObjectAtIndex:0];
                    colorItem.endColor = [colorArray ssj_safeObjectAtIndex:0];
                }
                shareBookItem.booksColor = colorItem;
                currentBooksItem = shareBookItem;
            }
        }
        [rs close];
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(currentBooksItem);
            });
        }
    }];
}


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
            item.booksOrder = [booksResult intForColumn:@"iorder"];
            item.booksParent = [booksResult intForColumn:@"iparenttype"];
            if (item.booksOrder == 0) {
                item.booksOrder = order;
            }
            [booksList addObject:item];
            order ++;
        }
        
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
        if (![db boolForQuery:@"select count(*) from BK_BOOKS_TYPE where CBOOKSID = ?", booksid]) {//添加
            [typeInfo setObject:@(booksOrder) forKey:@"iorder"];
            [typeInfo setObject:@(0) forKey:@"operatortype"];
            [typeInfo setObject:[item parentIcon] forKey:@"cicoin"];
            sql = [self inertSQLStatementWithTypeInfo:typeInfo tableName:@"BK_BOOKS_TYPE"];
        } else { //修改
            [typeInfo setObject:@(1) forKey:@"operatortype"];
            sql = [self updateSQLStatementWithTypeInfo:typeInfo tableName:@"BK_BOOKS_TYPE"];
        }
        
        if (![db boolForQuery:@"select count(*) from BK_BOOKS_TYPE where CBOOKSID = ?", booksid]) {//判断添加账本还是修改账本
            NSError *tError = nil;
            [SSJUserDefaultBillTypesCreater createDefaultDataTypeForUserId:userId booksId:item.booksId booksType:item.booksParent inDatabase:db error:&tError];
            if (tError) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure(tError);
                    });
                }
                return;
            }
        }
        
        if (![db executeUpdate:sql withParameterDictionary:typeInfo]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
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
    //处理渐变颜色
    if ([[typeInfo allKeys] containsObject:@"cbookscolor"]) {
        id bookColorDic = [typeInfo objectForKey:@"cbookscolor"];
        if ([bookColorDic isKindOfClass:[NSDictionary class]]) {
            if ([[bookColorDic allKeys] containsObject:@"endColor"] && [[bookColorDic allKeys] containsObject:@"startColor"] ) {
                [typeInfo setValue:[NSString stringWithFormat:@"%@,%@",bookColorDic[@"startColor"],bookColorDic[@"endColor"]] forKey:@"cbookscolor"];
            }
        }
    }
    
    for (NSString *key in [typeInfo allKeys]) {
        [keyValues addObject:[NSString stringWithFormat:@"%@ =:%@", key, key]];
    }
    
    return [NSString stringWithFormat:@"update %@ set %@ where cbooksid = :cbooksid",tableName, [keyValues componentsJoinedByString:@", "]];
}

+ (void)deleteBooksTypeWithbooksItems:(NSArray *)items
                           deleteType:(BOOL)type
                              Success:(void(^)(BOOL bookstypeHasChange))success
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

            }
        }
        
        NSString *currentBooksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        
        BOOL booksTypeHasChange = NO;
        
        for (SSJBooksTypeItem *item in items) {
            if ([item.booksId isEqualToString:currentBooksId]) {
                if (![db executeUpdate:@"update bk_user set ccurrentbooksid = ? where cuserid = ?",userId,userId]) {
                    booksTypeHasChange = YES;
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
                success(booksTypeHasChange);
            });
        }
    }];
}

+ (void)getTotalIncomeAndExpenceWithSuccess:(void(^)(double income,double expenture))success
                                    failure:(void (^)(NSError *error))failure{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        double income = [db doubleForQuery:@"select sum(uc.imoney) from bk_user_charge uc, bk_user_bill_type bt where uc.ibillid = bt.cbillid and bt.itype = 0 and uc.cuserid = ? and uc.operatortype <> 2 and uc.cbilldate <= date('now', 'localtime')",userId];
        double expenture = [db doubleForQuery:@"select sum(uc.imoney) from bk_user_charge uc, bk_user_bill_type bt where uc.ibillid = bt.cbillid and bt.itype = 1 and uc.cuserid = ? and uc.operatortype <> 2 and uc.cbilldate <= date('now', 'localtime')",userId];
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
        FMResultSet *result = [db executeQuery:@"select t.*,(select count(*) from bk_share_books_member t1 where t1.cbooksid = t.cbooksid and t1.istate = 0) as memberCount from bk_share_books t where t.cbooksid in (select s.cbooksid from bk_share_books_member s where s.cmemberid = ? and s.istate = 0) order by t.iorder asc, t.cwritedate asc",SSJUSERID()];
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
            shareBookItem.booksParent = [result intForColumn:@"iparenttype"];
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
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(shareBooksList);
            });
        }
    }];
}


/**
 *  保存账本类型(共享)
 *
 *  @return (BOOL) 是否保存成功
 */
+ (void)saveShareBooksTypeItem:(SSJShareBookItem *)item
               WithshareMember:(NSArray<NSDictionary *> *)shareMember
             shareFriendsMarks:(NSArray<NSDictionary *> *)shareFriendsMarks
              ShareBookOperate:(ShareBookOperate)shareBookOperate
                        sucess:(void(^)())success
                       failure:(void (^)(NSError *error))failure {
    if (!item.booksId.length) return;
    
    if (!item.creatorId.length) {
        item.creatorId = SSJUSERID();
    }
    
    if (!item.adminId.length) {
        item.adminId = SSJUSERID();
    }
    
    NSMutableDictionary *shareBookInfo = [NSMutableDictionary dictionaryWithDictionary:[self fieldMapWithShareBookItem:item]];
    [shareBookInfo removeObjectForKey:@"editing"];
    [shareBookInfo removeObjectForKey:@"memberCount"];
    if (![[shareBookInfo allKeys] containsObject:@"iversion"]) {
        [shareBookInfo setObject:@(SSJSyncVersion()) forKey:@"iversion"];
    }
    
    if (![[shareBookInfo allKeys] containsObject:@"cbooksname"]) {
        [shareBookInfo setObject:item.booksName forKey:@"cbooksname"];
    }
    
    //处理渐变色
    if (![[shareBookInfo allKeys] containsObject:@"cbookscolor"]) {
        SSJFinancingGradientColorItem *gradItem = item.booksColor;
        NSMutableArray *gradArr = [NSMutableArray array];
        if (gradItem.startColor) {
            [gradArr addObject:gradItem.startColor];
        }
        if (gradItem.endColor) {
            [gradArr addObject:gradItem.endColor];
        }
        [shareBookInfo setObject:[gradArr componentsJoinedByString:@","] forKey:@"cbookscolor"];
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
        
        //共享账本账本名称不做限制
        //        if ([db intForQuery:@"select count(1) from bk_share_books t where t.cbooksid in (select s.cbooksid from bk_share_books_member s where s.cmemberid = ? and s.istate = 0) and t.operatortype <> 2 and cbooksname = ? and cbooksid <> ?",SSJUSERID(),item.booksName,item.booksId]) {
        //            SSJDispatch_main_async_safe(^{
        //                [CDAutoHideMessageHUD showMessage:@"已有相同账本名称了，换一个吧"];
        //            });
        //            return;
        //        }
        item.booksOrder = [db intForQuery:@"select max(iorder) from bk_share_books"] + 1;
        NSString *sqlStr;
        if (shareBookOperate == ShareBookOperateCreate) {//添加
            [shareBookInfo setObject:@(item.booksOrder) forKey:@"iorder"];
            [shareBookInfo setObject:[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cadddate"];
            [shareBookInfo setObject:@(0) forKey:@"operatortype"];
            sqlStr = [self inertSQLStatementWithTypeInfo:shareBookInfo tableName:@"bk_share_books"];
        } else if(shareBookOperate == ShareBookOperateEdite){//修改
            [shareBookInfo setObject:@(1) forKey:@"operatortype"];
            [shareBookInfo setObject:[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cwritedate"];
            sqlStr = [self updateSQLStatementWithTypeInfo:shareBookInfo tableName:@"bk_share_books"];
        }
        
        if (![db executeUpdate:sqlStr withParameterDictionary:shareBookInfo]) {
            *rollback = YES;
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        //账本类别(新建)
        if (shareBookOperate == ShareBookOperateCreate) {
            NSError *tError = nil;
            [SSJUserDefaultBillTypesCreater createDefaultDataTypeForUserId:SSJUSERID() booksId:item.booksId booksType:item.booksParent inDatabase:db error:&tError];
            if (tError) {
                *rollback = YES;
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure(tError);
                    });
                }
                return;
            }
        }
        
        //如果是新建时候生成成员信息和昵称
        if (shareBookOperate == ShareBookOperateCreate) {
            if (![self saveShareBooksMemberWithBookId:item shareMember:shareMember inDatabase:db]) {
                *rollback = YES;
                if ([db lastError]) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            if (![self saveShareBookMemberNickWithBookId:item.booksId shareFriendsMarks:shareFriendsMarks inDatabase:db]) {
                *rollback = YES;
                if ([db lastError]) {
                    SSJDispatchMainAsync(^{
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


/**
 删除账本(共享账本)
 @param item share_charge	bk_user_charge	平账流水
 share_member	bk_share_books_member	共享成员
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)deleteShareBooksWithShareCharge:(NSArray<NSDictionary *> *)shareCharge
                            shareMember:(NSArray<NSDictionary *> *)shareMember
                                 bookId:(NSString *)bookId
                                 sucess:(void(^)(BOOL bookstypeHasChange))success
                                failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userId = SSJUSERID();
        //更新bk_user_charge表
        if (![SSJUserChargeSyncTable mergeRecords:shareCharge forUserId:SSJUSERID() inDatabase:db error:nil]) {
            *rollback = YES;
            if ([db lastError]) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return ;
        }
        
        //更新bk_share_books_member表
        NSArray *memberArr = @[@"cmemberid",
                               @"cbooksid",
                               @"cjoindate",
                               @"istate"];
        
        [shareMember enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *mergeRecord = [NSMutableDictionary dictionary];
            for (NSString *key in memberArr) {
                [mergeRecord setObject:[dic objectForKey:key]?:@"" forKey:key];
            }
            
            NSMutableArray *keyValues = [NSMutableArray array];
            [mergeRecord enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [keyValues addObject:[NSString stringWithFormat:@"%@ = :%@", key, key]];
                [mergeRecord setObject:obj forKey:key];
            }];
            
            NSString *keyValuesStr = [keyValues componentsJoinedByString:@", "];
            NSString *sqlStr = [NSString stringWithFormat:@"update bk_share_books_member set %@ where cmemberid = '%@' and cbooksid = '%@'",keyValuesStr,[mergeRecord objectForKey:@"cmemberid"],[mergeRecord objectForKey:@"cbooksid"]];
            
            if (![db executeUpdate:sqlStr withParameterDictionary:mergeRecord]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
            }
        }];
        
        //退出账本 移除账本 移除本地账本的备注
        if (![self deleteMemberMarkWithBookId:bookId inDatabase:db]) {
            if (failure) {
                *rollback = YES;
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (![self deleteSharebooksWithBooksid:bookId inDatabase:db]) {
            if (failure) {
                *rollback = YES;
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        

        BOOL booksTypeHasChange = NO;
        
        NSString *currentBooksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        
        if ([bookId isEqualToString:currentBooksId]) {
            booksTypeHasChange = YES;
            if (![db executeUpdate:@"update bk_user set ccurrentbooksid = ? where cuserid = ?",userId,userId]) {
                if (failure) {
                    *rollback = YES;
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(booksTypeHasChange);
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
            NSString *bookId;
            if ([item isKindOfClass:[SSJShareBookItem class]]) {
                bookId = ((SSJShareBookItem *)item).booksId;
            } else if ([item isKindOfClass:[SSJBooksTypeItem class]]) {
                bookId = ((SSJBooksTypeItem *)item).booksId;
            }
            if (!bookId.length && ![item.booksName isEqualToString:@"添加账本"]) return ;
            NSString *sqlStr = [NSString stringWithFormat:@"update bk_share_books set iorder = %@ where cbooksid = '%@'",@(order),bookId];
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
                           shareMember:(NSArray<NSDictionary *> *)shareMember
                               success:(void(^)())success
                               failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        __block NSString *iconStr;
        if (SSJIsUserLogined()) {//登录
            //查询当前用户信息
            [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull item) {
                if (!item.icon) {
                    item.icon = @"defualt_portrait";
                }
                iconStr = item.icon;
                
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
            
        } else {
            iconStr = @"defualt_portrait";
        }
        
        NSArray *memberArr = @[@"cmemberid",
                               @"cbooksid",
                               @"cjoindate",
                               @"istate",
                               @"cicon",
                               @"ccolor",
                               @"cleavedate"];
        //更新bk_share_books_member表
        [shareMember enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *memberDic = [dic mutableCopy];
            [memberDic setObject:iconStr?:@"defualt_portrait" forKey:@"cicon"];
            NSString *memberKey = [memberArr componentsJoinedByString:@", "];
            
            NSMutableArray *memberValueArr = [NSMutableArray array];
            for (NSString *key in memberArr) {
                [memberValueArr addObject:[NSString stringWithFormat:@"'%@'",[memberDic objectForKey:key]]];
            }
            
            NSString *memberValue = [memberValueArr componentsJoinedByString:@", "];
            NSString *sqlStr = [NSString stringWithFormat:@"insert into bk_share_books_member (%@) values(%@)",memberKey,memberValue];
            if (![db executeUpdate:sqlStr]) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
        }];
        
        SSJDispatch_main_sync_safe(^{
            if (success) {
                success();
            }
        });
    }];
}


/**
 保存用户信息
 
 @param bookId <#bookId description#>
 @param shareFriendsMarks <#shareFriendsMarks description#>
 @param success <#success description#>
 @param failure <#failure description#>
 @return <#return value description#>
 */
+ (BOOL)saveShareBooksMemberWithBookId:(SSJShareBookItem *)item
                           shareMember:(NSArray<NSDictionary *> *)shareMember
                            inDatabase:(FMDatabase *)db {
    
    NSArray *memberArr = @[@"cmemberid",
                           @"cbooksid",
                           @"cjoindate",
                           @"istate",
                           @"cicon",
                           @"ccolor"];
    NSString *memberKey = [memberArr componentsJoinedByString:@", "];
    
    //更新bk_share_books_member表
    for (NSDictionary *dic in shareMember) {
        NSMutableDictionary *memberDic = [dic mutableCopy];
        
        NSMutableArray *memberValueArr = [NSMutableArray array];
        for (NSString *key in memberArr) {
            [memberValueArr addObject:[NSString stringWithFormat:@"'%@'",[memberDic objectForKey:key]]];
        }
        
        NSString *memberValue = [memberValueArr componentsJoinedByString:@", "];
        NSString *sqlStr = [NSString stringWithFormat:@"insert into bk_share_books_member (%@) values(%@)",memberKey,memberValue];
        if (![db executeUpdate:sqlStr]) {
            return NO;
        }
    }
    
    return YES;
}


/**
 删除账本后删除对应账本的备注
 
 @param bookId <#bookId description#>
 @param db <#db description#>
 @return <#return value description#>
 */
+ (BOOL)deleteMemberMarkWithBookId:(NSString *)bookId
                        inDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"delete from BK_SHARE_BOOKS_FRIENDS_MARK where cbooksid = ?",bookId]) {
        return NO;
    }
    return YES;
}


+ (BOOL)deleteSharebooksWithBooksid:(NSString *)bookId
                        inDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"delete from bk_share_books where cbooksid = ?",bookId]) {
        return NO;
    }
    
    return YES;
}

+ (void)saveShareBookMemberNickWithBookId:(NSString *)bookId
                        shareFriendsMarks:(NSArray <NSDictionary *>*)shareFriendsMarks
                                  success:(void(^)())success
                                  failure:(void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSArray *keyStrArr = @[@"cuserid",
                               @"cbooksid",
                               @"cfriendid",
                               @"cmark",
                               @"iversion",
                               @"cwritedate",
                               @"operatortype"];
        NSString *keyStr = [keyStrArr componentsJoinedByString:@", "];
        [shareFriendsMarks enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *friendValueArr = [NSMutableArray array];
            for (NSString *key in keyStrArr) {
                [friendValueArr addObject:[NSString stringWithFormat:@"'%@'",[dic objectForKey:key]]];
            }
            
            NSString *valueStr = [friendValueArr componentsJoinedByString:@", "];
            NSString *sqlStr = [NSString stringWithFormat:@"insert into BK_SHARE_BOOKS_FRIENDS_MARK (%@) values (%@)",keyStr,valueStr];
            if (![db executeUpdate:sqlStr]) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
                return ;
            }
            
        }];
        
        SSJDispatch_main_sync_safe(^{
            if (success) {
                success();
            }
        });
    }];
}

+ (BOOL)saveShareBookMemberNickWithBookId:(NSString *)bookId
                        shareFriendsMarks:(NSArray <NSDictionary *>*)shareFriendsMarks inDatabase:(SSJDatabase *)db {
    NSArray *keyStrArr = @[@"cuserid",
                           @"cbooksid",
                           @"cfriendid",
                           @"cmark",
                           @"iversion",
                           @"cwritedate",
                           @"operatortype"];
    NSString *keyStr = [keyStrArr componentsJoinedByString:@", "];
    for (NSDictionary *dic in shareFriendsMarks) {
        NSMutableArray *friendValueArr = [NSMutableArray array];
        for (NSString *key in keyStrArr) {
            [friendValueArr addObject:[NSString stringWithFormat:@"'%@'",[dic objectForKey:key]]];
        }
        
        NSString *valueStr = [friendValueArr componentsJoinedByString:@", "];
        NSString *sqlStr = [NSString stringWithFormat:@"insert into BK_SHARE_BOOKS_FRIENDS_MARK (%@) values (%@)",keyStr,valueStr];
        if (![db executeUpdate:sqlStr]) {
            return NO;
        }
    }
    return YES;
}

+ (NSDictionary *)fieldMapWithShareBookItem:(SSJShareBookItem *)item {
    [SSJShareBookItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return [SSJShareBookItem propertyMapping];
    }];
    return item.mj_keyValues;
}

@end
