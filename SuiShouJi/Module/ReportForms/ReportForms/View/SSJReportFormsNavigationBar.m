//
//  SSJReportFormsNavigationBar.m
//  SuiShouJi
//
//  Created by old lang on 17/5/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJReportFormsNavigationBar.h"
#import "SSJSegmentedControl.h"
#import "Masonry.h"

@interface SSJReportFormsNavigationBar ()

@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) SSJSegmentedControl *titleSegmentCtrl;

@end

@implementation SSJReportFormsNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.leftBtn];
        [self addSubview:self.titleSegmentCtrl];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.leftBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
    [self.titleSegmentCtrl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(170, 24));
    }];
    [super updateConstraints];
}

- (void)setOption:(SSJReportFormsNavigationBarOption)option {
    _option = option;
    switch (option) {
        case SSJReportFormsNavigationBarChart:
            self.titleSegmentCtrl.selectedSegmentIndex = 0;
            break;
            
        case SSJReportFormsNavigationBarCurve:
            self.titleSegmentCtrl.selectedSegmentIndex = 1;
            break;
    }
}

- (void)setBooksImage:(UIImage *)booksImage {
    UIImage *resizedImage = [booksImage ssj_scaleImageWithSize:CGSizeMake(21, 21)];
    UIImage *tmplateImage = [resizedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.leftBtn setImage:tmplateImage forState:UIControlStateNormal];
    
//    [self.leftBtn setImage:[booksImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)setBooksColor:(UIColor *)booksColor {
    self.leftBtn.tintColor = booksColor;
}

- (void)updateAppearance {
    self.titleSegmentCtrl.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.titleSegmentCtrl.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [self.titleSegmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
    [self.titleSegmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

- (void)updateOption {
    if (self.titleSegmentCtrl.selectedSegmentIndex != 0
        && self.titleSegmentCtrl.selectedSegmentIndex != 1) {
        return;
    }
    _option = self.titleSegmentCtrl.selectedSegmentIndex == 0 ? SSJReportFormsNavigationBarChart : SSJReportFormsNavigationBarCurve;
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        @weakify(self);
        [[_leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.clickBooksHandler) {
                self.clickBooksHandler(self);
            }
        }];
    }
    return _leftBtn;
}

- (SSJSegmentedControl *)titleSegmentCtrl {
    if (!_titleSegmentCtrl) {
        _titleSegmentCtrl = [[SSJSegmentedControl alloc] initWithItems:@[@"饼图",@"折线图"]];
        @weakify(self);
        [[_titleSegmentCtrl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(SSJSegmentedControl *segCtrl) {
            @strongify(self);
            [self updateOption];
            if (self.switchChartAndCurveHandler) {
                self.switchChartAndCurveHandler(self);
            }
        }];
    }
    return _titleSegmentCtrl;
}

@end
