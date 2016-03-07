//
//  SSJImageSynchronizeTask.m
//  SuiShouJi
//
//  Created by old lang on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJImageSynchronizeTask.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSyncHelper.h"

@implementation SSJImageSynchronizeTask

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    NSMutableArray *uploadImages = [NSMutableArray array];
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select a.cimgname from bk_img_sync as a, bk_user_charge as b where a.rid = b.ichargeid and a.operatortype <> 2 and a.isynctype = 0 and a.isyncstate = 0 and b.cuserid = ?", SSJCurrentSyncUserId()];
        if (!resultSet) {
            if (failure) {
                failure([db lastError]);
            }
            return;
        }
        
        while ([resultSet next]) {
            [uploadImages addObject:[resultSet stringForColumn:@"cimgname"]];
        }
    }];
    
    for (NSString *imageName in uploadImages) {
        
    }
    
}

@end
