//
//  SSJReportFormCurveHeaderViewItem.m
//  SuiShouJi
//
//  Created by old lang on 16/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCurveHeaderViewItem.h"
#import "SSJReportFormsCurveModel.h"

@implementation SSJReportFormCurveHeaderViewItem

- (BOOL)isEqualToItem:(SSJReportFormCurveHeaderViewItem *)item {
    return ([_curveModels isEqualToArray:item.curveModels]
            && _timeDimension == item.timeDimension
            && [_generalIncome isEqualToString:item.generalIncome]
            && [_generalPayment isEqualToString:item.generalPayment]
            && [_dailyCost isEqualToString:item.dailyCost]);
}

@end
