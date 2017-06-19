//
//  SSJDatabase.h
//  SuiShouJi
//
//  Created by old lang on 17/4/21.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "FMDB.h"

@interface SSJDatabase : FMDatabase

@property (nonatomic, copy, readonly) NSString *sql;

@property (nonatomic) BOOL shouldHandleError;

@end
