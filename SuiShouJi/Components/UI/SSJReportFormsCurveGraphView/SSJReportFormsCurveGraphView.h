//
//  SSJReportFormsCurveGraphView.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJReportFormsCurveGraphView;

@protocol SSJReportFormsCurveGraphViewDataSource <NSObject>

@required
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView;

- (double)curveGraphView:(SSJReportFormsCurveGraphView *)graphView valueForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex;

@optional
- (NSUInteger)numberOfCurveInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView;

- (nullable NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index;

- (nullable UIColor *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView colorForCurveAtIndex:(NSUInteger)curveIndex;

- (nullable NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView suspensionTitleAtAxisXIndex:(NSUInteger)index;

- (BOOL)curveGraphView:(SSJReportFormsCurveGraphView *)graphView shouldShowValuePointForCurveAtIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex;

@end

@protocol SSJReportFormsCurveGraphViewDelegate <NSObject>

@optional
- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index;

- (nullable NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleForBallonAtAxisXIndex:(NSUInteger)index;

- (nullable NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleForBallonLabelAtCurveIndex:(NSUInteger)curveIndex axisXIndex:(NSUInteger)axisXIndex;

@end

@interface SSJReportFormsCurveGraphView : UIView

@property (nonatomic, weak) id <SSJReportFormsCurveGraphViewDataSource> dataSource;

@property (nonatomic, weak) id <SSJReportFormsCurveGraphViewDelegate> delegate;

/**
 X轴每个刻度之间的距离，默认50
 */
@property (nonatomic) CGFloat unitAxisXLength;

/**
 Y轴刻度数量，默认6
 */
@property (nonatomic) NSUInteger axisYCount;

/**
 Y轴刻度上的最大值
 */
@property (nonatomic, readonly) double maxValue;

/**
 X轴的刻度数量
 */
@property (nonatomic, readonly) NSUInteger axisXCount;

/**
 曲线数量
 */
@property (nonatomic, readonly) NSUInteger curveCount;

/**
 当前滚动至中间的X轴下标
 */
@property (nonatomic, readonly) NSUInteger currentIndex;

/**
 当前可见的X轴下标
 */
@property (nonatomic, strong, readonly) NSMutableArray<NSNumber *> *visibleIndexs;

/**
 曲线的Y轴坐标浮动范围，只有top、bottom的值有效，默认{46, 0, 56, 0}
 */
@property (nonatomic) UIEdgeInsets curveInsets;

/**
 刻度值、刻度线的颜色，默认lightGrayColor
 */
@property (nonatomic, strong) UIColor *scaleColor;

/**
 X轴、Y轴刻度标题字体大小，默认10号
 */
@property (nonatomic) CGFloat scaleTitleFontSize;

/**
 是否显示中间气球，默认NO
 */
@property (nonatomic, assign) BOOL showBalloon;

/**
 设置折线图中间气球标题样式，只有NSFontAttributeName、NSForegroundColorAttributeName、NSBackgroundColorAttributeName 3个key有效
 */
@property (nonatomic, strong) NSDictionary *balloonTitleAttributes;

/**
 是否在每个曲线上显示数值，默认NO
 */
@property (nonatomic, assign) BOOL showValuePoint;

/**
 数值颜色，默认blackColor
 */
@property (nonatomic, strong) UIColor *valueColor;

/**
 数值字体大小，默认12
 */
@property (nonatomic, assign) CGFloat valueFontSize;

/**
 是否显示曲线的阴影，默认YES
 */
@property (nonatomic, assign) BOOL showCurveShadow;

/**
 是否显示原点到第一个值、最后一个值到终点的曲线，默认NO
 */
@property (nonatomic, assign) BOOL showOriginAndTerminalCurve;

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

NS_ASSUME_NONNULL_END
