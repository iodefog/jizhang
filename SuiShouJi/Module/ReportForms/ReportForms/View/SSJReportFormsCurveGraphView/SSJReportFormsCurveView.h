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
 <#Description#>
 */
@property (nonatomic) UIEdgeInsets contentInsets;

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
