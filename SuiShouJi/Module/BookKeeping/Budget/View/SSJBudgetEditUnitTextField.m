//
//  SSJBudgetEditUnitTextField.m
//  SuiShouJi
//
//  Created by old lang on 16/3/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditUnitTextField.h"

@interface SSJBudgetEditUnitTextField ()

@property (nonatomic, strong) UILabel *unitLab;

@end

@implementation SSJBudgetEditUnitTextField

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.unitLab = [[UILabel alloc] init];
        self.unitLab.text = @"￥";
        [self.unitLab sizeToFit];
        [self addSubview:self.unitLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    switch (self.style) {
        case SSJBudgetEditUnitTextFieldStyleLeft:
            if (self.textAlignment == NSTextAlignmentLeft) {
                self.unitLab.left = 0;
                self.unitLab.centerY = self.height * 0.5;
            } else if (self.textAlignment == NSTextAlignmentCenter) {
                
            } else if (self.textAlignment == NSTextAlignmentRight) {
                
            }
            break;
            
        case SSJBudgetEditUnitTextFieldStyleRight:
            
            break;
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    
}

- (void)setStyle:(SSJBudgetEditUnitTextFieldStyle)style {
    if (_style != style) {
        _style = style;
    }
}

- (void)textFieldDidChange {
    
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    if (CGRectEqualToRect(self.bounds, bounds)) {
        switch (self.style) {
            case SSJBudgetEditUnitTextFieldStyleLeft:
                return CGRectMake(self.unitLab.width, 0, CGRectGetWidth(rect) - self.unitLab.width, CGRectGetHeight(rect));
                break;
                
            case SSJBudgetEditUnitTextFieldStyleRight:
                return CGRectMake(0, 0, CGRectGetWidth(rect) - self.unitLab.width, CGRectGetHeight(rect));
                break;
        }
    }
    
    return rect;
}

@end
