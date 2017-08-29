//
//  SSJRecycleHelper.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJRecycleModel.h"
#import "SSJRecycleListModel.h"
#import "SSJRecycleListCell.h"
#import "SSJBooksTypeItem.h"

@interface _SSJRecycleTransferModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *targetFundID;

@end

@implementation _SSJRecycleTransferModel
@end



@interface _SSJRecycleChargeModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *fundID;

@property (nonatomic, copy) NSString *sundryID;

@end

@implementation _SSJRecycleChargeModel
@end



@implementation SSJRecycleHelper

#pragma mark -
#pragma mark ---------------------------------------- 查询 ----------------------------------------

#pragma mark - 查询回收站数据
+ (void)queryRecycleListModelsWithSuccess:(void(^)(NSArray<SSJRecycleListModel *> *models))success
                                  failure:(nullable void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSMutableArray *models = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:@"select * from bk_recycle where cuserid = ? and operatortype = ? order by clientadddate desc", SSJUSERID(), @(SSJRecycleStateNormal)];
        while ([rs next]) {
            [models addObject:[SSJRecycleModel modelWithResultSet:rs]];
        }
        [rs close];
        
        NSMutableArray *resultModels = [NSMutableArray array];
        NSMutableArray *cellItems = [NSMutableArray array];
        NSDate *lastDate = nil;
        
        NSError *error = nil;
        for (SSJRecycleModel *model in models) {
            SSJRecycleListCellItem *cellItem = nil;
            switch (model.type) {
                case SSJRecycleTypeCharge:
                    cellItem = [self chargeItemWithRecycleModel:model inDatabase:db error:&error];
                    break;
                    
                case SSJRecycleTypeFund:
                    cellItem = [self fundItemWithRecycleModel:model inDatabase:db error:&error];
                    break;
                    
                case SSJRecycleTypeBooks:
                    cellItem = [self booksItemWithRecycleModel:model inDatabase:db error:&error];
                    break;
            }
            
            if (error) {
                SSJDispatchMainAsync(^{
                    if (failure) {
                        failure(error);
                    }
                });
                return;
            }
            
            if (lastDate && ![model.clientAddDate isSameDay:lastDate]) {
                SSJRecycleListModel *listModel = [[SSJRecycleListModel alloc] init];
                NSDate *now = [NSDate date];
                if ([lastDate isSameDay:now]) {
                    listModel.dateStr = @"今天";
                } else if ([lastDate isSameDay:[now dateBySubtractingDays:1]]) {
                    listModel.dateStr = @"昨天";
                } else {
                    listModel.dateStr = [lastDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm"];
                }
                listModel.cellItems = cellItems;
                [resultModels addObject:listModel];
                
                cellItems = [NSMutableArray array];
            }
            
            [cellItems addObject:cellItem];
            lastDate = model.clientAddDate;
        }
        
        if (cellItems.count) {
            SSJRecycleListModel *listModel = [[SSJRecycleListModel alloc] init];
            NSDate *now = [NSDate date];
            if ([lastDate isSameDay:now]) {
                listModel.dateStr = @"今天";
            } else if ([lastDate isSameDay:[now dateBySubtractingDays:1]]) {
                listModel.dateStr = @"昨天";
            } else {
                listModel.dateStr = [lastDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm"];
            }
            listModel.cellItems = cellItems;
            [resultModels addObject:listModel];
        }
        
        SSJDispatchMainAsync(^{
            if (success) {
                success(resultModels);
            }
        });
    }];
}

