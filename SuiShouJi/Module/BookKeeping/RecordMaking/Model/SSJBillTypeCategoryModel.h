//
//  SSJBillTypeCategoryModel.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJBillTypeModel;

@interface SSJBillTypeCategoryModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSArray<SSJBillTypeModel *> *items;

+ (instancetype)modelWithTitle:(NSString *)title items:(NSArray<SSJBillTypeModel *> *)items;

@end
