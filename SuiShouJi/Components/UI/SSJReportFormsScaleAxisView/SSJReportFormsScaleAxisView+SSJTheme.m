//
//  SSJReportFormsScaleAxisView+SSJTheme.m
//  SuiShouJi
//
//  Created by old lang on 17/5/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJReportFormsScaleAxisView+SSJTheme.h"

@implementation SSJReportFormsScaleAxisView (SSJTheme)

- (void)updateAppearance {
    self.fillColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.selectedScaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

@end
