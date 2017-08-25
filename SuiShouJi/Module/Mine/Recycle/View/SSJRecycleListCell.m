//
//  SSJRecycleListCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleListCell.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJRecycleListCellSeparatorView
#pragma mark -

@interface _SSJRecycleListCellSeparatorView : UIView

@property (nonatomic, strong) NSArray<NSString *> *titles;

@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;

@end

@implementation _SSJRecycleListCellSeparatorView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.labels = [NSMutableArray array];
    }
    return self;
}

- (void)updateConstraints {
    [self.labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (idx == 0) {
                make.left.mas_equalTo(self);
            } else {
                UILabel *preLab = self.labels[idx - 1];
                make.left.mas_equalTo(preLab.mas_right);
            }
            make.top.and.bottom.mas_equalTo(self);
        }];
    }];
    [super updateConstraints];
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = titles;
    
    if (self.labels.count < titles.count) {
        // 如果lab不够就继续创建新的
        for (int i = 0; titles.count - self.labels.count; i ++) {
            UILabel *lab = [[UILabel alloc] init];
            lab.textColor = SSJ_SECONDARY_COLOR;
            [lab ssj_setBorderColor:SSJ_BORDER_COLOR];
            [lab ssj_setBorderInsets:UIEdgeInsetsMake(2, 0, 2, 0)];
            lab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
            [self.labels addObject:lab];
            [self addSubview:lab];
        }
    }
    
    [self.labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < _titles.count - 1) {
            obj.text = _titles[idx];
            [obj ssj_setBorderStyle:SSJBorderStyleRight];
            obj.hidden = NO;
        } else if (idx == _titles.count - 1) {
            obj.text = _titles[idx];
            [obj ssj_setBorderStyle:SSJBorderStyleleNone];
            obj.hidden = NO;
        } else {
            obj.hidden = YES;
        }
    }];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateAppearanceAccordingToTheme {
    [self.labels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hidden) {
            *stop = YES;
        }
        obj.textColor = SSJ_SECONDARY_COLOR;
        [obj ssj_setBorderColor:SSJ_BORDER_COLOR];
    }];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJRecycleListCellExpandedView
#pragma mark -

@interface _SSJRecycleListCellExpandedView : UIView

@property (nonatomic, strong) UIButton *recoverBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation _SSJRecycleListCellExpandedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.recoverBtn];
        [self addSubview:self.deleteBtn];
        [self ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
        [self updateAppearanceAccordingToTheme];
    }
    return self;
}

- (void)updateConstraints {
    [_recoverBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(self);
    }];
    [_deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_recoverBtn.mas_right);
        make.top.right.bottom.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (UIButton *)recoverBtn {
    if (!_recoverBtn) {
        _recoverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recoverBtn setTitle:NSLocalizedString(@"还原", nil) forState:UIControlStateNormal];
        [_recoverBtn setTitle:nil forState:UIControlStateDisabled];
        [_recoverBtn setImage:[UIImage imageNamed:@"recycle_recover"] forState:UIControlStateNormal];
        [_recoverBtn setImage:nil forState:UIControlStateDisabled];
        _recoverBtn.spaceBetweenImageAndTitle = 10;
        [_recoverBtn ssj_setBorderStyle:SSJBorderStyleRight];
    }
    return _recoverBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setTitle:NSLocalizedString(@"彻底删除", nil) forState:UIControlStateNormal];
        [_deleteBtn setTitle:nil forState:UIControlStateDisabled];
        [_deleteBtn setImage:[UIImage imageNamed:@"recycle_delete"] forState:UIControlStateNormal];
        [_deleteBtn setImage:nil forState:UIControlStateDisabled];
        _deleteBtn.spaceBetweenImageAndTitle = 10;
    }
    return _deleteBtn;
}

