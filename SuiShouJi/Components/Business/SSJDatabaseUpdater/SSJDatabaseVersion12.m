//
// Created by ricky on 2017/1/24.
// Copyright (c) 2017 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion12.h"
#import "SSJDatabaseQueue.h"

@implementation SSJDatabaseVersion12


+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {

    NSError *error = [self updateUserChargeTableWithDatabase:db];
    if (error) {
        return error;
    }

    return nil;
}

+ (NSError *)updateUserChargeTableWithDatabase:(FMDatabase *)db {

    // 添加记账时分字段
    if (![db executeUpdate:@"alter table bk_user_charge add cdetaildate text"]) {
        return [db lastError];
    }

    // 修改记账时分字段
    if (![db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(clientadddate,12,5) from bk_user_charge) from bk_user_charge where length(clientadddate) > 0"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(cwritedate,12,5) from bk_user_charge) from bk_user_charge where length(cdetaildate) = 0 or cdetaildate is null"]) {
        return [db lastError];
    }
    
    return nil;
}

@end
