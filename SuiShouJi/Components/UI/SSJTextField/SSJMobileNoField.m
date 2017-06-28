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
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.leftView = self.areaCodeLab;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.placeholder = NSLocalizedString(@"手机号", nil);
        [self ssj_setBorderWidth:2];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        
        __weak typeof(self) wself = self;
        self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (wself.text.length > wself.mobileNoLength) {
                wself.text = [wself.text substringToIndex:wself.mobileNoLength];
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
        [_areaCodeLab ssj_setBorderWidth:2];
        [_areaCodeLab ssj_setBorderStyle:SSJBorderStyleRight];
    }
    return _areaCodeLab;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.areaCodeLab.font = font;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    return [self newRectForOriginalRect:rect];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super editingRectForBounds:bounds];
    return [self newRectForOriginalRect:rect];
}

- (CGRect)newRectForOriginalRect:(CGRect)rect {
    return CGRectMake(rect.origin.x + 12, rect.origin.y, rect.size.width - 12, rect.size.height);
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