- (void)updateAppearanceAccordingToTheme {
    _recoverBtn.tintColor = SSJ_SECONDARY_COLOR;
    [_recoverBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
    [_recoverBtn ssj_setBorderColor:SSJ_BORDER_COLOR];
    
    _deleteBtn.tintColor = SSJ_SECONDARY_COLOR;
    [_deleteBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
    
    [self ssj_setBorderColor:SSJ_BORDER_COLOR];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJRecycleListCellItem
#pragma mark -
@implementation SSJRecycleListCellItem

+ (instancetype)itemWithRecycleID:(NSString *)recycleID
                             icon:(UIImage *)icon
                    iconTintColor:(UIColor *)iconTintColor
                            title:(NSString *)title
                        subtitles:(NSArray<NSString *> *)subtitles
                            state:(SSJRecycleListCellState)state {
    SSJRecycleListCellItem *item = [[SSJRecycleListCellItem alloc] init];
    item.recycleID = recycleID;
    item.icon = icon;
    item.iconTintColor = iconTintColor;
    item.title = title;
    item.subtitles = subtitles;
    item.state = state;
    return item;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJRecycleListCell
#pragma mark -
@interface SSJRecycleListCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) _SSJRecycleListCellSeparatorView *subtitleView;

@property (nonatomic, strong) UIButton *arrowBtn;

@property (nonatomic, strong) _SSJRecycleListCellExpandedView *expandedView;

@property (nonatomic, strong) UIImageView *checkMark;

@end

@implementation SSJRecycleListCell

- (void)dealloc {
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self updateAppearance];
    }
    return self;
}

- (void)updateConstraints {
    [_icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.top.mas_equalTo(self.contentView).offset(12);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [_titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_icon.mas_right).offset(10);
        make.centerY.mas_equalTo(_icon);
    }];
    
    [_arrowBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(41, 41));
        make.right.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(_icon);
    }];
    
    [_subtitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_titleLab);
        make.top.mas_equalTo(_titleLab.mas_bottom).offset(8);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(13);
    }];
    
    [_expandedView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_subtitleView.mas_bottom).offset(19);
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo([self item].state == SSJRecycleListCellStateExpanded ? 44 : 0);
    }];
    
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJRecycleListCellItem class]]) {
        return;
    }
    
    SSJRecycleListCellItem *item = cellItem;
    
    @weakify(self);
    [[RACObserve(item, state) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *stateValue) {
        @strongify(self);
        
        switch ([stateValue integerValue]) {
            case SSJRecycleListCellStateNormal: {
                UIImage *btnImg = [[UIImage imageNamed:@"recycle_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [_arrowBtn setImage:btnImg forState:UIControlStateNormal];
                self.arrowBtn.hidden = NO;
                self.checkMark.hidden = YES;
            }
                break;
                
            case SSJRecycleListCellStateExpanded: {
                UIImage *btnImg = [[UIImage imageNamed:@"recycle_arrow_up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [self.arrowBtn setImage:btnImg forState:UIControlStateNormal];
                self.arrowBtn.hidden = NO;
                self.checkMark.hidden = YES;
            }
                break;
                
            case SSJRecycleListCellStateSelected: {
                self.arrowBtn.hidden = YES;
                self.checkMark.hidden = NO;
                self.checkMark.tintColor = SSJ_MARCATO_COLOR;
            }
                break;
                
            case SSJRecycleListCellStateUnselected: {
                self.arrowBtn.hidden = YES;
                self.checkMark.hidden = NO;
                self.checkMark.tintColor = SSJ_SECONDARY_COLOR;
            }
                break;
        }
        
        [self setNeedsUpdateConstraints];
    }];
    
    [[RACObserve(item, recoverBtnLoading) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *loadingValue) {
        self.expandedView.recoverBtn.enabled = ![loadingValue boolValue];
        if ([loadingValue boolValue]) {
            [self.expandedView.recoverBtn ssj_showLoadingIndicator];
        } else {
            [self.expandedView.recoverBtn ssj_hideLoadingIndicator];
        }
    }];
    
    [[RACObserve(item, clearBtnLoading) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *loadingValue) {
        self.expandedView.deleteBtn.enabled = ![loadingValue boolValue];
        if ([loadingValue boolValue]) {
            [self.expandedView.deleteBtn ssj_showLoadingIndicator];
        } else {
            [self.expandedView.deleteBtn ssj_hideLoadingIndicator];
        }
    }];
}

- (SSJRecycleListCellItem *)item {
    return (SSJRecycleListCellItem *)self.cellItem;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _titleLab.textColor = SSJ_MAIN_COLOR;
    _arrowBtn.tintColor = SSJ_SECONDARY_COLOR;
    [_subtitleView updateAppearanceAccordingToTheme];
    [_expandedView updateAppearanceAccordingToTheme];
    
    if ([self item].state == SSJRecycleListCellStateSelected) {
        _checkMark.tintColor = SSJ_MARCATO_COLOR;
    } else if ([self item].state == SSJRecycleListCellStateSelected) {
        _checkMark.tintColor = SSJ_SECONDARY_COLOR;
    }
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLab;
}

- (_SSJRecycleListCellSeparatorView *)subtitleView {
    if (!_subtitleView) {
        _subtitleView = [[_SSJRecycleListCellSeparatorView alloc] init];
    }
    return _subtitleView;
}

- (UIButton *)arrowBtn {
    if (!_arrowBtn) {
        _arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        @weakify(self);
        [[_arrowBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.expandBtnDidClick) {
                self.expandBtnDidClick(self);
            }
        }];
    }
    return _arrowBtn;
}

- (_SSJRecycleListCellExpandedView *)expandedView {
    if (!_expandedView) {
        _expandedView = [[_SSJRecycleListCellExpandedView alloc] init];
        @weakify(self);
        [[_expandedView.recoverBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.recoverBtnDidClick) {
                self.recoverBtnDidClick(self);
            }
        }];
        [[_expandedView.deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.deleteBtnDidClick) {
                self.deleteBtnDidClick(self);
            }
        }];
    }
    return _expandedView;
}

- (UIImageView *)checkMark {
    if (!_checkMark) {
        _checkMark = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"recycle_checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _checkMark;
}

@end
