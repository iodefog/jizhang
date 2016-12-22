//
//  SSJReportFormsCurveDot.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReportFormsCurveDot : UIView

/**
 外圆半径，默认8
 */
@property (nonatomic, assign) CGFloat outerRadius;

/**
 内圆半径，默认4
 */
@property (nonatomic, assign) CGFloat innerRadius;

/**
 内圆颜色，默认blackColor
 */
@property (nonatomic, strong) UIColor *dotColor;

/**
 外圆透明度，默认0.5
 */
@property (nonatomic, assign) CGFloat outerColorAlpha;

@end
