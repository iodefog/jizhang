//
//  SSJReportFormCurveHeaderView.h
//  SuiShouJi
//
//  Created by old lang on 16/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJReportFormCurveHeaderViewItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJReportFormCurveHeaderView : UIView

/**
 切换时间维度触发的回调
 */
@property (nonatomic, copy, nullable) void (^changeTimePeriodHandle)(SSJReportFormCurveHeaderView *);

/**
 模型
 */
@property (nonatomic, strong) SSJReportFormCurveHeaderViewItem *item;

/**
 <#Description#>
 */
- (void)showLoadingOnSeparatorForm;

/**
 <#Description#>
 */
- (void)hideLoadingOnSeparatorForm;

/**
 <#Description#>
 */
- (void)showLoadingOnCurve;

/**
 <#Description#>
 */
- (void)hideLoadingOnCurve;

/**
 根据主题更新界面
 */
- (void)updateAppearanceAccordingToTheme;

@end

NS_ASSUME_NONNULL_END
