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

    if (![db executeUpdate:@"alter table bk_user_charge add cdetaildate text"]) {
        return [db lastError];
    }

    if (![db executeUpdate:@"update bk_user_charge set "]) {
        
    }
    
    return nil;
}

@end
