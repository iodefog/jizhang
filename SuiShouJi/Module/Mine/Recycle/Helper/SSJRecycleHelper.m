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

@implementation SSJRecycleHelper

+ (void)queryRecycleListModelsWithSuccess:(void(^)(NSArray<SSJRecycleListModel *> *models))success
                                  failure:(nullable void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSMutableArray *models = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:@"select * from bk_recycle where cuserid = ? and operatortype = ? order by clientadddate desc", SSJUSERID(), @(SSJRecycleStateNormal)];
        while ([rs next]) {
            SSJRecycleModel *model = [[SSJRecycleModel alloc] init];
            model.ID = [rs stringForColumn:@"rid"];
            model.userID = [rs stringForColumn:@"cuserid"];
            model.sundryID = [rs stringForColumn:@"cid"];
            model.type = [rs intForColumn:@"itype"];
            model.clientAddDate = [NSDate dateWithString:[rs stringForColumn:@"clientadddate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
            model.writeDate = [NSDate dateWithString:[rs stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
            model.state = [rs intForColumn:@"operatortype"];
            model.version = [rs longLongIntForColumn:@"iversion"];
            [models addObject:model];
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
        
        SSJDispatchMainAsync(^{
            if (success) {
                success(resultModels);
            }
        });
    }];
}

+ (SSJRecycleListCellItem *)chargeItemWithRecycleModel:(SSJRecycleModel *)model inDatabase:(SSJDatabase *)db error:(NSError **)error {
    FMResultSet *rs = [db executeQuery:@"select uc.imoney, uc.cbooksid, ub.cicoin, ub.ccolor, ub.cname, fi.cacctname from bk_user_charge as uc, bk_user_bill_type as ub, bk_fund_info as fi where uc.ibillid = ub.cbillid and uc.cbooksid = ub.cbooksid and uc.cuserid = ub.cuserid and uc.ifunsid = fi.cfundid and uc.ichargeid = ? and uc.cuserid = ?", model.sundryID, model.userID];
    
    NSString *iconName = nil;
    NSString *colorValue = nil;
    NSString *billName = nil;
    NSString *money = nil;
    NSString *fundName = nil;
    NSString *booksID = nil;
    
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
    
    BOOL isShareBooks = [db executeQuery:@"select count(1) from bk_share_books where cbooksid = ?", booksID];
    if (isShareBooks) {
        booksName = [db stringForQuery:@"select cbooksname from bk_share_books where cbooksid = ?", booksID];
        booksName = [NSString stringWithFormat:@"%@(共享)", booksName];
        memberName = @"我";
    } else {
        booksName = [db stringForQuery:@"select cbooksname from bk_books_type where cbooksid = ? and cuserid = ?", booksID, model.userID];
        booksName = [NSString stringWithFormat:@"%@(个人)", booksName];
        
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
        if ([db boolForQuery:@"select count(*) from bk_user_credit where cthisfundid = ? and length(cremindid) > 0", model.sundryID]) {
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

+ (SSJRecycleListCellItem *)booksItemWithRecycleModel:(SSJRecycleModel *)model inDatabase:(SSJDatabase *)db error:(NSError **)error {
    
    NSString *iconName = nil;
    NSString *colorValue = nil;
    NSString *bookName = nil;
    NSMutableArray *subtitles = [NSMutableArray array];
    
    if ([db boolForQuery:@"select count(*) from bk_share_books where cbooksid = ?", model.sundryID]) {
        FMResultSet *rs = [db executeQuery:@"select sb.cbooksname, sb.cbookscolor, sb.iparenttype, count(uc.*) as chargecount from bk_share_books as sb, bk_user_charge as uc where sb.cbooksid = uc.cbooksid and uc.operatortype <> 2 and sb.cbooksid = ?", model.sundryID];
        while ([rs next]) {
            iconName = SSJImageNameForBooksType([rs intForColumn:@"iparenttype"]);
            colorValue = [rs stringForColumn:@"cbookscolor"];
            bookName = [rs stringForColumn:@"cbooksname"];
            [subtitles addObject:[NSString stringWithFormat:@"%d条流水", [rs intForColumn:@"chargecount"]]];
        }
        [subtitles addObject:@"共享账本"];
        [rs close];
    } else {
        FMResultSet *rs = [db executeQuery:@"select bt.cbooksname, bt.cbookscolor, bt.iparenttype, count(uc.*) as chargecount from bk_books_type as bt, bk_user_charge as uc where bt.cbooksid = uc.cbooksid and uc.operatortype <> 2 and bt.cbooksid = ?", model.sundryID];
        while ([rs next]) {
            iconName = SSJImageNameForBooksType([rs intForColumn:@"iparenttype"]);
            colorValue = [rs stringForColumn:@"cbookscolor"];
            bookName = [rs stringForColumn:@"cbooksname"];
            [subtitles addObject:[NSString stringWithFormat:@"%d条流水", [rs intForColumn:@"chargecount"]]];
        }
        [subtitles addObject:@"个人账本"];
        [rs close];
    }
    
    SSJRecycleListCellItem *item = [SSJRecycleListCellItem itemWithRecycleID:model.ID
                                                                        icon:[UIImage imageNamed:iconName]
                                                               iconTintColor:[UIColor ssj_colorWithHex:colorValue]
                                                                       title:bookName
                                                                   subtitles:subtitles
                                                                       state:SSJRecycleListCellStateNormal];
    return item;
}

@end
