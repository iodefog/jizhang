//
//  SSJUserDefaultBillTypesCreater.m
//  SuiShouJi
//
//  Created by old lang on 17/5/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserDefaultBillTypesCreater.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillTypeManager.h"

static NSString *const kIncomeBillIdKey = @"kIncomeBillIdKey";
static NSString *const kExpenseBillIdKey = @"kExpenseBillIdKey";

@implementation SSJUserDefaultBillTypesCreater

+ (void)createDefaultDataTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    // 查询个人账本id、类型
    FMResultSet *rs = [db executeQuery:@"select cbooksid, iparenttype from bk_books_type where cuserid = ? and operatortype <> 2", userId];
    if (!rs) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    NSMutableArray *booksTypeArr = [NSMutableArray array];
    while ([rs next]) {
        [booksTypeArr addObject:@{@"cbooksid":[rs stringForColumn:@"cbooksid"],
                                  @"iparenttype":[rs stringForColumn:@"iparenttype"]}];
    }
    [rs close];
    
    // 查询共享账本id、类型
    rs = [db executeQuery:@"select sb.cbooksid, sb.iparenttype from bk_share_books as sb, bk_share_books_member as sbm where sb.cbooksid = sbm.cbooksid and sbm.cmemberid = ? and sbm.istate = 0 and sb.operatortype <> 2", userId];
    if (!rs) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    while ([rs next]) {
        [booksTypeArr addObject:@{@"cbooksid":[rs stringForColumn:@"cbooksid"],
                                  @"iparenttype":[rs stringForColumn:@"iparenttype"]}];
    }
    [rs close];
    
    // 根据不同的账本类型创建不同的收支类别
    for (NSDictionary *booksTypeInfo in booksTypeArr) {
        NSString *booksId = booksTypeInfo[@"cbooksid"];
        SSJBooksType booksType = [booksTypeInfo[@"iparenttype"] integerValue];
        [self createDefaultDataTypeForUserId:userId booksId:booksId booksType:booksType inDatabase:db error:error];
    }
}

+ (void)createDefaultDataTypeForUserId:(NSString *)userId
                               booksId:(NSString *)booksId
                             booksType:(SSJBooksType)booksType
                            inDatabase:(FMDatabase *)db
                                 error:(NSError **)error {
    
    NSDictionary *billTypesInfo = [self billTypesForBooksType:booksType];
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [self createBillTypeWithIDs:billTypesInfo[kIncomeBillIdKey]
                         userId:userId
                        booksId:booksId
                      writeDate:writeDate
                       database:db
                          error:error];
    
    [self createBillTypeWithIDs:billTypesInfo[kExpenseBillIdKey]
                         userId:userId
                        booksId:booksId
                      writeDate:writeDate
                       database:db
                          error:error];
}

+ (void)createBillTypeWithIDs:(NSArray *)IDs userId:(NSString *)userId booksId:(NSString *)booksId writeDate:(NSString *)writeDate database:(FMDatabase *)db error:(NSError **)error {
    [IDs enumerateObjectsUsingBlock:^(NSString *billId, NSUInteger idx, BOOL * _Nonnull stop) {
        SSJBillTypeModel *model = SSJBillTypeModel(billId);
        NSDictionary *param = @{@"cbillid":model.ID,
                                @"cuserid":userId,
                                @"cbooksid":booksId,
                                @"cname":model.name,
                                @"itype":@(model.expended)};
        // 注意：重名并且同是收入／支出的类别也算相同类别
        FMResultSet *rs = [db executeQuery:@"select count(1) from bk_user_bill_type where (cbillid = :cbillid and cuserid = :cuserid and cbooksid = :cbooksid) or (cname = :cname and itype = :itype and cuserid = :cuserid and cbooksid = :cbooksid and operatortype <> 2)" withParameterDictionary:param];
        while (!rs) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        [rs next];
        BOOL existed = [rs boolForColumn:@"count(1)"];
        [rs close];
        
        if (!existed) {
            NSMutableDictionary *tmpRecord = [NSMutableDictionary dictionary];
            tmpRecord[@"cbillid"] = model.ID;
            tmpRecord[@"cuserid"] = userId;
            tmpRecord[@"cbooksid"] = booksId;
            tmpRecord[@"itype"] = @(model.expended);
            tmpRecord[@"cname"] = model.name;
            tmpRecord[@"ccolor"] = model.color;
            tmpRecord[@"cicoin"] = model.icon;
            tmpRecord[@"iorder"] = @(idx);
            tmpRecord[@"cwritedate"] = writeDate;
            tmpRecord[@"operatortype"] = @0;
            tmpRecord[@"iversion"] = @(SSJSyncVersion());
            
            BOOL successful = [db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, itype, cname, ccolor, cicoin, iorder, cwritedate, operatortype, iversion) values (:cbillid, :cuserid, :cbooksid, :itype, :cname, :ccolor, :cicoin, :iorder, :cwritedate, :operatortype, :iversion)" withParameterDictionary:tmpRecord];
            if (!successful) {
                if (error) {
                    *error = [db lastError];
                }
                return;
            }
        }
    }];
}

