//
//  SSJReportFormCurveHeaderView.h
//  SuiShouJi
//
//  Created by old lang on 16/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJReportFormCurveHeaderViewItem.h"

@interface SSJReportFormCurveHeaderView : UIView

@property (nonatomic, copy) void (^changeTimePeriodHandle)(SSJReportFormCurveHeaderView *);

@property (nonatomic, strong) SSJReportFormCurveHeaderViewItem *item;

- (void)updateAppearanceAccordingToTheme;

@end
