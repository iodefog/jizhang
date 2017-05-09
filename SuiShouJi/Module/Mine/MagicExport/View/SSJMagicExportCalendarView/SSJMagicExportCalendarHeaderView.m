//
//  SSJMagicExportCalendarHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarHeaderView.h"

@implementation SSJMagicExportCalendarHeaderView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        
        self.backgroundView = [[UIView alloc] init];
        [self updateAppearance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearance) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.center = CGPointMake(self.contentView.width * 0.5, self.contentView.height * 0.5);
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.backgroundView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    } else {
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
}

@end
