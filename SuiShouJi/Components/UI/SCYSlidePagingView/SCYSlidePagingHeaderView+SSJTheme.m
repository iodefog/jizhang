//
//  SCYSlidePagingHeaderView+SSJTheme.m
//  SuiShouJi
//
//  Created by old lang on 17/2/10.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SCYSlidePagingHeaderView+SSJTheme.h"

@implementation SCYSlidePagingHeaderView (SSJTheme)

- (void)updateAppearanceAccordingToTheme {
    self.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}

@end
