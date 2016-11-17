//
//  SSJLoanInterestTypeAlertView.m
//  SuiShouJi
//
//  Created by old lang on 16/11/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanInterestTypeAlertView.h"
#import "SSJBorderButton.h"

@interface SSJLoanInterestTypeAlertView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) SSJBorderButton *button1;

@property (nonatomic, strong) SSJBorderButton *button2;

@property (nonatomic, strong) UIButton *sureButton;


@end

@implementation SSJLoanInterestTypeAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithTitle:nil sureButtonItem:nil otherButtonItem:nil];
}

- (instancetype)initWithTitle:(NSString *)title sureButtonItem:(SSJLoanInterestTypeAlertViewButtonItem *)sureButtonItem otherButtonItem:(nullable SSJLoanInterestTypeAlertViewButtonItem *)otherButtonItem,... {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        
        NSMutableArray *buttonItems = [[NSMutableArray alloc] init];
        if (otherButtonItem) {
            [buttonItems addObject:otherButtonItem];
        }
        
        va_list actionList;
        va_start(actionList, otherButtonItem);
        SSJLoanInterestTypeAlertViewButtonItem *tempItem = nil;
        while ((tempItem = va_arg(actionList, SSJLoanInterestTypeAlertViewButtonItem *))) {
            [buttonItems addObject:tempItem];
        }
        va_end(actionList);
//        [self initButtonsWithItems:buttonItems];
        
        self.sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self updateButton:self.sureButton withItem:sureButtonItem];
        
        self.titleLab.text = title;
        
        [self addSubview:self.titleLab];
        [self addSubview:self.sureButton];
    }
    
    return self;
}

- (void)layoutSubviews {
    
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#393939"];
    }
    return _titleLab;
}

- (SSJBorderButton *)button1 {
    if (!_button1) {
        _button1 = [[SSJBorderButton alloc] init];
        [_button1 setFontSize:21];
        [_button1 setTitle:@"" forState:SSJBorderButtonStateNormal];
        [_button1 setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:SSJBorderButtonStateNormal];
        [_button1 setTitleColor:[UIColor whiteColor] forState:SSJBorderButtonStateHighlighted];
        [_button1 setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:SSJBorderButtonStateNormal];
        [_button1 setBackgroundColor:[UIColor clearColor] forState:SSJBorderButtonStateNormal];
        [_button1 setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:SSJBorderButtonStateHighlighted];
    }
    return _button1;
}

@end
