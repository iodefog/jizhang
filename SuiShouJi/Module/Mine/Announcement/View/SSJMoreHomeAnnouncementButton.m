//
//  SSJMoreHomeAnnouncementButton.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMoreHomeAnnouncementButton.h"

@interface SSJMoreHomeAnnouncementButton()

@property(nonatomic, strong) UIButton *button;

@property(nonatomic, strong) UIView *dotView;

@end

@implementation SSJMoreHomeAnnouncementButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
        [self addSubview:self.dotView];
        self.hasNewAnnoucements = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
    self.dotView.rightTop = CGPointMake(self.width, 0);
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:self.bounds];
        [_button setImage:[[UIImage imageNamed:@"more_gonggao"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _button.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_button addTarget:self action:@selector(buttonCLickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UIView *)dotView
{
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        _dotView.size = CGSizeMake(5, 5);
        _dotView.layer.cornerRadius = 2.5;
        _dotView.hidden = YES;
        [_dotView clipsToBounds];
    }
    return _dotView;
}

- (void)buttonCLickAction:(id)sender {
    if (self.buttonClickBlock) {
        self.buttonClickBlock();
    }
}

- (void)setHasNewAnnoucements:(BOOL)hasNewAnnoucements {
    self.dotView.hidden = !hasNewAnnoucements;
}

- (void)updateAfterThemeChange {
    _button.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.dotView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
