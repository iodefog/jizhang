//
//  SSJLoanDetailChargeChangeHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/11/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDetailChargeChangeHeaderView.h"

@interface SSJLoanDetailChargeChangeHeaderView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *arrow;

@end

@implementation SSJLoanDetailChargeChangeHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14];
        [self addSubview:_titleLab];
        
        _arrow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [self addSubview:_arrow];
    }
    return self;
}

- (void)layoutSubviews {
    [_titleLab sizeToFit];
    _titleLab.left = 15;
    _titleLab.centerY = self.height * 0.5;
    
//    _arrow
}

- (void)setExpanded:(BOOL)expanded {
    
}

- (void)updateAppearance {
    
}

@end
