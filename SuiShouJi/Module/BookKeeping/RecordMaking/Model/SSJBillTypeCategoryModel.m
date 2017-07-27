//
//  SSJBillTypeCategoryModel.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBillTypeCategoryModel.h"

@implementation SSJBillTypeCategoryModel

+ (instancetype)modelWithTitle:(NSString *)title items:(NSArray<SSJBillTypeModel *> *)items {
    SSJBillTypeCategoryModel *model = [[SSJBillTypeCategoryModel alloc] init];
    model.title = title;
    model.items = items;
    return model;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}

@end
