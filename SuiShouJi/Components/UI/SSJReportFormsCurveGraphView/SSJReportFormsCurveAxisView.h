//
//  SSJReportFormsAxisView.h
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReportFormsCurveAxisView : UIView

/**
 刻度标题
 */
@property (nonatomic) NSArray *axisTitles;

/**
 第一个刻度和最后一个刻度距离边界的距离
 */
@property (nonatomic) CGFloat margin;

/**
 刻度标题颜色
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 刻度颜色
 */
@property (nonatomic, strong) UIColor *scaleColor;

@end
