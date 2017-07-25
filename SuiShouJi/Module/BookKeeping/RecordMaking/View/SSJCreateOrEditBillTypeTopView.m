//
//  SSJCreateOrEditBillTypeTopView.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreateOrEditBillTypeTopView.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJCreateOrEditBillTypeTopViewColorControl
#pragma mark -
@interface _SSJCreateOrEditBillTypeTopViewColorControl : UIControl

@property (nonatomic, strong) UIView *colorView;

@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic) BOOL arrowDown;

@end

@implementation _SSJCreateOrEditBillTypeTopViewColorControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _arrowDown = YES;
        [self addSubview:self.colorView];
        [self addSubview:self.arrowView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)updateConstraints {
    [self.colorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(15);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(26, 13));
    }];
    [self.arrowView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.colorView.mas_right).offset(10);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(12, 7));
        make.right.mas_equalTo(self.mas_right).offset(-10);
    }];
    [super updateConstraints];
}

- (void)tapAction {
    [self setArrowDown:!_arrowDown animated:YES];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)setArrowDown:(BOOL)arrowDown {
    [self setArrowDown:arrowDown animated:NO];
}

- (void)setArrowDown:(BOOL)arrowDown animated:(BOOL)animated {
    _arrowDown = arrowDown;
    [UIView animateWithDuration:(animated ? 0.25 : 0) animations:^{
        self.arrowView.transform = CGAffineTransformMakeRotation(_arrowDown ? M_PI : 0);
    }];
}

- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [[UIView alloc] init];
        _colorView.clipsToBounds = YES;
        _colorView.layer.cornerRadius = 4;
    }
    return _colorView;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loan_arrow"]];
        _arrowView.transform = CGAffineTransformMakeRotation(_arrowDown ? M_PI : 0);
    }
    return _arrowView;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCreateOrEditBillTypeTopView
#pragma mark -
@interface SSJCreateOrEditBillTypeTopView () <UITextFieldDelegate>

@property (nonatomic, strong) _SSJCreateOrEditBillTypeTopViewColorControl *colorControl;

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UITextField *nameField;

@end

@implementation SSJCreateOrEditBillTypeTopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.colorControl];
        [self addSubview:self.iconView];
        [self addSubview:self.nameField];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self updateAppearanceAccordingToTheme];
    }
    return self;
}

- (void)updateConstraints {
    [self.colorControl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.mas_equalTo(0);
    }];
    [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.colorControl.mas_right).offset(20);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(self.iconView.image.size);
    }];
    [self.nameField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(20);
        make.right.mas_equalTo(self).offset(-10);
        make.top.and.bottom.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (void)setArrowDown:(BOOL)arrowDown {
    self.colorControl.arrowDown = arrowDown;
}

- (void)setArrowDown:(BOOL)arrowDown animated:(BOOL)animated {
    [self.colorControl setArrowDown:arrowDown animated:animated];
}

- (BOOL)arrowDown {
    return self.colorControl.arrowDown;
}

- (void)setBillTypeColor:(UIColor *)billTypeColor {
    _billTypeColor = billTypeColor;
    self.colorControl.colorView.backgroundColor = billTypeColor;
}

- (void)setBillTypeIcon:(UIImage *)billTypeIcon {
    _billTypeIcon = billTypeIcon;
    self.iconView.image = billTypeIcon;
    [self setNeedsUpdateConstraints];
}

- (void)setBillTypeName:(NSString *)billTypeName {
    _billTypeName = billTypeName;
    self.nameField.text = billTypeName;
}

- (void)updateAppearanceAccordingToTheme {
    [self ssj_setBorderColor:SSJ_BORDER_COLOR];
    self.backgroundColor = SSJ_MAIN_BACKGROUND_COLOR;
    [self.colorControl ssj_setBorderColor:SSJ_BORDER_COLOR];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    _billTypeName = nil;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameField resignFirstResponder];
    return YES;
}

#pragma mark - LazyInit
- (_SSJCreateOrEditBillTypeTopViewColorControl *)colorControl {
    if (!_colorControl) {
        _colorControl = [[_SSJCreateOrEditBillTypeTopViewColorControl alloc] init];
        [_colorControl ssj_setBorderStyle:SSJBorderStyleRight];
        [_colorControl ssj_setBorderInsets:UIEdgeInsetsMake(20, 0, 20, 0)];
        @weakify(self);
        [[_colorControl rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.tapColorAction) {
                self.tapColorAction(self);
            }
        }];
    }
    return _colorControl;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UITextField *)nameField {
    if (!_nameField) {
        _nameField = [[UITextField alloc] init];
        _nameField.textAlignment = NSTextAlignmentRight;
        _nameField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _nameField.returnKeyType = UIReturnKeyDone;
        _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameField.delegate = self;
    }
    return _nameField;
}

@end
