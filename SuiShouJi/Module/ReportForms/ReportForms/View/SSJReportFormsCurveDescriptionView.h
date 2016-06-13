//
//  SSJReportFormsCurveDescriptionView.h
//  SuiShouJi
//
//  Created by old lang on 16/6/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJDatePeriod;

@interface SSJReportFormsCurveDescriptionView : UIView

@property (nonatomic, strong) SSJDatePeriod *period;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point;

- (void)dismiss;

@end