+ (NSDictionary<NSString *, NSArray *> *)billTypesForBooksType:(SSJBooksType)booksType {
    NSString *fileName = nil;
    switch (booksType) {
        case SSJBooksTypeDaily:
            return [self dailyIDs];
            break;
            
        case SSJBooksTypeBusiness:
            return [self businessIDs];
            break;
            
        case SSJBooksTypeMarriage:
            return [self marriageIDs];
            break;
            
        case SSJBooksTypeDecoration:
            return [self decorationIDs];
            break;
            
        case SSJBooksTypeTravel:
            return [self travelIDs];
            break;
            
        case SSJBooksTypeBaby:
            return [self babyIDs];
            break;
    }
}

+ (NSDictionary<NSString *, NSArray *> *)dailyIDs {
    NSArray *expenseIds = @[@"1000",// 餐饮
                            @"1002",// 交通
                            @"1003",// 购物
                            @"1009",// 居住
                            @"1004",// 娱乐
                            @"1008",// 医疗
                            @"1022",// 教育
                            @"1160",// 人情
                            @"1033" // 其它
                            ];
    
    NSArray *incomeIds = @[@"2001",// 工资
                           @"2005",// 收红包
                           @"2007",// 生活费
                           @"2002",// 奖金福利
                           @"2008",// 报销
                           @"2006",// 兼职
                           @"2020",// 借入款
                           @"2004",// 投资收益
                           @"2050" // 其它收入
                           ];
    return @{kIncomeBillIdKey:incomeIds,
             kExpenseBillIdKey:expenseIds};
}

+ (NSDictionary<NSString *, NSArray *> *)businessIDs {
    NSArray *incomeIds = @[@"2029",// 销售额
                           @"2052",// 提成
                           @"2009",// 退款
                           @"2050"// 其它收入
                           ];
    NSArray *expenseIds = @[@"1146",// 货品材料
                            @"1159",// 人工支出
                            @"1188",// 运营费用
                            @"1062",// 办公费用
                            @"1142",// 房租物业
                            @"1071",// 税费
                            @"1163" // 生意其它
                            ];
    return @{kIncomeBillIdKey:incomeIds,
             kExpenseBillIdKey:expenseIds};
}

+ (NSDictionary<NSString *, NSArray *> *)marriageIDs {
    NSArray *incomeIds = @[@"2012",// 礼金
                           @"2005",// 收红包
                           @"2039",// 赞助费
                           @"2050"// 其它收入
                           ];
    
    NSArray *expenseIds = @[@"1148",// 结婚物品
                            @"1145",// 婚礼支出
                            @"1140",// 度蜜月
                            @"1147"// 结婚其它
                            ];
    return @{kIncomeBillIdKey:incomeIds,
             kExpenseBillIdKey:expenseIds};
}

+ (NSDictionary<NSString *, NSArray *> *)decorationIDs {
    NSArray *incomeIds = @[@"2009",// 退款
                           @"2050"// 其它收入
                           ];
    
    NSArray *expenseIds = @[@"1161",// 软装
                           @"1185",// 硬装
                           @"1105",// 装修人工
                           @"1195" // 装修其它
                           ];
    return @{kIncomeBillIdKey:incomeIds,
             kExpenseBillIdKey:expenseIds};
}

+ (NSDictionary<NSString *, NSArray *> *)travelIDs {
    NSArray *incomeIds = @[@"2033",// 退税
                           @"2009",// 退款
                           @"2050"// 其它收入
                           ];
    
    NSArray *expenseIds = @[@"1000",// 餐饮
                            @"1002",// 交通
                            @"1193",// 住宿
                            @"1004",// 娱乐
                            @"1153",// 旅游购物
                            @"1149",// 景点门票
                            @"1114",// 参团费
                            @"1126",// 导游费
                            @"1152"// 旅行其它
                            ];
    
    return @{kIncomeBillIdKey:incomeIds,
             kExpenseBillIdKey:expenseIds};
}

+ (NSDictionary<NSString *, NSArray *> *)babyIDs {
    NSArray *incomeIds = @[@"2012",// 礼金
                           @"2051",// 压岁钱
                           @"2007",// 生活费
                           @"2050"// 其它收入
                           ];
    NSArray *expenseIds = @[@"1130",// 宝宝食物
                            @"1131",// 宝宝用品
                            @"1181",// 衣服
                            @"1190",// 早教
                            @"1171",// 玩乐
                            @"1182",// 医疗护理
                            @"1047",// 零花
                            @"1178",// 写真
                            @"1129"// 宝宝其它
                            ];
    return @{kIncomeBillIdKey:incomeIds,
             kExpenseBillIdKey:expenseIds};
}

@end
