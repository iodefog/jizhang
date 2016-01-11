//
//  SSJDataSync.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDataSync : NSObject

+ (instancetype)shareInstance;

- (void)startSync;

@end