#pragma mark - 查询回收站流水
+ (SSJRecycleListCellItem *)chargeItemWithRecycleModel:(SSJRecycleModel *)model
                                            inDatabase:(SSJDatabase *)db
                                                 error:(NSError **)error {
    NSString *iconName = nil;
    NSString *colorValue = nil;
    NSString *billName = nil;
    NSString *money = nil;
    NSString *fundName = nil;
    NSString *booksID = nil;
    
    FMResultSet *rs = [db executeQuery:@"select uc.imoney, uc.cbooksid, ub.cicoin, ub.ccolor, ub.cname, fi.cacctname from bk_user_charge as uc, bk_user_bill_type as ub, bk_fund_info as fi where uc.ibillid = ub.cbillid and uc.cbooksid = ub.cbooksid and uc.cuserid = ub.cuserid and uc.ifunsid = fi.cfundid and uc.ichargeid = ? and uc.cuserid = ?", model.sundryID, model.userID];
    while ([rs next]) {
        iconName = [rs stringForColumn:@"cicoin"];
        colorValue = [rs stringForColumn:@"ccolor"];
        billName = [rs stringForColumn:@"cname"];
        money = [rs stringForColumn:@"imoney"];
        fundName = [rs stringForColumn:@"cacctname"];
        booksID = [rs stringForColumn:@"cbooksid"];
    }
    [rs close];
    
    NSString *booksName = nil;
    NSString *memberName = nil;
    
    BOOL isShareBooks = [db intForQuery:@"select count(1) from bk_share_books where cbooksid = ?", booksID];
    if (isShareBooks) {
        booksName = [db stringForQuery:@"select cbooksname from bk_share_books where cbooksid = ?", booksID];
        booksName = [NSString stringWithFormat:@"%@ (共享)", booksName];
        memberName = @"我";
    } else {
        booksName = [db stringForQuery:@"select cbooksname from bk_books_type where cbooksid = ? and cuserid = ?", booksID, model.userID];
        booksName = [NSString stringWithFormat:@"%@ (个人)", booksName];
        
        rs = [db executeQuery:@"select m.cname from bk_user_charge as uc, bk_member_charge as mc, bk_member as m where uc.ichargeid = mc.ichargeid and mc.cmemberid = m.cmemberid and uc.ichargeid = ?", model.sundryID];
        NSMutableArray *memberNames = [NSMutableArray array];
        while ([rs next]) {
            [memberNames addObject:[rs stringForColumn:@"cname"]];
        }
        [rs close];
        memberName = [memberNames componentsJoinedByString:@","];
    }
    
    SSJRecycleListCellItem *item = [SSJRecycleListCellItem itemWithRecycleID:model.ID
                                                                        icon:[UIImage imageNamed:iconName]
                                                               iconTintColor:[UIColor ssj_colorWithHex:colorValue]
                                                                       title:[NSString stringWithFormat:@"%@ %.2f", billName, [money doubleValue]]
                                                                   subtitles:@[booksName, fundName, memberName]
                                                                       state:SSJRecycleListCellStateNormal];
    
    return item;
}

#pragma mark - 查询回收站资金账户
+ (SSJRecycleListCellItem *)fundItemWithRecycleModel:(SSJRecycleModel *)model inDatabase:(SSJDatabase *)db error:(NSError **)error {
    
    NSString *iconName = nil;
    NSString *colorValue = nil;
    NSString *fundName = nil;
    int parent = 0;
    
    NSMutableArray *subtitles = [NSMutableArray array];
    
    FMResultSet *rs = [db executeQuery:@"select fi.cicoin, fi.cacctname, fi.ccolor, fi.cparent, count(uc.*) as chargecount from bk_fund_info as fi, bk_user_charge as uc where fi.cfundid = uc.ifunsid and uc.operatortype <> 2 and fi.cfundid = ?", model.sundryID];
    while ([rs next]) {
        iconName = [rs stringForColumn:@"cicoin"];
        colorValue = [rs stringForColumn:@"ccolor"];
        fundName = [rs stringForColumn:@"cacctname"];
        parent = [rs intForColumn:@"cparent"];
        [subtitles addObject:[NSString stringWithFormat:@"%d条流水", [rs intForColumn:@"chargecount"]]];
    }
    [rs close];
    
    if ([db boolForQuery:@"select count(*) from bk_charge_period_config where ifunsid = ?", model.sundryID]) {
        [subtitles addObject:@"周期记账"];
    }
    
    if (parent == SSJFinancingParentPaidLeave
        || parent == SSJFinancingParentDebt) {
        if ([db boolForQuery:@"select count(*) from bk_loan where cthefundid = ? and length(cremindid) > 0", model.sundryID]) {
            [subtitles addObject:@"提醒"];
        }
    } else if (parent == SSJFinancingParentCreditCard) {
        if ([db boolForQuery:@"select count(*) from bk_user_credit where cfundid = ? and length(cremindid) > 0", model.sundryID]) {
            [subtitles addObject:@"提醒"];
        }
    } else if (parent == SSJFinancingParentFixedEarnings) {
        if ([db boolForQuery:@"select count(*) from bk_fixed_finance_product where cthisfundid = ? and length(cremindid) > 0", model.sundryID]) {
            [subtitles addObject:@"提醒"];
        }
    }
    
    SSJRecycleListCellItem *item = [SSJRecycleListCellItem itemWithRecycleID:model.ID
                                                                        icon:[UIImage imageNamed:iconName]
                                                               iconTintColor:[UIColor ssj_colorWithHex:colorValue]
                                                                       title:fundName
                                                                   subtitles:subtitles
                                                                       state:SSJRecycleListCellStateNormal];
    return item;
}

