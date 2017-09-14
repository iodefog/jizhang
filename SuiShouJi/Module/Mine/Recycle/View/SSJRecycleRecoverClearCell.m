//
//  SSJRecycleRecoverClearCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleRecoverClearCell.h"

@interface SSJRecycleRecoverClearCell ()

@property (nonatomic, strong) UIButton *recoverBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation SSJRecycleRecoverClearCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.recoverBtn];
        [self.contentView addSubview:self.deleteBtn];
        [self.contentView ssj_setBorderStyle:SSJBorderStyleBottom];
        [self updateAppearanceAccordingToTheme];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [_recoverBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(self.contentView);
    }];
    [_deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_recoverBtn.mas_right);
        make.width.mas_equalTo(_recoverBtn);
        make.top.right.bottom.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJRecycleRecoverClearCellItem class]]) {
        return;
    }
    
    [super setCellItem:cellItem];
    SSJRecycleRecoverClearCellItem *item = cellItem;
    [[RACObserve(item, recoverBtnLoading) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *loadingValue) {
        self.recoverBtn.enabled = ![loadingValue boolValue];
        if ([loadingValue boolValue]) {
            [self.recoverBtn ssj_showLoadingIndicator];
        } else {
            [self.recoverBtn ssj_hideLoadingIndicator];
        }
    }];
    
    [[RACObserve(item, clearBtnLoading) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *loadingValue) {
        self.deleteBtn.enabled = ![loadingValue boolValue];
        if ([loadingValue boolValue]) {
            [self.deleteBtn ssj_showLoadingIndicator];
        } else {
            [self.deleteBtn ssj_hideLoadingIndicator];
        }
    }];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearanceAccordingToTheme];
}

- (UIButton *)recoverBtn {
    if (!_recoverBtn) {
        _recoverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recoverBtn setTitle:NSLocalizedString(@"还原", nil) forState:UIControlStateNormal];
        [_recoverBtn setTitle:nil forState:UIControlStateDisabled];
        [_recoverBtn setImage:[[UIImage imageNamed:@"recycle_recover"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_recoverBtn setImage:nil forState:UIControlStateDisabled];
        _recoverBtn.spaceBetweenImageAndTitle = 10;
        [_recoverBtn ssj_setBorderWidth:1];
        [_recoverBtn ssj_setBorderStyle:SSJBorderStyleRight];
        @weakify(self);
        [[_recoverBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.recoverBtnDidClick) {
                self.recoverBtnDidClick(self);
            }
        }];
    }
    return _recoverBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setTitle:NSLocalizedString(@"彻底删除", nil) forState:UIControlStateNormal];
        [_deleteBtn setTitle:nil forState:UIControlStateDisabled];
        [_deleteBtn setImage:[[UIImage imageNamed:@"recycle_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_deleteBtn setImage:nil forState:UIControlStateDisabled];
        _deleteBtn.spaceBetweenImageAndTitle = 10;
        @weakify(self);
        [[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.deleteBtnDidClick) {
                self.deleteBtnDidClick(self);
            }
        }];
    }
    return _deleteBtn;
}

- (void)updateAppearanceAccordingToTheme {
    _recoverBtn.imageView.tintColor = SSJ_SECONDARY_COLOR;
    [_recoverBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
    [_recoverBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    
    _deleteBtn.imageView.tintColor = SSJ_SECONDARY_COLOR;
    [_deleteBtn setTitleColor:SSJ_MAIN_COLOR forState:UIControlStateNormal];
    [self.contentView ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
}

@end
