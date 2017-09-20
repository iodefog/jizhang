//
//  SSJUserDefaultMembersCreater.m
//  SuiShouJi
//
//  Created by old lang on 17/3/20.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJUserDefaultMembersCreater.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefaultMembersCreater

+ (void)createDefaultDataTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSArray *datas = [self datasWithUserId:userId];
    for (NSDictionary *dataInfo in datas) {
        NSString *memberID = dataInfo[@"cmemberid"];
        NSString *memberName = dataInfo[@"cname"];
        BOOL existed = [db boolForQuery:@"select count(1) from bk_member where (cmemberid = ? and cuserid = ?) or (cname = ? and cuserid = ?)", memberID, userId, memberName, userId];
        if (!existed) {
            BOOL successfull = [db executeUpdate:@"insert into bk_member (cmemberid, cuserid, cname, ccolor, istate, iorder, cadddate, iversion, cwritedate, operatortype) values (:cmemberid, :cuserid, :cname, :ccolor, :istate, :iorder, :cadddate, :iversion, :cwritedate, :operatortype)" withParameterDictionary:dataInfo];
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
    return @[@{@"cmemberid":[NSString stringWithFormat:@"%@-0", userId],
               @"cuserid":userId,
               @"cname":@"我",
               @"ccolor":@"#fc7a60",
               @"istate":@1,
               @"iorder":@1,
               @"cadddate":writeDate,
               @"iversion":syncVersion,
               @"cwritedate":writeDate,
               @"operatortype":@0},
             
             @{@"cmemberid":[NSString stringWithFormat:@"%@-1", userId],
               @"cuserid":userId,
               @"cname":@"爱人",
               @"ccolor":@"#b1c23e",
               @"istate":@1,
               @"iorder":@2,
               @"cadddate":writeDate,
               @"iversion":syncVersion,
               @"cwritedate":writeDate,
               @"operatortype":@0},
             
             @{@"cmemberid":[NSString stringWithFormat:@"%@-2", userId],
               @"cuserid":userId,
               @"cname":@"小宝宝",
               @"ccolor":@"#25b4dd",
               @"istate":@1,
               @"iorder":@3,
               @"cadddate":writeDate,
               @"iversion":syncVersion,
               @"cwritedate":writeDate,
               @"operatortype":@0},
             
             @{@"cmemberid":[NSString stringWithFormat:@"%@-3", userId],
               @"cuserid":userId,
               @"cname":@"爸爸",
               @"ccolor":@"#5a98de",
               @"istate":@1,
               @"iorder":@4,
               @"cadddate":writeDate,
               @"iversion":syncVersion,
               @"cwritedate":writeDate,
               @"operatortype":@0},
             
             @{@"cmemberid":[NSString stringWithFormat:@"%@-4", userId],
               @"cuserid":userId,
               @"cname":@"妈妈",
               @"ccolor":@"#8bb84a",
               @"istate":@1,
               @"iorder":@5,
               @"cadddate":writeDate,
               @"iversion":syncVersion,
               @"cwritedate":writeDate,
               @"operatortype":@0}];
}

@end
