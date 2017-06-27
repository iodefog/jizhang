//
//  SSJMobileNoField.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMobileNoField.h"

@interface SSJMobileNoField ()

@property (nonatomic, strong) UILabel *areaCodeLab;

@property (nonatomic, strong) id <NSObject> observer;

@end

@implementation SSJMobileNoField

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.mobileNoLength = 11;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.leftView = self.areaCodeLab;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.placeholder = NSLocalizedString(@"手机号", nil);
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (self.text.length > self.mobileNoLength) {
                self.text = [self.text substringToIndex:self.mobileNoLength];
            }
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.areaCodeLab sizeToFit];
    self.areaCodeLab.width = 44;
}

- (UILabel *)areaCodeLab {
    if (!_areaCodeLab) {
        _areaCodeLab = [[UILabel alloc] init];
        _areaCodeLab.text = @"+86";
        [_areaCodeLab ssj_setBorderStyle:SSJBorderStyleRight];
    }
    return _areaCodeLab;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.areaCodeLab.font = font;
}

@end

@implementation SSJMobileNoField (SSJTheme)

- (void)updateAppearanceAccordingToTheme {
    self.textColor = SSJ_MAIN_COLOR;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:SSJ_SECONDARY_COLOR}];
    [self ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [self.areaCodeLab ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
}

@end
