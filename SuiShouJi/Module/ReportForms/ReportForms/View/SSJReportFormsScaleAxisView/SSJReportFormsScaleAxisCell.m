//
//  SSJReportFormsScaleAxisCell.m
//  SSJReportFormsScaleAxisView
//
//  Created by old lang on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsScaleAxisCell.h"

#warning test
#import "SSJViewAddition.h"

@interface SSJReportFormsScaleAxisCell ()

@property (nonatomic, strong) UIView *tickMark;

@property (nonatomic, strong) UILabel *scaleValueLab;

@end

@implementation SSJReportFormsScaleAxisCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.contentView.backgroundColor = [UIColor ssj_colorWithHex:@"F8F8F8"];
        
        _tickMark = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
        _tickMark.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_tickMark];
        
        _scaleValueLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 12)];
        _scaleValueLab.font = [UIFont systemFontOfSize:12];
        _scaleValueLab.textColor = [UIColor lightTextColor];
        _scaleValueLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_scaleValueLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _tickMark.centerX = self.contentView.width * 0.5;
    _tickMark.height = _scaleHeight;
    _tickMark.bottom = self.contentView.height;
    
    _scaleValueLab.bottom = _tickMark.top - 3;
}

- (void)setScaleValue:(NSString *)scaleValue {
    _scaleValueLab.text = scaleValue;
}

- (void)setScaleColor:(UIColor *)scaleColor {
    _scaleValueLab.textColor = scaleColor;
    _tickMark.backgroundColor = scaleColor;
}

- (void)setScaleHeight:(CGFloat)scaleHeight {
    if (_scaleHeight != scaleHeight) {
        _scaleHeight = scaleHeight;
        [self setNeedsLayout];
    }
}

@end
