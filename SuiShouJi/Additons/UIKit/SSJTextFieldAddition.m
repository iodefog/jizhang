//
//  SSJTextFieldAddition.m
//  SuiShouJi
//
//  Created by old lang on 2017/9/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

// 两种方法改变clearbutton的颜色，目前采用第1种，如果审核不通过改用第2种
// 1.通过kvc获取按钮的私有属性，更改按钮颜色
// 2.自定义清除按钮，设置给rightview

#import "SSJTextFieldAddition.h"

static const void * kClearBtnKey = &kClearBtnKey;
static const void * kClearBtnTintColorKey = &kClearBtnTintColorKey;

@implementation UITextField (SSJClearButton)


//+ (void)load {
//    SSJSwizzleSelector(self, @selector(clearButtonRectForBounds:), @selector(ssj_clearButtonRectForBounds:));
//    SSJSwizzleSelector(self, @selector(setClearButtonMode:), @selector(ssj_setClearButtonMode:));
//}

- (UIColor *)ssj_clearButtonTintColor {
    return objc_getAssociatedObject(self, kClearBtnTintColorKey);
}

- (void)ssj_setClearButtonTintColor:(UIColor *)color {
    objc_setAssociatedObject(self, kClearBtnTintColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //    [self ssj_clearBtn].tintColor = color;
    
    UIButton *clearBtn = [self valueForKey:@"_clearButton"];
    
    UIImage *normal_img = [[clearBtn imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [clearBtn setImage:normal_img forState:UIControlStateNormal];
    [clearBtn setImage:normal_img forState:UIControlStateHighlighted];
    
    clearBtn.imageView.tintColor = color;
}

- (void)ssj_setClearButtonMode:(UITextFieldViewMode)clearButtonMode {
    [self ssj_setClearButtonMode:clearButtonMode];
    self.rightViewMode = clearButtonMode;
    if (clearButtonMode != UITextFieldViewModeNever) {
        self.rightView = [self ssj_clearBtn];
    }
}

- (CGRect)ssj_clearButtonRectForBounds:(CGRect)bounds {
    CGRect btnRect = [self ssj_clearButtonRectForBounds:bounds];
    [self ssj_clearBtn].frame = btnRect;
    return btnRect;
}

- (void)ssj_clearButtonAction {
    BOOL shouldClear = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        shouldClear = [self.delegate textFieldShouldClear:self];
    }
    
    if (shouldClear) {
        self.text = @"";
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self userInfo:nil];
    }
}

- (UIButton *)ssj_clearBtn {
    UIButton *btn = objc_getAssociatedObject(self, kClearBtnKey);
    if (!btn) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor blueColor].CGColor;
        [btn addTarget:self action:@selector(ssj_clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self, kClearBtnKey, btn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return btn;
}

@end
