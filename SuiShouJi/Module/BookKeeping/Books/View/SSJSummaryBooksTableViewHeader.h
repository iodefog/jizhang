//
//  SSJSummaryBooksTableViewHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJReportFormsScaleAxisView.h"
#import "SSJReportFormsCurveGraphView.h"
#import "SSJPercentCircleView.h"
#import "SSJSegmentedControl.h"
#import "SSJDatePeriod.h"

@interface SSJSummaryBooksTableViewHeader : UIView

@property (nonatomic, copy) void(^periodSelectBlock)();

@property (nonatomic, copy) void(^incomeOrExpentureSelectBlock)();

// 滚动日期选择
@property(nonatomic, strong) SSJReportFormsScaleAxisView *dateAxisView;

// 折线图
@property(nonatomic, strong) SSJReportFormsCurveGraphView *curveView;

//  月份收支图表
@property (nonatomic, strong) SSJPercentCircleView *chartView;

//  周期选择(日周月)
@property (nonatomic, strong) SSJSegmentedControl *periodSelectSegment;

//  支出或者收入选择(0为支出,1为收入)
@property (nonatomic, strong) SSJSegmentedControl *incomOrExpenseSelectSegment;

//  自定义时间
@property (nonatomic, strong) UIButton *customPeriodBtn;

//  编辑、删除自定义时间按钮
@property (nonatomic, strong) UIButton *addOrDeleteCustomPeriodBtn;

//  圆环中间顶部的总收入、总支出
@property (nonatomic, strong) UILabel *incomeAndPaymentTitleLab;

//  圆环中间顶部的总收入、总支出金额
@property (nonatomic, strong) UILabel *incomeAndPaymentMoneyLab;

@property (nonatomic) double totalIncome;

@property (nonatomic) double totalExpenture;

@property(nonatomic, strong) SSJDatePeriod *customPeriod;

@property(nonatomic) BOOL curveViewHasDataOrNot;

@property(nonatomic) BOOL chartViewHasDataOrNot;

@end
