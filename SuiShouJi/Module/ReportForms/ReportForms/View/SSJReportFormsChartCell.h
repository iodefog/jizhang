//
//  SSJReportFormsChartCell.h
//  SuiShouJi
//
//  Created by old lang on 16/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJReportFormsChartCellItem.h"

typedef NS_ENUM(NSUInteger, SSJReportFormsMemberAndCategoryOption) {
    SSJReportFormsMemberAndCategoryOptionCategory = 0,
    SSJReportFormsMemberAndCategoryOptionMember
};

@interface SSJReportFormsChartCell : SSJBaseTableViewCell

@property (nonatomic) SSJReportFormsMemberAndCategoryOption option;

@property (nonatomic, copy) void (^selectOptionHandle)(SSJReportFormsChartCell *);

@end
