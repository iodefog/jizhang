//
//  SSJDataMergeQueue.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDataMergeQueue.h"

static const void * kSSJDataMergeQueueSpecificKey = &kSSJDataMergeQueueSpecificKey;

@implementation SSJDataMergeQueue

+ (instancetype)sharedInstance {
    static SSJDataMergeQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!queue) {
            queue = [[SSJDataMergeQueue alloc] init];
        }
    });
    return queue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataMergeQueue = dispatch_queue_create("com.ShuiShouJi.SSJDataMergeQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(self.dataMergeQueue, kSSJDataMergeQueueSpecificKey, (__bridge void *)self, NULL);
    }
    return self;
}

@end
