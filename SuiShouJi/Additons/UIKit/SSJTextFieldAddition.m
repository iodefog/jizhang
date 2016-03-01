//
//  SSJTextFieldAddition.m
//  SuiShouJi
//
//  Created by old lang on 16/3/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJTextFieldAddition.h"
#import <objc/runtime.h>

static const void *kDecimalDigitsKey = &kDecimalDigitsKey;

@implementation UITextField (SSJDecimal)

- (void)ssj_dealloc {
    [self ssj_dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)ssj_limitDecimalDigits:(int)digits {
    static BOOL isExchanged = NO;
    if (!isExchanged) {
        isExchanged = YES;
        Method originalMethod = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
        Method swizzledMethod = class_getInstanceMethod([self class], @selector(ssj_dealloc));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ssj_textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    objc_setAssociatedObject(self, kDecimalDigitsKey, @(digits), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ssj_textFieldDidChange {
    
    int digits = [objc_getAssociatedObject(self, kDecimalDigitsKey) intValue];
    NSArray *arr = [self.text componentsSeparatedByString:@"."];
    
    if ([self.text isEqualToString:@"0."] || [self.text isEqualToString:@"."]) {
        self.text = @"0.";
    }else if (self.text.length == 2) {
        if ([self.text floatValue] == 0) {
            self.text = @"0";
        }else if(arr.count < 2){
            self.text = [NSString stringWithFormat:@"%d",[self.text intValue]];
        }
    }
    
    if (arr.count > 2) {
        self.text = [NSString stringWithFormat:@"%@.%@",arr[0],arr[1]];
    }
    
    if (arr.count == 2) {
        NSString * lastStr = arr.lastObject;
        if (lastStr.length > digits) {
            self.text = [NSString stringWithFormat:@"%@.%@",arr[0],[lastStr substringToIndex:digits]];
        }
    }
}

@end