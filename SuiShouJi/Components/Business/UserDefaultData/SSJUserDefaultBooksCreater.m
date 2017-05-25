//
//  SSJUserDefaultBooksCreater.m
//  SuiShouJi
//
//  Created by old lang on 17/3/20.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJUserDefaultBooksCreater.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefaultBooksCreater

+ (void)createDefaultDataTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSArray *datas = [self datasWithUserId:userId];
    for (NSDictionary *dataInfo in datas) {
        BOOL existed = [db boolForQuery:@"select count(1) from bk_books_type where cbooksid = ?", dataInfo[@"cbooksid"]];
        if (!existed) {
            BOOL successfull = [db executeUpdate:@"insert into bk_books_type (cbooksid, cuserid, iparenttype, cbooksname, cbookscolor, cicoin, iorder, iversion, cwritedate, operatortype) values (:cbooksid, :cuserid, :iparenttype, :cbooksname, :cbookscolor, :cicoin, :iorder, :iversion, :cwritedate, :operatortype)" withParameterDictionary:dataInfo];
            if (!successfull) {
                if (error) {
                    *error = [db lastError];
                }
                return;
            }
        }
    }
}

+ (NSArray<NSDictionary *> *)datasWithUserId:(NSString *)userId {
    NSNumber *syncVersion = @(SSJSyncVersion());
    NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    return @[@{@"cbooksid":userId,
               @"cuserid":userId,
               @"iparenttype":@(SSJBooksTypeDaily),
               @"cbooksname":@"日常账本",
               @"cbookscolor":@"#FC73AE,#FB91BC",
               @"cicoin":@"bk_moren",
               @"iorder":@1,
               @"iversion":syncVersion,
               @"cwritedate":writeDate,
               @"operatortype":@0}];
}

@end
