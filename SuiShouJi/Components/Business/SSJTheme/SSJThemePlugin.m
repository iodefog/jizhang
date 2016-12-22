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
    if (SSJ_CURRENT_THEME.keyboardSeparatorColor.length) {
        [SSJCustomKeyboard sharedInstance].separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.keyboardSeparatorColor];
    } else {
        [SSJCustomKeyboard sharedInstance].separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    [SSJCustomKeyboard sharedInstance].backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
}

@end

@implementation SSJReportFormsCurveGraphView (SSJTheme)

- (void)updateAppearanceAccordToTheme {
    self.scaleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor];
    self.balloonTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                    NSForegroundColorAttributeName:[UIColor whiteColor],
                                    NSBackgroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor]};
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

@end


