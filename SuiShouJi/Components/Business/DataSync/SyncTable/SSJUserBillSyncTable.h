//
//  SSJUserBillSyncTable.h
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

// 用户收支类型

#import "SSJBaseSyncTable.h"

@interface SSJUserBillSyncTable : SSJBaseSyncTable

// 登录时候userbill的合并逻辑
+ (BOOL)mergeWhenLoginWithRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;

@end
