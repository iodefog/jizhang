//
//  SSJReportFormCurveCell.h
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJReportFormCurveCellItem.h"

@interface SSJReportFormCurveCell : SSJBaseTableViewCell

@property (nonatomic, copy) void (^changeTimePeriodHandle)(SSJReportFormCurveCell *);

@property (nonatomic, strong) SSJReportFormCurveCellItem *cellItem;

@end
