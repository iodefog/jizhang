//
//  SSJReportFormsChartCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsChartCellItem.h"

@implementation SSJReportFormsChartCellItem

- (BOOL)isEqualToItem:(SSJReportFormsChartCellItem *)item {
    if ([item isKindOfClass:[SSJReportFormsChartCellItem class]]) {
        return [self.chartItems isEqualToArray:item.chartItems] && [self.title isEqualToString:item.title] && [self.amount isEqualToString:item.amount];
    }
    return NO;
}

- (CGFloat)rowHeight {
    return 270;
}

@end