#pragma mark - 查询回收站账本
+ (SSJRecycleListCellItem *)booksItemWithRecycleModel:(SSJRecycleModel *)model
                                           inDatabase:(SSJDatabase *)db
                                                error:(NSError **)error {
    NSString *iconName = nil;
    NSString *colorValue = nil;
    NSString *bookName = nil;
    NSMutableArray *subtitles = [NSMutableArray array];
    
    FMResultSet *rs = [db executeQuery:@"select cbooksname, cbookscolor, iparenttype from bk_books_type where cbooksid = ?", model.sundryID];
    while ([rs next]) {
        bookName = [rs stringForColumn:@"cbooksname"];
        iconName = SSJImageNameForBooksType([rs intForColumn:@"iparenttype"]);
        colorValue = [self singleColorValueWithGradientColor:[rs stringForColumn:@"cbookscolor"]];
    }
    [rs close];
    
    int chargeCount = [db intForQuery:@"select count(1) from bk_user_charge where cbooksid = ? and cwritedate = ? and operatortype = 2 and length(ibillid) >= 4", model.sundryID, [model.clientAddDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]];
    [subtitles addObject:[NSString stringWithFormat:@"%d条流水", chargeCount]];
    [subtitles addObject:@"个人账本"];
    
    
    
    SSJRecycleListCellItem *item = [SSJRecycleListCellItem itemWithRecycleID:model.ID
                                                                        icon:[UIImage imageNamed:iconName]
                                                               iconTintColor:[UIColor ssj_colorWithHex:colorValue]
                                                                       title:bookName
                                                                   subtitles:subtitles
                                                                       state:SSJRecycleListCellStateNormal];
    return item;
}

+ (NSString *)singleColorValueWithGradientColor:(NSString *)gradientColor {
    NSArray *colorValues = [gradientColor componentsSeparatedByString:@","];
    SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
    colorItem.startColor = [colorValues firstObject];
    colorItem.endColor = [colorValues lastObject];
    
    SSJBooksTypeItem *booksItem = [[SSJBooksTypeItem alloc] init];
    booksItem.booksColor = colorItem;
    
    return [booksItem getSingleColor];
}

#pragma mark -
#pragma mark ---------------------------------------- 恢复 ----------------------------------------

#pragma mark - 恢复回收站中指定的数据
+ (void)recoverRecycleIDs:(NSArray<NSString *> *)recycleIDs
                  success:(nullable void(^)())success
                  failure:(nullable void(^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        for (NSString *recycleID in recycleIDs) {
            SSJRecycleModel *recycleModel = nil;
            FMResultSet *rs = [db executeQuery:@"select * from bk_recycle where rid = ?", recycleID];
            while ([rs next]) {
                recycleModel = [SSJRecycleModel modelWithResultSet:rs];
            }
            [rs close];
            
            NSError *error = nil;
            switch (recycleModel.type) {
                case SSJRecycleTypeCharge:
                    [self recoverChargeWithRecycleModel:recycleModel inDatabase:db error:&error];
                    break;
                    
                case SSJRecycleTypeFund:
                    [self recoverFundWithRecycleModel:recycleModel inDatabase:db error:&error];
                    break;
                    
                case SSJRecycleTypeBooks:
                    [self recoverBookWithRecycleModel:recycleModel inDatabase:db error:&error];
                    break;
            }
            
            if (error) {
                SSJDispatchMainAsync(^{
                    if (failure) {
                        failure(error);
                    }
                });
                return;
            }
        }
        
        SSJDispatchMainAsync(^{
            if (success) {
                success();
            }
        });
    }];
}

