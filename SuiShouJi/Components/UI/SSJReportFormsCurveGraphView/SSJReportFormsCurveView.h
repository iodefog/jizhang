//
//  SSJReportFormsCurveView.h
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReportFormsCurveView : UIView

/**
 支出曲线的顶点值
 */
@property (nonatomic, strong) NSArray *paymentValues;

/**
 收入曲线的顶点值
 */
@property (nonatomic, strong) NSArray *incomeValues;

/**
 最大值，根据此值决定收入、支出曲线的顶点显示位置
 */
@property (nonatomic) CGFloat maxValue;

/**
 曲线的布局范围
 */
@property (nonatomic) UIEdgeInsets contentInsets;

/**
 阴影的偏移量，默认CGPointZero
 */
@property (nonatomic) CGPoint shadowOffset;

/**
 是否显示曲线阴影，默认NO
 */
@property (nonatomic) BOOL showShadow;

/**
 是否填充曲线，默认NO
 */
@property (nonatomic) BOOL fillCurve;

/**
 支出曲线颜色
 */
@property (nonatomic, strong) UIColor *paymentCurveColor;

/**
 收入曲线颜色
 */
@property (nonatomic, strong) UIColor *incomeCurveColor;

/**
 支出曲线填充颜色
 */
@property (nonatomic, strong) UIColor *paymentFillColor;

/**
 收入曲线填充颜色
 */
@property (nonatomic, strong) UIColor *incomeFillColor;

/**
 获取支出曲线上X轴坐标对应的Y轴坐标，此方法目前没有实现

 @param axisX X轴坐标
 @return X轴对应的Y轴坐标
 */
- (CGFloat)paymentAxisYAtAxisX:(CGFloat)axisX;

/**
 获取收入曲线上X轴坐标对应的Y轴坐标，此方法目前没有实现

 @param axisX X轴坐标
 @return X轴对应的Y轴坐标
 */
- (CGFloat)incomeAxisYAtAxisX:(CGFloat)axisX;

@end
