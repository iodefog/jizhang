//
//  SSJMineHomeHeadLineService.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJMineHomeHeadLineService : SSJBaseNetworkService

@property (nonatomic, strong) NSArray *headLines;

- (void)requestHeadLines;

@end
