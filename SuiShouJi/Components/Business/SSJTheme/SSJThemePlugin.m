//
//  SSJThemePlugin.m
//  SuiShouJi
//
//  Created by old lang on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemePlugin.h"
#import "SSJCustomKeyboard.h"

@implementation SSJThemePlugin

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChangeNotification) name:SSJThemeDidChangeNotification object:nil];
    
    [SSJCustomKeyboard sharedInstance].titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [SSJCustomKeyboard sharedInstance].separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    [SSJCustomKeyboard sharedInstance].backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
}

+ (void)themeDidChangeNotification {
    [SSJCustomKeyboard sharedInstance].titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [SSJCustomKeyboard sharedInstance].separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    [SSJCustomKeyboard sharedInstance].backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
}

@end

@implementation SSJReportFormsCurveGraphView (SSJTheme)

- (void)updateAppearanceAccordToTheme {
    self.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.paymentCurveColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
    self.incomeCurveColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
    self.balloonColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

@end
