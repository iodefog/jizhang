//
//  SSJLoanInterestTypeAlertView.m
//  SuiShouJi
//
//  Created by old lang on 16/11/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanInterestTypeAlertView.h"

@interface SSJLoanInterestTypeAlertView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) UIButton *button1;

@property (nonatomic, strong) UIButton *button2;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) NSMutableArray *otherButtonItems;

@property (nonatomic, strong) SSJLoanInterestTypeAlertViewButtonItem *sureButtonItem;

@end

@implementation SSJLoanInterestTypeAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithTitle:nil sureButtonItem:nil otherButtonItem:nil];
}

- (instancetype)initWithTitle:(NSString *)title sureButtonItem:(SSJLoanInterestTypeAlertViewButtonItem *)sureButtonItem otherButtonItem:(nullable SSJLoanInterestTypeAlertViewButtonItem *)otherButtonItem,... {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.otherButtonItems = [[NSMutableArray alloc] init];
        if (otherButtonItem) {
            [self.otherButtonItems addObject:otherButtonItem];
        }
        
        va_list actionList;
        va_start(actionList, otherButtonItem);
        SSJLoanInterestTypeAlertViewButtonItem *tempItem = nil;
        while ((tempItem = va_arg(actionList, SSJLoanInterestTypeAlertViewButtonItem *))) {
            [self.otherButtonItems addObject:tempItem];
        }
        va_end(actionList);
        
        
        [self addSubview:self.titleLab];
        [self addSubview:self.sureButton];
        [self initButtons];
    }
    
    return self;
}

- (void)layoutSubviews {
    
}

- (void)initButtons {
    
}

//- (void)

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        _titleLab.text = @"";
    }
    return _titleLab;
}

- (UILabel *)descLab {
    if (!_descLab) {
        
    }
    return _descLab;
}

@end
