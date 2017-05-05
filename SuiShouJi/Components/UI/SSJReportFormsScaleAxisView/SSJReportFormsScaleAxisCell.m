//
//  SSJReportFormsScaleAxisCell.m
//  SSJReportFormsScaleAxisView
//
//  Created by old lang on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsScaleAxisCell.h"

@implementation SSJReportFormsScaleAxisCellItem

@end

@interface SSJReportFormsScaleAxisCell ()

@property (nonatomic, strong) UIView *tickMark;

@property (nonatomic, strong) UILabel *scaleValueLab;

@end

@implementation SSJReportFormsScaleAxisCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _tickMark = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
        _tickMark.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_tickMark];
        
        _scaleValueLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 12)];
        _scaleValueLab.font = [UIFont systemFontOfSize:11];
        _scaleValueLab.textColor = [UIColor lightTextColor];
        _scaleValueLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_scaleValueLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _tickMark.centerX = self.contentView.width * 0.5;
    _tickMark.height = _item.scaleHeight;
    _tickMark.bottom = self.contentView.height;
    
    _scaleValueLab.bottom = _tickMark.top - 3;
}

- (void)setItem:(SSJReportFormsScaleAxisCellItem *)item {
    _item = item;
    
    @weakify(self);
    [[RACObserve(_item, scaleValue) takeUntil:[self rac_prepareForReuseSignal]] subscribeNext:^(NSString *scaleValue) {
        @strongify(self);
        self.scaleValueLab.text = scaleValue;
    }];
    [[RACObserve(_item, font) takeUntil:[self rac_prepareForReuseSignal]] subscribeNext:^(UIFont *font) {
        @strongify(self);
        self.scaleValueLab.font = font;
    }];
    [[RACObserve(_item, scaleColor) takeUntil:[self rac_prepareForReuseSignal]] subscribeNext:^(UIColor *scaleColor) {
        @strongify(self);
        self.scaleValueLab.textColor = scaleColor;
        self.tickMark.backgroundColor = scaleColor;
    }];
    [[RACObserve(_item, scaleHeight) takeUntil:[self rac_prepareForReuseSignal]] subscribeNext:^(NSNumber *value) {
        @strongify(self);
        [self setNeedsLayout];
    }];
    [[RACObserve(_item, scaleMarkShowed) takeUntil:[self rac_prepareForReuseSignal]] subscribeNext:^(NSNumber *showedValue) {
        @strongify(self);
        self.tickMark.hidden = ![showedValue boolValue];
    }];
}

@end
