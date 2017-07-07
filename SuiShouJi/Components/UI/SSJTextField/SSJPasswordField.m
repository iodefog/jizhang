//
//  SSJPasswordField.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/29.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPasswordField.h"

@interface SSJPasswordField ()

@property (nonatomic, strong) UIButton *toggle;

@property (nonatomic, strong) id <NSObject> observer;

@end

@implementation SSJPasswordField

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.maxLength = SSJMaxPasswordLength;
        self.textColor = [UIColor ssj_colorWithHex:@"333333"];
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.placeholder = [NSString stringWithFormat:@"请设置%d位以上密码", (int)SSJMinPasswordLength];
        self.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        
        self.secureTextEntry = YES;
        self.keyboardType = UIKeyboardTypeASCIICapable;
        
        self.rightView = self.toggle;
        self.rightViewMode = UITextFieldViewModeAlways;
        
        [self ssj_setBorderColor:[UIColor lightGrayColor]];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self ssj_setBorderWidth:2];
        
        __weak typeof(self) wself = self;
        self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (wself.text.length > wself.maxLength) {
                wself.text = [wself.text substringToIndex:wself.maxLength];
            }
        }];
    }
    return self;
}

- (UIButton *)toggle {
    if (!_toggle) {
        _toggle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 50)];
        [_toggle setImage:[UIImage imageNamed:@"founds_xianshi"] forState:UIControlStateSelected];
        [_toggle setImage:[UIImage imageNamed:@"founds_yincang"] forState:UIControlStateNormal];
        [[_toggle rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
            self.secureTextEntry = button.selected;
            button.selected = !button.selected;
        }];
    }
    return _toggle;
}

@end

@implementation SSJPasswordField (SSJTheme)

- (void)updateAppearanceAccordingToTheme {
    [self updateAppearanceWithThemeModel:[SSJThemeSetting currentThemeModel]];
}

- (void)updateAppearanceAccordingToDefaultTheme {
    [self updateAppearanceWithThemeModel:[SSJThemeSetting defaultThemeModel]];
}

- (void)updateAppearanceWithThemeModel:(SSJThemeModel *)model {
    self.textColor = [UIColor ssj_colorWithHex:model.mainColor];
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:model.secondaryColor]}];
    [self ssj_setBorderColor:[UIColor ssj_colorWithHex:model.borderColor]];
}

@end
