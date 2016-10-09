//
//  SSJMultiFunctionButton.m
//  SuiShouJi
//
//  Created by ricky on 16/9/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMultiFunctionButtonView.h"

static const CGFloat kButtonWidth = 36.0;

static const CGFloat kButtonGap = 8.0; 

@interface SSJMultiFunctionButtonView()

@property (nonatomic, strong) NSMutableArray *buttons;

@end


@implementation SSJMultiFunctionButtonView


- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    self.right = keyWindow.width;
    self.centerY = keyWindow.height / 2;
    self.alpha = 0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL complation) {
                         if (_showBlock) {
                             _showBlock();
                         }
                     }];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL complation) {
                         [self removeFromSuperview];
                         if (_dismissBlock) {
                             _dismissBlock();
                         }
                     }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
