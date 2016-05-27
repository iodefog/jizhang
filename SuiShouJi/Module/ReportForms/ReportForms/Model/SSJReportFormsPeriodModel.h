//
//  SSJReportFormsPeriodModel.h
//  SuiShouJi
//
//  Created by old lang on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJReportFormsItem;

@interface SSJReportFormsPeriodModel : NSObject

@property (nonatomic, copy) NSString *date;

@property (nonatomic, strong) NSArray <SSJReportFormsItem *>*items;

+ (instancetype)modelWithDate:(NSString *)date items:(NSArray <SSJReportFormsItem *>*)items;

@end
