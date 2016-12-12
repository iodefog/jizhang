//
//  SSJReportFormsChartCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@class SSJPercentCircleViewItem;

@interface SSJReportFormsChartCellItem : SSJBaseItem

@property (nonatomic, copy) NSArray <SSJPercentCircleViewItem *>* chartItems;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *amount;

- (BOOL)isEqualToItem:(SSJReportFormsChartCellItem *)item;

@end
