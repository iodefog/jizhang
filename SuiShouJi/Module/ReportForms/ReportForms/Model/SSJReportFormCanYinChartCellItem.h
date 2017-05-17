//
//  SSJReportFormCanYinChartCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/12/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

/**
 左侧分割线段样式

 - SSJReportFormCanYinChartCellSegmentStyleNone: 只有点没有分线
 - SSJReportFormCanYinChartCellSegmentStyleTop: 点和上半部分线
 - SSJReportFormCanYinChartCellSegmentStyleBottom: 点和下半部分线
 */
typedef NS_OPTIONS(NSUInteger, SSJReportFormCanYinChartCellSegmentStyle) {
    SSJReportFormCanYinChartCellSegmentStyleNone = 0,
    SSJReportFormCanYinChartCellSegmentStyleTop = 1 << 0,
    SSJReportFormCanYinChartCellSegmentStyleBottom = 1 << 1
};

@interface SSJReportFormCanYinChartCellItem : SSJBaseCellItem

@property (nonatomic) SSJReportFormCanYinChartCellSegmentStyle segmentStyle;

@property (nonatomic, copy) NSString *leftText;

@property (nonatomic, copy) NSString *centerText;

@property (nonatomic, copy) NSString *rightText;

/**
 颜色
 */
@property (nonatomic, copy) NSString *circleColor;

@end
