//
//  SSJBudgetNodataRemindView.m
//  SuiShouJi
//
//  Created by old lang on 16/7/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetNodataRemindView.h"

@interface SSJBudgetNodataRemindView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SSJBudgetNodataRemindView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"budget_no_data"]];
        [self addSubview:_imageView];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        [self addSubview:_titleLab];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat spaceY = 10;
    CGFloat y = (self.height - _imageView.height - _titleLab.height - spaceY) * 0.5;
    
    _imageView.top = y;
    _titleLab.top = _imageView.bottom + spaceY;
    _imageView.centerX = _titleLab.centerX = self.width * 0.5;
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
        _titleLab.text = title;
        [_titleLab sizeToFit];
        [self setNeedsLayout];
    }
}

@end
