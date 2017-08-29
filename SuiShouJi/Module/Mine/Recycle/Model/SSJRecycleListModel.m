//
//  SSJRecycleListModel.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleListModel.h"

@implementation SSJRecycleListModel

- (instancetype)copyWithZone:(NSZone *)zone {
    SSJRecycleListModel *model = [[SSJRecycleListModel alloc] init];
    model.dateStr = self.dateStr;
    model.cellItems = [self.cellItems mutableCopy];
    return model;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}

@end
