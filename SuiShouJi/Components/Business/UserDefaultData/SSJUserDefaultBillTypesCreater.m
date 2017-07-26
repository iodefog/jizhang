//
//  SSJUserDefaultBillTypesCreater.m
//  SuiShouJi
//
//  Created by old lang on 17/5/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserDefaultBillTypesCreater.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefaultBillTypesCreater

+ (void)createDefaultDataTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSString *booksId = userId;
    [self createDefaultDataTypeForUserId:userId booksId:booksId booksType:SSJBooksTypeDaily inDatabase:db error:error];
}

+ (void)createDefaultDataTypeForUserId:(NSString *)userId
                               booksId:(NSString *)booksId
                             booksType:(SSJBooksType)booksType
                            inDatabase:(FMDatabase *)db
                                 error:(NSError **)error {
    
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"];
    NSArray *billTypes = [self billTypesForBooksType:booksType];
    for (NSDictionary *record in billTypes) {
        NSMutableDictionary *tmpRecord = [record mutableCopy];
        tmpRecord[@"cuserid"] = userId;
        tmpRecord[@"cbooksid"] = booksId;
        tmpRecord[@"cwritedate"] = writeDate;
        tmpRecord[@"operatortype"] = @0;
        tmpRecord[@"iversion"] = @(SSJSyncVersion());
        
        BOOL existed = [db boolForQuery:@"select count(1) from bk_user_bill_type where cbillid = ? and cuserid = ? and cbooksid = ?", record[@"cbillid"], userId, booksId];
        if (!existed) {
            BOOL successful = [db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, itype, cname, ccolor, cicoin, iorder, cwritedate, operatortype, iversion) values (:cbillid, :cuserid, :cbooksid, :itype, :cname, :ccolor, :cicoin, :iorder, :cwritedate, :operatortype, :iversion)" withParameterDictionary:tmpRecord];
            if (!successful) {
                if (error) {
                    *error = [db lastError];
                }
                return;
            }
        }
    }
}

+ (NSArray<NSString *> *)billTypesForBooksType:(SSJBooksType)booksType {
    NSString *fileName = nil;
    switch (booksType) {
        case SSJBooksTypeDaily:
            
            break;
            
        case SSJBooksTypeBusiness:
            fileName = @"SSJBusinessBillTypes";
            break;
            
        case SSJBooksTypeMarriage:
            fileName = @"SSJMarriageBillTypes";
            break;
            
        case SSJBooksTypeDecoration:
            fileName = @"SSJDecorationBillTypes";
            break;
            
        case SSJBooksTypeTravel:
            fileName = @"SSJTravelBillTypes";
            break;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    return [NSArray arrayWithContentsOfFile:filePath];
}

+ (NSArray<NSString *> *)dailyIDs {
    return @[@"1000",
             @"1002",
             @"1003",
             @"1009",
             @"1004",
             @"1008",
             @"1022",
             @"1160",
             @"1033",
             @"2001",
             @"2005",
             @"2007",
             @"2002",
             @"2008",
             @"2006",
             @"2020",
             @"2004",
             @"2050"];
}

+ (NSArray<NSString *> *)babyIDs {
    return @[@"1130",
             @"1131",
             @"1181",
             @"1190",
             @"1171",
             @"1182",
             @"1047",
             @"1178",
             @"1129",
             @"2012",
             @"2051",
             @"2007",
             @"2050"];
}

+ (NSArray<NSString *> *)businessIDs {
    return @[@"1146",// 货品材料
             @"1159",// 人工支出
             @"1188",// 运营费用
             @"1062",// 办公费用
             @"1142",// 房租物业
             @"1071",// 税费
             @"1163",// 生意其它
             @"2029",// 销售额
             @"2052",// 提成
             @"2009",// 退款
             @"2050"// 其它收入
             ];
}

+ (NSArray<NSString *> *)marriageIDs {
    return @[@"1148",// 结婚物品
             @"1145",// 婚礼支出
             @"1140",// 度蜜月
             @"1147",// 结婚其它
             @"2012",// 礼金
             @"2005",// 收红包
             @"1163",// 赞助费
             @"2029"// 其它收入
             ];
}

@end
