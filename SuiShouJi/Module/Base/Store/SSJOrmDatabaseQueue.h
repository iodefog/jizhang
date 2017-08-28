//
//  SSJOrmDatabaseQueue.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WCDB/WCDB.h>

@interface SSJOrmDatabaseQueue : NSObject

@property (nonatomic, strong) dispatch_queue_t ormDatabaseQueue;

+ (instancetype)sharedInstance;

- (void)inDatabase:(void (^)(WCTDatabase *_db))blockblock;

- (void)asyncInDatabase:(void (^)(WCTDatabase *db))block;

@end
