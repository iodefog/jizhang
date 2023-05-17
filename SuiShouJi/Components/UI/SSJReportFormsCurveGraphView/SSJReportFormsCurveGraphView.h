//
//  SSJReportFormsCurveGraphView.h
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJReportFormsCurveGraphView;

@protocol SSJReportFormsCurveGraphViewDelegate <NSObject>

@required
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView;

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index;

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView paymentValueAtAxisXIndex:(NSUInteger)index;

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView incomeValueAtAxisXIndex:(NSUInteger)index;

@optional
- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index;

@end

@interface SSJReportFormsCurveGraphView : UIView

@property (nonatomic, weak) id<SSJReportFormsCurveGraphViewDelegate> delegate;

// default 7
@property (nonatomic) CGFloat displayAxisXCount;

// 刻度值、刻度线的颜色，默认grayColor
@property (nonatomic, strong) UIColor *scaleColor;

// 支出曲线、标题、圆点的颜色，默认greenColor
@property (nonatomic, strong) UIColor *paymentCurveColor;

// 收入曲线、标题、圆点的颜色，默认redColor
@property (nonatomic, strong) UIColor *incomeCurveColor;

// 结余背景颜色，默认orangeColor
@property (nonatomic, strong) UIColor *balloonColor;

/**
 重载数据，此方法触发SSJReportFormsCurveGraphViewDelegate的方法
 */
- (void)reloadData;

/**
 滚动到指定的X轴下标，使其位于中间

 @param index 指定的X轴下标
 @param animted 是否显示动画效果
 */
- (void)scrollToAxisXAtIndex:(NSUInteger)index animated:(BOOL)animted;

@end
