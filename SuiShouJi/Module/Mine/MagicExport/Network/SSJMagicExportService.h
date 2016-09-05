//
//  SSJMagicExportService.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJMagicExportService : SSJBaseNetworkService

@property (nonatomic, copy, readonly) NSString *email;

- (void)exportWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate emailAddress:(NSString *)email;

@end
