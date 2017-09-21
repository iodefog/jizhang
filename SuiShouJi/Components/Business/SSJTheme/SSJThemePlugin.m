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

@implementation UITextField (SSJThemePlugin)

+ (void)load {
    SSJSwizzleSelector(self, NSSelectorFromString(@"dealloc"), @selector(ssj_delloc));
    SSJSwizzleSelector(self, @selector(initWithFrame:), @selector(ssj_initWithFrame:));
}

- (void)ssj_delloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self ssj_delloc];
}

- (instancetype)ssj_initWithFrame:(CGRect)frame {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ssj_updateClearButtonTintColor) name:SSJThemeDidChangeNotification object:self];
    [self ssj_updateClearButtonTintColor];
    return [self ssj_initWithFrame:frame];
}

- (void)ssj_updateClearButtonTintColor {
    [self ssj_setClearButtonTintColor:SSJ_MAIN_COLOR];
}

@end


