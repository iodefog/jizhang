//
//  SSJBaseTableViewCell.m
//  MoneyMore
//
//  Created by old lang on 15-3-23.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJBaseTableViewCell ()

@property (nonatomic, strong) UIImageView *indicatorView;

@end

@implementation SSJBaseTableViewCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return 48;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.appliesTheme = YES;
        self.contentView.backgroundColor = [UIColor clearColor];
        [self updateCellAppearanceAfterThemeChanged];
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [self setPreservesSuperviewLayoutMargins:NO];
        }
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        
        if (self.appliesTheme) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_customAccessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        CGFloat accessoryWidth = 33;
        self.contentView.frame = CGRectMake(0, 0, self.width - accessoryWidth, self.height);
        _indicatorView.center = CGPointMake(self.contentView.right + accessoryWidth * 0.5 - 5, self.height * 0.5);
    } else {
//        self.contentView.frame = self.bounds;
    }
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJBaseCellItem class]]) {
        return;
    }
    
    _cellItem = cellItem;
    self.separatorInset = _cellItem.separatorInsets;
    self.selectionStyle = _cellItem.selectionStyle;
}

- (void)setCustomAccessoryType:(UITableViewCellAccessoryType)customAccessoryType {
    if (_customAccessoryType != customAccessoryType) {
        _customAccessoryType = customAccessoryType;
        
        if (customAccessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            if (!self.indicatorView.superview) {
                [self addSubview:self.indicatorView];
            }
        } else {
            if (self.indicatorView.superview) {
                [self.indicatorView removeFromSuperview];
            }
        }
        
        [self setNeedsLayout];
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    self.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    self.backgroundColor = SSJ_MAIN_BACKGROUND_COLOR;
    _indicatorView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor];
}

- (UIImageView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cellIndicator"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _indicatorView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor];
    }
    return _indicatorView;
}

@end
