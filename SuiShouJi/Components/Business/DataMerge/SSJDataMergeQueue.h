//
//  SSJDataMergeQueue.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDataMergeQueue : NSObject

@property (nonatomic, strong) dispatch_queue_t dataMergeQueue;

+ (instancetype)sharedInstance;

@end
