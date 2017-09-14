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
#import "SSJLoanCompoundChargeModel.h"

@interface _SSJRecycleTransferModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *targetFundID;

@end

@implementation _SSJRecycleTransferModel
@end



@interface _SSJRecycleChargeModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *billID;

@property (nonatomic, copy) NSString *fundID;

@property (nonatomic, copy) NSString *sundryID;

@end

@implementation _SSJRecycleChargeModel
@end


@interface _SSJLoanModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic) SSJLoanType type;

@property (nonatomic, copy) NSString *fundID;

@property (nonatomic, copy) NSArray<SSJLoanCompoundChargeModel *> *chargeModels;

@end

@implementation _SSJLoanModel

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
    SSJFinancingParent parent = 0;
    
    NSMutableArray *subtitles = [NSMutableArray array];
    
    FMResultSet *rs = [db executeQuery:@"select cicoin, cacctname, ccolor, cparent from bk_fund_info where cfundid = ?", model.sundryID];
    while ([rs next]) {
        iconName = [rs stringForColumn:@"cicoin"];
        colorValue = [rs stringForColumn:@"ccolor"];
        fundName = [rs stringForColumn:@"cacctname"];
        parent = [rs intForColumn:@"cparent"];
    }
    [rs close];
    
    NSString *clientDate = [model.clientAddDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    // 查询非共享账本流水条数
    int personalBookChargeCount = [db intForQuery:@"select count(1) from bk_user_charge where ifunsid = ? and cwritedate = ? and ichargetype <> ? and operatortype = 2", model.sundryID, clientDate, @(SSJChargeIdTypeShareBooks)];
    
    // 查询为退出的共享账本流水条数
    int shareBookChargeCount = [db intForQuery:@"select count(1) from bk_user_charge where ifunsid = ? and cwritedate = ? and ichargetype = ? and operatortype = 2 and cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate = ?)", model.sundryID, clientDate, @(SSJChargeIdTypeShareBooks), model.userID, @(SSJShareBooksMemberStateNormal)];
    [subtitles addObject:[NSString stringWithFormat:@"%d条流水", personalBookChargeCount + shareBookChargeCount]];
    
    if ([db boolForQuery:@"select count(*) from bk_charge_period_config where ifunsid = ? and cwritedate = ? and operatortype = 2", model.sundryID, clientDate]) {
        [subtitles addObject:@"周期记账"];
    }
    
    if (parent == SSJFinancingParentPaidLeave
        || parent == SSJFinancingParentDebt) {
        if ([db boolForQuery:@"select count(ur.cremindid) from bk_loan as l, bk_user_remind as ur where l.cremindid = ur.cremindid and l.cthefundid = ? and ur.cwritedate = ? and ur.operatortype = 2", model.sundryID, clientDate]) {
            [subtitles addObject:@"提醒"];
        }
    } else if (parent == SSJFinancingParentCreditCard) {
        if ([db boolForQuery:@"select count(uc.cremindid) from bk_user_credit as uc, bk_user_remind as ur where uc.cfundid = ? and uc.cremindid = ur.cremindid and ur.cwritedate = ? and ur.operatortype = 2", model.sundryID, clientDate]) {
            [subtitles addObject:@"提醒"];
        }
    } else if (parent == SSJFinancingParentFixedEarnings) {
        if ([db boolForQuery:@"select count(fp.cremindid) from bk_fixed_finance_product as fp, bk_user_remind as ur where fp.cthisfundid = ? and fp.cremindid = ur.cremindid and ur.cwritedate = ? and ur.operatortype = 2", model.sundryID, clientDate]) {
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
    
    NSString *clientDate = [model.clientAddDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    int chargeCount = [db intForQuery:@"select count(1) from bk_user_charge where cbooksid = ? and cwritedate = ? and operatortype = 2 and length(ibillid) >= 4", model.sundryID, clientDate];
    [subtitles addObject:[NSString stringWithFormat:@"%d条流水", chargeCount]];
    [subtitles addObject:@"个人账本"];
    
    if ([db boolForQuery:@"select count(*) from bk_charge_period_config where cbooksid = ? and cwritedate = ? and operatortype = 2", model.sundryID, clientDate]) {
        [subtitles addObject:@"周期记账"];
    }
    
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
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(SSJDatabase *db, BOOL *rollback) {
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
                *rollback = YES;
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

#pragma mark - 恢复流水及其相关数据
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
    NSString *fundID = [db stringForQuery:@"select ifunsid from bk_user_charge where ichargeid = ?", recycleModel.sundryID];
    if (![self recoverFundWithID:fundID
                       writeDate:writeDateStr
                        database:db
                           error:error]) {
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

#pragma mark - 恢复资金账户及其相关数据
+ (void)recoverFundWithRecycleModel:(SSJRecycleModel *)recycleModel
                         inDatabase:(SSJDatabase *)db
                              error:(NSError **)error {
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *clientDate = [db stringForQuery:@"select clientadddate from bk_recycle where rid = ?", recycleModel.ID];
    
    // 恢复资金账户
    if (![self recoverFundWithID:recycleModel.sundryID
                       writeDate:writeDate
                        database:db
                           error:error]) {
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
    
    // 恢复普通流水／周期记账/平账流水
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
    if (![db executeUpdate:@"update bk_books_type set operatortype = 1, cwritedate = ?, iversion = ? where operatortype = 2 and cbooksid in (select cbooksid from bk_charge_period_config where cwritedate = ? and ifunsid = ? and operatortype = 2)", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.sundryID]) {
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

#pragma mark - 恢复账本及其相关数据
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
    
    // 查询此账本下需要恢复的流水及其资金账户
    // 注意：过滤特殊流水，例如：平账、转账等等；因为老版本对这些特殊流水也写入了booksid
    NSMutableSet *fundIDs = [NSMutableSet set];
    NSMutableArray *chargeIDs = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select ichargeid, ifunsid from bk_user_charge where cwritedate = ? and cbooksid = ? and operatortype = 2 and length(ibillid) >= 4", clientDate, recycleModel.sundryID];
    while ([rs next]) {
        [fundIDs addObject:[rs stringForColumn:@"ifunsid"]];
        [chargeIDs addObject:[rs stringForColumn:@"ichargeid"]];
    }
    [rs close];
    
    // 恢复此账本下流水依赖的资金账户
    for (NSString *fundID in fundIDs) {
        if (![self recoverFundWithID:fundID writeDate:writeDate database:db error:error]) {
            return;
        }
    }
    
    // 恢复此账本下流水
    for (NSString *chargeID in chargeIDs) {
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where ichargeid = ?", writeDate, @(SSJSyncVersion()), chargeID]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
    }
    
    // 查询此账本下需要恢复的周期记账及其资金账户
    [fundIDs removeAllObjects];
    [chargeIDs removeAllObjects];
    rs = [db executeQuery:@"select iconfigid, ifunsid from bk_charge_period_config where cwritedate = ? and cbooksid = ? and operatortype = 2", clientDate, recycleModel.sundryID];
    while ([rs next]) {
        [fundIDs addObject:[rs stringForColumn:@"ifunsid"]];
        [chargeIDs addObject:[rs stringForColumn:@"iconfigid"]];
    }
    [rs close];
    
    // 恢复周期记账依赖的资金账户
    for (NSString *fundID in fundIDs) {
        if (![self recoverFundWithID:fundID writeDate:writeDate database:db error:error]) {
            return;
        }
    }
    
    // 恢复周期记账
    for (NSString *chargeID in chargeIDs) {
        if (![db executeUpdate:@"update bk_charge_period_config set operatortype = 1, cwritedate = ?, iversion = ? where iconfigid = ?", writeDate, @(SSJSyncVersion()), chargeID]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
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
        if (![self recoverFundWithID:model.targetFundID writeDate:writeDate database:db error:error]) {
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
    
    // 查询需要恢复的周期转账流水
    NSArray *chargeModels = [self queryChargeModelsWithChargeType:SSJChargeIdTypeCyclicTransfer
                                                       clientDate:clientDate
                                                           fundID:fundID
                                                       inDatabase:db];
    
    NSTimeInterval timestamp = [NSDate date].timeIntervalSince1970;
    for (_SSJRecycleChargeModel *model in chargeModels) {
        // 恢复目标资金账户
        if (![self recoverTargetFundWithChargeModel:model
                                          writeDate:writeDate
                                         chargeType:SSJChargeIdTypeCyclicTransfer
                                         inDatabase:db
                                              error:error]) {
            return NO;
        }
        
        // 恢复周期转账流水；因为老版本（2.8.0之前）周期转账流水是通过writedate匹配的，所以要兼容老版本writedate不能完全相同
        NSString *increaseWriteDate = [[NSDate dateWithTimeIntervalSince1970:timestamp] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, iversion = ?, cwritedate = ? where cid = ? and ichargetype = ? and cwritedate = ? and operatortype = 2", @(SSJSyncVersion()), increaseWriteDate, model.sundryID, @(SSJChargeIdTypeCyclicTransfer), clientDate]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        timestamp += 0.001;
    }
    
    return YES;
}

#pragma mark - 恢复借贷
+ (BOOL)recoverLoanWithFundID:(NSString *)fundID
                   clientDate:(NSString *)clientDate
                    writeDate:(NSString *)writeDate
                   inDatabase:(SSJDatabase *)db
                        error:(NSError **)error {
    
    // 查询要恢复的借贷项目
    NSMutableArray *loanModels = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select loanid, cthefundid, itype from bk_loan where cwritedate = ? and operatortype = 2", clientDate];
    while ([rs next]) {
        _SSJLoanModel *model = [[_SSJLoanModel alloc] init];
        model.ID = [rs stringForColumn:@"loanid"];
        model.fundID = [rs stringForColumn:@"cthefundid"];
        model.type = [rs intForColumn:@"itype"];
        [loanModels addObject:model];
    }
    [rs close];
    
    // 查询每个借贷项目要恢复的流水
    for (_SSJLoanModel *loanModel in loanModels) {
        NSMutableArray *compoundModels = [NSMutableArray array];
        // 查询借贷账户流水
        rs = [db executeQuery:@"select ichargeid, ifunsid, ibillid from bk_user_charge where cid = ? and cwritedate = ? and ifunsid = ? and ichargetype = ? and operatortype = 2", loanModel.ID, clientDate, loanModel.fundID, @(SSJChargeIdTypeLoan)];
        while ([rs next]) {
            SSJLoanChargeModel *chargeModel = [[SSJLoanChargeModel alloc] init];
            chargeModel.chargeId = [rs stringForColumn:@"ichargeid"];
            chargeModel.fundId = [rs stringForColumn:@"ifunsid"];
            chargeModel.billId = [rs stringForColumn:@"ibillid"];
            
            SSJLoanCompoundChargeModel *compoundModel = [[SSJLoanCompoundChargeModel alloc] init];
            compoundModel.chargeModel = chargeModel;
            [compoundModels addObject:compoundModel];
        }
        [rs close];
        
        // 查询目标账户流水
        rs = [db executeQuery:@"select ichargeid, ifunsid, ibillid from bk_user_charge where cid = ? and cwritedate = ? and ifunsid <> ? and ichargetype = ? and operatortype = 2", loanModel.ID, clientDate, loanModel.fundID, @(SSJChargeIdTypeLoan)];
        while ([rs next]) {
            SSJLoanChargeModel *chargeModel = [[SSJLoanChargeModel alloc] init];
            chargeModel.chargeId = [rs stringForColumn:@"ichargeid"];
            chargeModel.fundId = [rs stringForColumn:@"ifunsid"];
            chargeModel.billId = [rs stringForColumn:@"ibillid"];
            
            // 根据chargeid匹配复合流水
            for (SSJLoanCompoundChargeModel *compoundModel in compoundModels) {
                NSString *preChargeID_1 = [[compoundModel.chargeModel.chargeId componentsSeparatedByString:@"_"] firstObject];
                NSString *preChargeID_2 = [[chargeModel.chargeId componentsSeparatedByString:@"_"] firstObject];
                if ([preChargeID_1 isEqualToString:preChargeID_2]) {
                    SSJSpecialBillId billID = [chargeModel.billId integerValue];
                    if (billID == SSJSpecialBillIdLoanInterestEarning
                        || billID == SSJSpecialBillIdLoanInterestExpense) {
                        compoundModel.interestChargeModel = chargeModel;
                    } else {
                        compoundModel.targetChargeModel = chargeModel;
                    }
                    break;
                }
            }
        }
        [rs close];
        
        loanModel.chargeModels = compoundModels;
    }
    
    NSTimeInterval timestamp = [NSDate date].timeIntervalSince1970;
    for (_SSJLoanModel *loanModel in loanModels) {
        // 恢复借贷项目
        if (![db executeUpdate:@"update bk_loan set operatortype = 1, cwritedate = ?, iversion = ? where loanid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), loanModel.ID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        for (SSJLoanCompoundChargeModel *compoundModel in loanModel.chargeModels) {
            NSString *updateDate = [[NSDate dateWithTimeIntervalSince1970:timestamp] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            // 恢复本账户流水
            if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, iversion = ?, operatortype = 1 where ichargeid = ?", updateDate, @(SSJSyncVersion()), compoundModel.chargeModel.chargeId]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
            
            // 恢复目标账户流水
            if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, iversion = ?, operatortype = 1 where ichargeid = ?", updateDate, @(SSJSyncVersion()), compoundModel.targetChargeModel.chargeId]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
            
            // 恢复目标账户
            if (![self recoverFundWithID:compoundModel.targetChargeModel.fundId
                               writeDate:writeDate
                                database:db
                                   error:error]) {
                return NO;
            }
            
            if (compoundModel.interestChargeModel) {
                // 恢复利息流水
                if (![db executeUpdate:@"update bk_user_charge set cwritedate = ?, iversion = ?, operatortype = 1 where ichargeid = ?", updateDate, @(SSJSyncVersion()), compoundModel.interestChargeModel.chargeId]) {
                    if (error) {
                        *error = [db lastError];
                    }
                    return NO;
                }
                
                // 恢复利息流水资金账户
                if (![self recoverFundWithID:compoundModel.interestChargeModel.fundId
                                   writeDate:writeDate
                                    database:db
                                       error:error]) {
                    return NO;
                }
            }
            
            timestamp += 0.001;
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
    // 查询此账户下已删除的信用卡流水
    NSArray *creditChargeModels = [self queryChargeModelsWithChargeType:SSJChargeIdTypeRepayment
                                                             clientDate:clientDate
                                                                 fundID:fundID
                                                             inDatabase:db];
    
    NSTimeInterval timestamp = [NSDate date].timeIntervalSince1970;
    for (_SSJRecycleChargeModel *model in creditChargeModels) {
        // 恢复还款项目
        if (![db executeUpdate:@"update bk_credit_repayment set operatortype = 1, cwritedate = ?, iversion = ? where crepaymentid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        SSJSpecialBillId billID = [model.billID integerValue];
        if (billID == SSJSpecialBillIdBalanceRollIn
            || billID == SSJSpecialBillIdBalanceRollOut) {
            // 恢复目标资金账户
            if (![self recoverTargetFundWithChargeModel:model
                                              writeDate:writeDate
                                             chargeType:SSJChargeIdTypeRepayment
                                             inDatabase:db
                                                  error:error]) {
                return NO;
            }
            
            // 恢复还款流水；因为老版本（2.8.0之前）还款流水是通过writedate匹配的，所以要兼容老版本writedate不能完全相同
            NSString *chargeWriteDate = [[NSDate dateWithTimeIntervalSince1970:timestamp] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where cid = ? and ichargetype = ? and cwritedate = ? and operatortype = 2", chargeWriteDate, @(SSJSyncVersion()), model.sundryID, @(SSJChargeIdTypeRepayment), clientDate]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
            
            timestamp += 0.001;
        } else if (billID == SSJSpecialBillIdCreditAgingPrincipal
                   || billID == SSJSpecialBillIdCreditAgingPoundage) {
            // 这两种流水不属于转入／转出类型 所以只要恢复流水
            if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where ichargeid = ?", writeDate, @(SSJSyncVersion()), model.ID]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
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
        // 恢复固收理财项目
        NSString *productID = [[model.sundryID componentsSeparatedByString:@"_"] firstObject];
        if (![db executeUpdate:@"update bk_fixed_finance_product set operatortype = 1, cwritedate = ?, iversion = ? where cproductid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), productID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        
        SSJSpecialBillId billID = [model.billID integerValue];
        if (billID == SSJSpecialBillIdFixedFinanceChangeEarning
            || billID == SSJSpecialBillIdFixedFinanceChangeExpenseg
            || billID == SSJSpecialBillIdFixedFinanceInterestEarning
            || billID == SSJSpecialBillIdFixedFinanceInterestExpense) {
            
            // 恢复目标资金账户
            if (![self recoverTargetFundWithChargeModel:model
                                              writeDate:writeDate
                                             chargeType:SSJChargeIdTypeFixedFinance
                                             inDatabase:db
                                                  error:error]) {
                return NO;
            }
        }
    }
    
    // 恢复流水
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where cwritedate = ? and ichargetype = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), clientDate, @(SSJChargeIdTypeFixedFinance)]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    return YES;
}

#pragma mark - 恢复资金账户
+ (BOOL)recoverFundWithID:(NSString *)fundID
                writeDate:(NSString *)writeDate
                 database:(FMDatabase *)db
                    error:(NSError **)error {
    
    SSJFinancingParent fundType = [db intForQuery:@"select cparent from bk_fund_info where cfundid = ?", fundID];
    if (fundType == SSJFinancingParentPaidLeave
        || fundType == SSJFinancingParentDebt
        || fundType == SSJFinancingParentFixedEarnings) {
        // 借贷和固收理财账户的删除状态是用idisplay表示的
        if (![db executeUpdate:@"update bk_fund_info set idisplay = 1, cwritedate = ?, iversion = ? where cfundid = ? and idisplay = 0", writeDate, @(SSJSyncVersion()), fundID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    } else if (fundType == SSJFinancingParentCreditCard) {
        if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), fundID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
        if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), fundID]) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    } else {
        if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), fundID]) {
            if (error) {
                *error = [db lastError];
            }
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
    FMResultSet *rs = [db executeQuery:@"select ichargeid, ibillid, cid from bk_user_charge where cwritedate = ? and ichargetype = ? and ifunsid = ? and operatortype = 2", clientDate, @(type), fundID];
    while ([rs next]) {
        _SSJRecycleChargeModel *model = [[_SSJRecycleChargeModel alloc] init];
        model.ID = [rs stringForColumn:@"ichargeid"];
        model.billID = [rs stringForColumn:@"ibillid"];
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
    
    if (chargeType != SSJChargeIdTypeLoan
        && chargeType != SSJChargeIdTypeRepayment
        && chargeType != SSJChargeIdTypeFixedFinance
        && chargeType != SSJChargeIdTypeCyclicTransfer) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"参数chargeType错误"}];
        }
        return NO;
    }
    
    NSString *targetFundID = nil;
    if (chargeType == SSJChargeIdTypeLoan
        || chargeType == SSJChargeIdTypeFixedFinance) {
        NSString *preChargeID = [[model.ID componentsSeparatedByString:@"_"] firstObject];
        targetFundID = [db stringForQuery:@"select ifunsid from bk_user_charge where ichargeid like ? || '_%' and ichargeid <> ? and ichargetype = ? and operatortype = 2", preChargeID, model.ID, @(chargeType)];
    } else {
        targetFundID = [db stringForQuery:@"select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2", model.sundryID, model.ID, @(chargeType)];
    }
    
    // 恢复目标资金账户
    if (targetFundID) {
        return [self recoverFundWithID:targetFundID writeDate:writeDate database:db error:error];
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

#pragma mark -
#pragma mark --------------------------------- 创建账本回收站数据 ---------------------------------

#pragma mark - 创建账本回收站数据
+ (BOOL)createRecycleRecordWithID:(NSString *)ID
                      recycleType:(SSJRecycleType)recycleType
                        writeDate:(NSString *)writeDate
                         database:(FMDatabase *)db
                            error:(NSError **)error {
    NSString *cycleID = [NSString stringWithFormat:@"%d_%@", (int)recycleType, ID];
    NSDictionary *params = @{@"rid":cycleID,
                             @"cuserid":SSJUSERID(),
                             @"cid":ID,
                             @"itype":@(recycleType),
                             @"clientadddate":writeDate,
                             @"cwritedate":writeDate,
                             @"operatortype":@(SSJRecycleStateNormal),
                             @"iversion":@(SSJSyncVersion())};
    
    if (![db executeUpdate:@"replace into bk_recycle (rid, cuserid, cid, itype, clientadddate, cwritedate, operatortype, iversion) values (:rid, :cuserid, :cid, :itype, :clientadddate, :cwritedate, :operatortype, :iversion)" withParameterDictionary:params]) {
        if (error) {
            *error = [db lastError];
        }
        return NO;
    }
    
    return YES;
}

@end
