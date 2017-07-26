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
             @"人情",
             @"1033",
             @"2001",
             @"2005",
             @"2007",
             @"2002",
             @"2008",
             @"2006",
             @"2020",
             @"2004",
             @"其它收入"];
}

+ (NSArray<NSString *> *)babyIDs {
    return @[@"宝宝食物",
             @"宝宝用品",
             @"衣服",
             @"早教",
             @"玩乐",
             @"医疗护理",
             @"1047",
             @"写真",
             @"宝宝其它",
             @"2012",
             @"压岁钱",
             @"2007",
             @"其它收入"];
}

+ (NSArray<NSString *> *)businessIDs {
    return @[@"货品材料",
             @"人工支出",
             @"运营费用",
             @"1062",
             @"1009",
             @"医疗护理",
             @"1047",
             @"写真",
             @"宝宝其它",
             @"2012",
             @"压岁钱",
             @"2007",
             @"其它收入"];
}

@end
