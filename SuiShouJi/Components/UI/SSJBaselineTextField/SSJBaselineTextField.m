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
        
        self.normalLineColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        self.highlightLineColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginSecondaryColor];
        
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self ssj_setBorderWidth:2.0];
        [self ssj_setBorderColor:self.normalLineColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditing) name:UITextFieldTextDidBeginEditingNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing) name:UITextFieldTextDidEndEditingNotification object:self];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    if (CGRectEqualToRect(self.bounds, bounds)) {
        CGFloat top = bounds.size.height - self.contentHeight + (self.contentHeight - rect.size.height) * 0.5;
        return CGRectMake(rect.origin.x, top, rect.size.width, rect.size.height);
    } else {
        return rect;
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super editingRectForBounds:bounds];
    if (CGRectEqualToRect(self.bounds, bounds)) {
        CGFloat top = bounds.size.height - self.contentHeight + (self.contentHeight - rect.size.height) * 0.5;
        return CGRectMake(rect.origin.x, top, rect.size.width, rect.size.height);
    } else {
        return rect;
    }
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect rect = [super clearButtonRectForBounds:bounds];
    if (CGRectEqualToRect(self.bounds, bounds)) {
        CGFloat top = bounds.size.height - self.contentHeight + (self.contentHeight - rect.size.height) * 0.5;
        return CGRectMake(rect.origin.x, top, rect.size.width, rect.size.height);
    } else {
        return rect;
    }
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super leftViewRectForBounds:bounds];
    if (CGRectEqualToRect(self.bounds, bounds)) {
        CGFloat top = bounds.size.height - self.contentHeight + (self.contentHeight - rect.size.height) * 0.5;
        return CGRectMake(rect.origin.x, top, rect.size.width, rect.size.height);
    } else {
        return rect;
    }
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rect = [super rightViewRectForBounds:bounds];
    if (CGRectEqualToRect(self.bounds, bounds)) {
        CGFloat top = bounds.size.height - self.contentHeight + (self.contentHeight - rect.size.height) * 0.5;
        return CGRectMake(rect.origin.x, top, rect.size.width, rect.size.height);
    } else {
        return rect;
    }
}

- (void)beginEditing {
    [self ssj_setBorderColor:self.highlightLineColor];
}

- (void)endEditing {
    [self ssj_setBorderColor:self.normalLineColor];
}

@end
