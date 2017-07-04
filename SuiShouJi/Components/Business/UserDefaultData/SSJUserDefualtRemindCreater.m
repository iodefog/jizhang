//
//  SSJUserDefualtRemindCreater.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserDefualtRemindCreater.h"
#import "SSJDatabaseQueue.h"

@implementation SSJUserDefualtRemindCreater

+ (void)createDefaultDataTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSArray *datas = [self datasWithUserId:userId];
    for (NSDictionary *dataInfo in datas) {
        BOOL existed = [db boolForQuery:@"select count(1) from bk_user_remind where cremindid = ?", dataInfo[@"cremindid"]];
        if (!existed) {
            BOOL successfull = [db executeUpdate:@"insert into bk_user_remind (cremindid, cuserid, cremindname, cmemo, cstartdate, istate, cwritedate, iversion, operatortype, itype, icycle, iisend) values (:cremindid, :cuserid, :cremindname, :cmemo, :cstartdate, :istate, :cwritedate, :iversion, :operatortype, :itype, :icycle, :iisend)" withParameterDictionary:dataInfo];
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
    NSDate *startDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:20 minute:0 second:0];
    NSString *startDateStr = [startDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    return @[@{@"cremindid":[NSString stringWithFormat:@"%@-0", userId],
               @"cuserid":userId,
               @"cremindname":@"精打细算，有吃有穿，小主快来记账啦～",
               @"cmemo":@"",
               @"cstartdate":startDateStr,
               @"istate":@0,
               @"cwritedate":writeDate,
               @"iversion":syncVersion,
               @"operatortype":@0,
               @"itype":@1,
               @"icycle":@0,
               @"iisend":@0},
             
             @{@"cremindid":[NSString stringWithFormat:@"%@-1", userId],
               @"cuserid":userId,
               @"cremindname":@"来记账咯，money money go my home",
               @"cmemo":@"",
               @"cstartdate":startDateStr,
               @"istate":@0,
               @"cwritedate":writeDate,
               @"iversion":syncVersion,
               @"operatortype":@0,
               @"itype":@1,
               @"icycle":@0,
               @"iisend":@0},
             
             @{@"cremindid":[NSString stringWithFormat:@"%@-2", userId],
               @"cuserid":userId,
               @"cremindname":@"记的是账，理的是生活，继续坚持",
               @"cmemo":@"",
               @"cstartdate":startDateStr,
               @"istate":@0,
               @"cwritedate":writeDate,
               @"iversion":syncVersion,
               @"operatortype":@0,
               @"itype":@1,
               @"icycle":@0,
               @"iisend":@0}];
}


@end
