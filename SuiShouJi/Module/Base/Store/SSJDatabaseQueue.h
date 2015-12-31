//
//  SSJDatabaseQueue.h
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <FMDB/FMDB.h>

@interface SSJDatabaseQueue : FMDatabaseQueue

+ (instancetype)sharedInstance;

- (void)asyncInDatabase:(void (^)(FMDatabase *db))block;

- (void)asyncInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

- (void)asyncInDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

@end
