//
//  SSJUserBillTypeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserBillTypeSyncTable.h"

@implementation SSJUserBillTypeSyncTable

+ (NSString *)tableName {
    return @"bk_user_bill_type";
}

+ (NSArray *)columns {
    return @[@"cbillid",
             @"cuserid",
             @"cbooksid",
             @"itype",
             @"cname",
             @"ccolor",
             @"cicoin",
             @"cwritedate",
             @"operatortype",
             @"iversion"];
}

+ (NSArray *)primaryKeys {
    return @[@"cbillid", @"cuserid", @"cbooksid"];
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        BOOL exist = [db boolForQuery:@"select count(*) from bk_user_bill_type where cbillid = ? and cuserid = ? and cbooksid = ?", recordInfo[@"cbillid"], recordInfo[@"cuserid"], recordInfo[@"cbooksid"] ? : recordInfo[@"cuserid"]];
        
        NSDictionary *param = @{@"cbillid":recordInfo[@"cbillid"],
                                @"cuserid":recordInfo[@"cuserid"],
                                @"cbooksid":recordInfo[@"cbooksid"],
                                @"itype":recordInfo[@"itype"],
                                @"cname":recordInfo[@"cname"],
                                @"ccolor":recordInfo[@"ccolor"],
                                @"cicoin":recordInfo[@"cicoin"],
                                @"cwritedate":recordInfo[@"cwritedate"],
                                @"operatortype":recordInfo[@"operatortype"],
                                @"iversion":recordInfo[@"iversion"]};
        if (exist) {
            if (![db executeUpdate:@"update bk_user_bill_type set itype = :itype, cname = :cname, ccolor = :ccolor, cicoin = :cicoin, cwritedate = :cwritedate, operatortype = :operatortype, iversion = :iversion where cbillid = :cbillid and cuserid = :cuserid and cbooksid = :cbooksid and cwritedate < :cwritedate" withParameterDictionary:param]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        } else {
            if (![db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, itype, cname, ccolor, cicoin, cwritedate, operatortype, iversion) values (:cbillid, :cuserid, :cbooksid, :itype, :cname, :ccolor, :cicoin, :cwritedate, :operatortype, :iversion)" withParameterDictionary:param]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        }
    }
    
    return YES;
}

@end
