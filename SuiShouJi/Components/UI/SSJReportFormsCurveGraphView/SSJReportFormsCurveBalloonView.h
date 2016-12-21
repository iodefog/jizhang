//
//  SSJReportFormsCurveBalloonView.h
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReportFormsCurveBalloonView : UIView

/**
 <#Description#>
 */
@property (nonatomic, strong) NSString *title;

/**
 标题大小，默认systemFontOfSize:12
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 标题颜色，默认whiteColor
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 背景颜色，默认yellowColor
 */
@property (nonatomic, strong) UIColor *ballonColor;

@end
