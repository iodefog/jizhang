//
//  SSJReportFormsChartCell.h
//  SuiShouJi
//
//  Created by old lang on 16/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJReportFormsChartCellItem.h"

/**
 成员、类别选项

 - SSJReportFormsMemberAndCategoryOptionCategory: 类别
 - SSJReportFormsMemberAndCategoryOptionMember: 成员
 */
typedef NS_ENUM(NSUInteger, SSJReportFormsMemberAndCategoryOption) {
    SSJReportFormsMemberAndCategoryOptionCategory = 0,
    SSJReportFormsMemberAndCategoryOptionMember
};

@interface SSJReportFormsChartCell : SSJBaseTableViewCell

/**
 当前选中的选项
 */
@property (nonatomic) SSJReportFormsMemberAndCategoryOption option;

/**
 切换成员、类别的回调
 */
@property (nonatomic, copy) void (^selectOptionHandle)(SSJReportFormsChartCell *);

@end
