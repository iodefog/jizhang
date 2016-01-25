//
//  SSJBaselineTextField.m
//  SuiShouJi
//
//  Created by old lang on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaselineTextField.h"

@interface SSJBaselineTextField ()

@property (nonatomic) CGFloat contentHeight;

@end

@implementation SSJBaselineTextField

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame contentHeight:(CGFloat)height {
    if (self = [super initWithFrame:frame]) {
        self.contentHeight = height;
        self.contentHeight = 40;
//        self.backgroundColor = [UIColor yellowColor];
        
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self ssj_setBorderWidth:2.0];
        [self ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditing) name:UITextFieldTextDidBeginEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing) name:UITextFieldTextDidEndEditingNotification object:self];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    if (CGRectEqualToRect(self.bounds, bounds)) {
        return CGRectMake(rect.origin.x, bounds.size.height - self.contentHeight, rect.size.width, self.contentHeight);
    } else {
        return rect;
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super editingRectForBounds:bounds];
    return CGRectMake(rect.origin.x, rect.size.height - self.contentHeight, rect.size.width, self.contentHeight);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect rect = [super clearButtonRectForBounds:bounds];
//    CGFloat top = bounds.size.height - self.contentHeight + (self.contentHeight - rect.size.height) * 0.5;
//    return CGRectMake(rect.origin.x, top, rect.size.width, rect.size.height);
    return CGRectMake(rect.origin.x, bounds.size.height - self.contentHeight, rect.size.width, self.contentHeight);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super leftViewRectForBounds:bounds];
    return CGRectMake(rect.origin.x, bounds.size.height - self.leftView.height, rect.size.width, self.leftView.height);
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super rightViewRectForBounds:bounds];
    return CGRectMake(rect.origin.x, bounds.size.height - self.rightView.height, rect.size.width, self.rightView.height);
}

- (void)beginEditing {
    [self ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#47cfbe"]];
}

- (void)endEditing {
    [self ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
}

@end
