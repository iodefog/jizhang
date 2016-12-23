//
//  SSJReportFormCanYinChartCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/12/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

/**
 左侧分割线段样式

 - SSJReportFormCanYinChartCellStyleHeader: 只有点和下半部分线
 - SSJReportFormCanYinChartCellStyleBody: 点和上下半部分线
 - SSJReportFormCanYinChartCellStyleFooter: 只有点和上半部分线
 */
typedef NS_OPTIONS(NSUInteger, SSJReportFormCanYinChartCellSegmentStyle) {
    SSJReportFormCanYinChartCellSegmentStyleNone = 0,
    SSJReportFormCanYinChartCellSegmentStyleTop = 1 << 0,
    SSJReportFormCanYinChartCellSegmentStyleBottom = 1 << 1
};

@interface SSJReportFormCanYinChartCellItem : SSJBaseItem

@property (nonatomic) SSJReportFormCanYinChartCellSegmentStyle segmentStyle;

@property (nonatomic) NSString *leftText;

@property (nonatomic) NSString *centerText;

@property (nonatomic) NSString *rightText;

@end
