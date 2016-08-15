//
//  SSJReportFormsCurveView.h
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReportFormsCurveView : UIView

@property (nonatomic, strong) NSArray *paymentValues;

@property (nonatomic, strong) NSArray *incomeValues;

@property (nonatomic) CGFloat maxValue;

@property (nonatomic) UIEdgeInsets contentInsets;

// 获取支出曲线上X轴坐标对应的Y轴坐标，此方法目前没有实现
- (CGFloat)paymentAxisYAtAxisX:(CGFloat)axisX;

// 获取收入曲线上X轴坐标对应的Y轴坐标，此方法目前没有实现
- (CGFloat)incomeAxisYAtAxisX:(CGFloat)axisX;

@end
