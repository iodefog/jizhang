//
//  SSJDatabaseQueue.m
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJDatabaseQueue.h"

@interface SSJDatabaseQueue ()

@property (nonatomic, strong) dispatch_queue_t dataBaseQueue;

@end

@implementation SSJDatabaseQueue

+ (instancetype)sharedInstance {
    static SSJDatabaseQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!queue) {
            queue = [[SSJDatabaseQueue alloc] initWithPath:SSJSQLitePath()];
        }
    });
    return queue;
}

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags {
    if (self = [super initWithPath:aPath flags:openFlags]) {
        self.dataBaseQueue = dispatch_queue_create("com.ShuiShouJi.SSJDatabaseQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)asyncInDatabase:(void (^)(FMDatabase *db))block {
    dispatch_async(self.dataBaseQueue, ^{
        [self inDatabase:block];
    });
}

- (void)asyncInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    dispatch_async(self.dataBaseQueue, ^{
        [self inTransaction:block];
    });
}

- (void)asyncInDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    dispatch_async(self.dataBaseQueue, ^{
        [self inDeferredTransaction:block];
    });
}

@end