#pragma mark - 恢复流水
+ (void)recoverChargeWithRecycleModel:(SSJRecycleModel *)recycleModel
                           inDatabase:(SSJDatabase *)db
                                error:(NSError **)error {
    
    if ([db intForQuery:@"select operatortype from bk_user_charge where ichargeid = ?", recycleModel.sundryID] != 2) {
        return;
    }
    
    // 如果此流水是共享账本流水，先检测是否共享退出了共享账本，退出了就不能恢复
    int state = [db intForQuery:@"select istate from bk_share_books_member where cmemberid = ? and cbooksid = (select cbooksid from bk_user_charge where ichargeid = ?)", recycleModel.userID, recycleModel.sundryID];
    if (state != SSJShareBooksMemberStateNormal) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"您已退出共享账本，无法恢复此记录"}];
        }
        return;
    }
    
    NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 如果流水依赖的资金账户也被删除了，先恢复资金账户
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where ichargeid = ?) and operatortype = 2", writeDateStr, @(SSJSyncVersion()), recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 如果流水依赖的个人账本也被删除了，先恢复账本
    if (![db executeUpdate:@"update bk_books_type set operatortype = 1, cwritedate = ?, iversion = ? where cbooksid = (select cbooksid from bk_user_charge where ichargeid = ?) and cuserid = ? and operatortype = 2", writeDateStr, @(SSJSyncVersion()), recycleModel.sundryID, recycleModel.userID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 将流水恢复
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where ichargeid = ?", writeDateStr, @(SSJSyncVersion()), recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复回收站记录
    if (![db executeUpdate:@"update bk_recycle set operatortype = ?, cwritedate = ?, iversion = ? where rid = ?", @(SSJRecycleStateRecovered), writeDateStr, @(SSJSyncVersion()), recycleModel.ID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
}

#pragma mark - 恢复资金账户
+ (void)recoverFundWithRecycleModel:(SSJRecycleModel *)recycleModel
                         inDatabase:(SSJDatabase *)db
                              error:(NSError **)error {
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *clientDate = [db stringForQuery:@"select clientadddate from bk_recycle where rid = ?", recycleModel.ID];
    
    // 恢复资金账户
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and cwritedate = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), recycleModel.sundryID, clientDate]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 如果此账户是信用卡账户，还要恢复信用卡表中的记录
    if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复回收站记录
    if (![db executeUpdate:@"update bk_recycle set operatortype = ?, cwritedate = ?, iversion = ? where rid = ?", @(SSJRecycleStateRecovered), writeDate, @(SSJSyncVersion()), recycleModel.ID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复此账户下流水（过滤特殊流水，例如：平账、转账等等）依赖的个人账本
    if (![db executeQuery:@"update bk_books_type set operatortype = 1, cwritedate = ?, iversion = ? where operatortype = 2 and cbooksid in (select cbooksid from bk_user_charge where ifunsid = ? and cwritedate = ? and operatortype = 2 and length(ibillid) >= 4)", writeDate, @(SSJSyncVersion()), recycleModel.sundryID, clientDate]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复普通流水／周期记账流水
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where ifunsid = ? and cwritedate = ? and (ichargetype = ? or ichargetype = ?) and operatortype = 2", writeDate, @(SSJSyncVersion()), recycleModel.sundryID, clientDate, @(SSJChargeIdTypeNormal), @(SSJChargeIdTypeCircleConfig)]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复未退出的共享账本流水
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where ifunsid = ? and cwritedate = ? and ichargetype = ? and operatortype = 2 and cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate = ?)", writeDate, @(SSJSyncVersion()), recycleModel.sundryID, clientDate, @(SSJChargeIdTypeShareBooks), recycleModel.userID, @(SSJShareBooksMemberStateNormal)]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复提醒
    if (![db executeUpdate:@"update bk_user_remind set operatortype = 1, cwritedate = ?, iversion = ? where cwritedate = ? and cuserid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.userID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复周期记账依赖的账本
    if (![db executeUpdate:@"udpate bk_books_type set operatortype = 1, cwritedate = ?, iversion = ? where operatortype = 2 and cbooksid in (select cbooksid from bk_charge_period_config where cwritedate = ? and ifunsid = ? and operatortype = 2)", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复周期记账
    if (![db executeUpdate:@"update bk_charge_period_config set operatortype = 1, cwritedate = ?, iversion = ? where cwritedate = ? and ifunsid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 周期转账
    if (![self recoverTransferWithFundID:recycleModel.sundryID
                              clientDate:clientDate
                               writeDate:writeDate
                              inDatabase:db
                                   error:error]) {
        return;
    }
    
    // 借贷
    if (![self recoverLoanWithFundID:recycleModel.sundryID
                          clientDate:clientDate
                           writeDate:writeDate
                          inDatabase:db
                               error:error]) {
        return;
    }
    
    // 信用卡
    if (![self recoverCreditWithFundID:recycleModel.sundryID
                            clientDate:clientDate
                             writeDate:writeDate
                            inDatabase:db
                                 error:error]) {
        return;
    }
    
    // 固收理财
    if (![self recoverFixFinanceWithFundID:recycleModel.sundryID
                                clientDate:clientDate
                                 writeDate:writeDate
                                inDatabase:db
                                     error:error]) {
        return;
    }
}

#pragma mark - 恢复账本
+ (void)recoverBookWithRecycleModel:(SSJRecycleModel *)recycleModel
                         inDatabase:(SSJDatabase *)db
                              error:(NSError **)error {
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *clientDate = [db stringForQuery:@"select clientadddate from bk_recycle where rid = ?", recycleModel.ID];
    
    // 恢复账本
    if (![db executeUpdate:@"update bk_books_type set operatortype = 1, cwritedate = ?, iversion = ? where cbooksid = ? and cwritedate = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), recycleModel.sundryID, clientDate]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复回收站记录
    if (![db executeUpdate:@"update bk_recycle set operatortype = ?, cwritedate = ?, iversion = ? where rid = ?", @(SSJRecycleStateRecovered), writeDate, @(SSJSyncVersion()), recycleModel.ID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复此账户下流水依赖的资金账户
    // 注意：过滤特殊流水，例如：平账、转账等等；因为老版本对这些特殊流水也写入了booksid
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where operatortype = 2 and cfundid in (select ifunsid from bk_user_charge where cwritedate = ? and cbooksid = ? and operatortype = 2 and length(ibillid) >= 4)", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复此账户下流水依赖的信用卡账户
    // 注意：过滤特殊流水，例如：平账、转账等等；因为老版本对这些特殊流水也写入了booksid
    if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where operatortype = 2 and cfundid in (select ifunsid from bk_user_charge where cwritedate = ? and cbooksid = ? and operatortype = 2 and length(ibillid) >= 4)", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复此账户下流水
    // 注意：过滤特殊流水，例如：平账、转账等等；因为老版本对这些特殊流水也写入了booksid
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where cwritedate = ? and cbooksid = ? and operatortype = 2 and length(ibillid) >= 4", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复周期记账依赖的资金账户
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where operatortype = 2 and cfundid in (select ifunsid from bk_charge_period_config where cwritedate = ? and cbooksid = ? and operatortype = 2)", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复周期记账
    if (![db executeUpdate:@"update bk_charge_period_config set operatortype = 1, cwritedate = ?, iversion = ? where cwritedate = ? and cbooksid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
}

#pragma mark - 恢复周期转账
+ (BOOL)recoverTransferWithFundID:(NSString *)fundID
                       clientDate:(NSString *)clientDate
                        writeDate:(NSString *)writeDate
                       inDatabase:(SSJDatabase *)db
                            error:(NSError **)error {
    // 查询已删除的周期转账配置
    NSMutableArray *transferModels = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select icycleid, ctransferinaccountid, ctransferoutaccountid from bk_transfer_cycle where cwritedate = ? and (ctransferinaccountid = ? or ctransferoutaccountid = ?) and operatortype = 2", clientDate, fundID, fundID];
    while ([rs next]) {
        _SSJRecycleTransferModel *model = [[_SSJRecycleTransferModel alloc] init];
        model.ID = [rs stringForColumn:@"icycleid"];
        NSString *transferInID = [rs stringForColumn:@"ctransferinaccountid"];
        NSString *transferOutID = [rs stringForColumn:@"ctransferoutaccountid"];
        model.targetFundID = [fundID isEqualToString:transferInID] ? transferOutID : transferInID;
        [transferModels addObject:model];
    }
    [rs close];
    
    for (_SSJRecycleTransferModel *model in transferModels) {
        // 恢复周期转账配置对应的目标资金账户
        if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.targetFundID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        // 如果目标账户是信用卡账户，还要恢复信用卡表中的记录
        if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.targetFundID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        // 恢复周期转账配置
        if (![db executeUpdate:@"update bk_transfer_cycle set operatortype = 1, cwritedate = ?, iversion = ? where icycleid = ?", writeDate, @(SSJSyncVersion()), model.ID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    
    // 查询此账户下已删除的周期转账流水
    NSArray *chargeModels = [self queryChargeModelsWithChargeType:SSJChargeIdTypeLoan
                                                       clientDate:clientDate
                                                           fundID:fundID
                                                       inDatabase:db];
    
    for (_SSJRecycleChargeModel *model in chargeModels) {
        // 恢复目标资金账户
        if (![self recoverTargetFundWithChargeModel:model
                                          writeDate:writeDate
                                         chargeType:SSJChargeIdTypeCyclicTransfer
                                         inDatabase:db
                                              error:error]) {
            return NO;
        }
        
        // 恢复所有和此账户关联的周期转账流水
        if (![self recoverChargesWithSundryID:model.sundryID
                                    writeDate:writeDate
                                   clientDate:clientDate
                                   chargeType:SSJChargeIdTypeCyclicTransfer
                                   inDatabase:db
                                        error:error]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 恢复借贷
+ (BOOL)recoverLoanWithFundID:(NSString *)fundID
                   clientDate:(NSString *)clientDate
                    writeDate:(NSString *)writeDate
                   inDatabase:(SSJDatabase *)db
                        error:(NSError **)error {
    // 查询此账户下已删除的借贷流水
    NSArray *loanChargeModels = [self queryChargeModelsWithChargeType:SSJChargeIdTypeLoan
                                                           clientDate:clientDate
                                                               fundID:fundID
                                                           inDatabase:db];
    for (_SSJRecycleChargeModel *model in loanChargeModels) {
        // 恢复目标资金账户
        if (![self recoverTargetFundWithChargeModel:model
                                          writeDate:writeDate
                                         chargeType:SSJChargeIdTypeLoan
                                         inDatabase:db
                                              error:error]) {
            return NO;
        }
        
        // 恢复借贷项目
        NSString *loanID = [[model.sundryID componentsSeparatedByString:@"_"] firstObject];
        if (![db executeUpdate:@"update bk_loan set operatortype = 1, cwritedate = ?, iversion = ? where loanid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), loanID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        // 恢复借贷流水
        if (![self recoverChargesWithSundryID:model.sundryID
                                    writeDate:writeDate
                                   clientDate:clientDate
                                   chargeType:SSJChargeIdTypeLoan
                                   inDatabase:db
                                        error:error]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 恢复信用卡
+ (BOOL)recoverCreditWithFundID:(NSString *)fundID
                     clientDate:(NSString *)clientDate
                      writeDate:(NSString *)writeDate
                     inDatabase:(SSJDatabase *)db
                          error:(NSError **)error {
    // 查询此账户下已删除的还款流水
    NSArray *creditChargeModels = [self queryChargeModelsWithChargeType:SSJChargeIdTypeRepayment
                                                             clientDate:clientDate
                                                                 fundID:fundID
                                                             inDatabase:db];
    for (_SSJRecycleChargeModel *model in creditChargeModels) {
        // 恢复目标资金账户
        if (![self recoverTargetFundWithChargeModel:model
                                          writeDate:writeDate
                                         chargeType:SSJChargeIdTypeRepayment
                                         inDatabase:db
                                              error:error]) {
            return NO;
        }
        
        // 恢复还款项目
        if (![db executeUpdate:@"update bk_credit_repayment set operatortype = 1, cwritedate = ?, iversion = ? where crepaymentid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        // 恢复还款流水
        if (![self recoverChargesWithSundryID:model.sundryID
                                    writeDate:writeDate
                                   clientDate:clientDate
                                   chargeType:SSJChargeIdTypeRepayment
                                   inDatabase:db
                                        error:error]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 恢复固收理财
+ (BOOL)recoverFixFinanceWithFundID:(NSString *)fundID
                         clientDate:(NSString *)clientDate
                          writeDate:(NSString *)writeDate
                         inDatabase:(SSJDatabase *)db
                              error:(NSError **)error {
    // 查询此账户下已删除的固收理财流水
    NSArray *fixedChargeModels = [self queryChargeModelsWithChargeType:SSJChargeIdTypeFixedFinance
                                                            clientDate:clientDate
                                                                fundID:fundID
                                                            inDatabase:db];
    
    for (_SSJRecycleChargeModel *model in fixedChargeModels) {
        // 恢复目标资金账户
        if (![self recoverTargetFundWithChargeModel:model
                                          writeDate:writeDate
                                         chargeType:SSJChargeIdTypeFixedFinance
                                         inDatabase:db
                                              error:error]) {
            return NO;
        }
        
        // 恢复固收理财项目
        NSString *productID = [[model.sundryID componentsSeparatedByString:@"_"] firstObject];
        if (![db executeUpdate:@"update bk_fixed_finance_product set operatortype = 1, cwritedate = ?, iversion = ? where crepaymentid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), productID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        // 恢复流水
        if (![self recoverChargesWithSundryID:model.sundryID
                                    writeDate:writeDate
                                   clientDate:clientDate
                                   chargeType:SSJChargeIdTypeFixedFinance
                                   inDatabase:db
                                        error:error]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 查询指定账本上已删除的指定类型的流水
+ (NSArray<_SSJRecycleChargeModel *> *)queryChargeModelsWithChargeType:(SSJChargeIdType)type
                                                            clientDate:(NSString *)clientDate
                                                                fundID:(NSString *)fundID
                                                            inDatabase:(SSJDatabase *)db {
    NSMutableArray *chargeModels = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select ichargeid, cid from bk_user_charge where cwritedate = ? and ichargetype = ? and ifunsid = ? and operatortype = 2", clientDate, @(type), fundID];
    while ([rs next]) {
        _SSJRecycleChargeModel *model = [[_SSJRecycleChargeModel alloc] init];
        model.ID = [rs stringForColumn:@"ichargeid"];
        model.sundryID = [rs stringForColumn:@"cid"];
        [chargeModels addObject:model];
    }
    [rs close];
    return chargeModels;
}

#pragma mark - 恢复转账／借贷／信用卡／固收理财流水的目标资金账户
+ (BOOL)recoverTargetFundWithChargeModel:(_SSJRecycleChargeModel *)model
                               writeDate:(NSString *)writeDate
                              chargeType:(SSJChargeIdType)chargeType
                              inDatabase:(SSJDatabase *)db
                                   error:(NSError **)error {
    // 恢复固收理财流水目标资金账户
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(chargeType)]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    // 如果目标账户是信用卡账户，还要恢复信用卡表中的记录
    if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(chargeType)]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    return YES;
}
#pragma mark - 恢复转账／借贷／信用卡／固收理财流水
+ (BOOL)recoverChargesWithSundryID:(NSString *)sundryID
                         writeDate:(NSString *)writeDate
                        clientDate:(NSString *)clientDate
                        chargeType:(SSJChargeIdType)chargeType
                        inDatabase:(SSJDatabase *)db
                             error:(NSError **)error {
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where cid = ? and ichargetype = ? and cwritedate = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), sundryID, @(chargeType), clientDate]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark ---------------------------------------- 清除 ----------------------------------------

#pragma mark - 清除回收站数据
+ (void)clearRecycleIDs:(NSArray<NSString *> *)recycleIDs
                success:(nullable void(^)())success
                failure:(nullable void(^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        for (NSString *recycleID in recycleIDs) {
            if (![db executeUpdate:@"update bk_recycle set operatortype = ?, cwritedate = ?, iversion = ? where rid = ?", @(SSJRecycleStateRemoved), writeDate, @(SSJSyncVersion()), recycleID]) {
                SSJDispatchMainAsync(^{
                    if (failure) {
                        failure([db lastError]);
                    }
                });
                return;
            }
        }
        
        SSJDispatchMainAsync(^{
            if (success) {
                success();
            }
        });
    }];
}

@end
