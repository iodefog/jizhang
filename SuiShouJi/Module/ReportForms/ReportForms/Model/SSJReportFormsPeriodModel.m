//
//  SSJReportFormsPeriodModel.m
//  SuiShouJi
//
//  Created by old lang on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsPeriodModel.h"

@implementation SSJReportFormsPeriodModel

+ (instancetype)modelWithDate:(NSString *)date items:(NSArray <SSJReportFormsItem *>*)items {
    SSJReportFormsPeriodModel *model = [[SSJReportFormsPeriodModel alloc] init];
    model.date = date;
    model.items = items;
    return model;
}

@end
