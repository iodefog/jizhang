//
//  SSJSummaryBooksTableViewHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJReportFormsCurveGraphView.h"
#import "SSJPercentCircleView.h"
#import "SSJSegmentedControl.h"
#import "SSJDatePeriod.h"
#import "SSJReportFormsPeriodSelectionControl.h"

@interface SSJSummaryBooksTableViewHeader : UIView

@property (nonatomic, copy) void(^periodSelectBlock)();

@property (nonatomic, copy) void(^incomeOrExpentureSelectBlock)();

@property (nonatomic, strong) SSJReportFormsPeriodSelectionControl *periodControl;

// 折线图
@property(nonatomic, strong) SSJReportFormsCurveGraphView *curveView;

//  月份收支图表
@property (nonatomic, strong) SSJPercentCircleView *chartView;

//  支出或者收入选择(0为支出,1为收入)
@property (nonatomic, strong) SSJSegmentedControl *incomOrExpenseSelectSegment;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *amount;

@property (nonatomic) double totalIncome;

@property (nonatomic) double totalExpenture;

@property(nonatomic) BOOL curveViewHasDataOrNot;

@property(nonatomic) BOOL chartViewHasDataOrNot;

@property (nonatomic) SSJTimeDimension dimension;

- (void)updateAppearance;

@end
