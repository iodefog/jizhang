//
//  SSJBudgetEditPeriodSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditPeriodSelectionView.h"
#import "SSJBaseTableViewCell.h"

static const CGFloat kTitleHeight = 50;
static const CGFloat kRowHeight = 45;

static NSString *const kWeekTitle = @"每周";
static NSString *const kMonthTitle = @"每月";
static NSString *const kYearTitle = @"每年";

static NSString *kCellID = @"cellID";

@interface SSJBudgetEditPeriodSelectionView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *accessoryView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation SSJBudgetEditPeriodSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titles = @[kWeekTitle, kMonthTitle, kYearTitle];
        [self addSubview:self.titleLab];
        [self addSubview:self.tableView];
        [self sizeToFit];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLab.frame = CGRectMake(0, 0, self.width, kTitleHeight);
    self.tableView.frame = CGRectMake(0, kTitleHeight, self.width, kRowHeight * self.titles.count);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, kTitleHeight + kRowHeight * self.titles.count);
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:NULL];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    NSString *title = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    cell.accessoryView = [title isEqualToString:[self selectedTitle]] ? self.accessoryView : nil;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    if ([title isEqualToString:kWeekTitle]) {
        self.periodType = SSJBudgetPeriodTypeWeek;
    } else if ([title isEqualToString:kMonthTitle]) {
        self.periodType = SSJBudgetPeriodTypeMonth;
    } else if ([title isEqualToString:kYearTitle]) {
        self.periodType = SSJBudgetPeriodTypeYear;
    }
    
    [self.tableView reloadData];
    [self dismiss];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (NSString *)selectedTitle {
    switch (self.periodType) {
        case SSJBudgetPeriodTypeWeek:
            return kWeekTitle;
            
        case SSJBudgetPeriodTypeMonth:
            return kMonthTitle;
            
        case SSJBudgetPeriodTypeYear:
            return kYearTitle;
    }
    return nil;
}

#pragma mark - Getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.text = @"周期";
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 44;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.scrollEnabled = NO;
        
        [_tableView ssj_setBorderWidth:2];
        [_tableView ssj_setBorderStyle:SSJBorderStyleTop];
        [_tableView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor]];
    }
    return _tableView;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _accessoryView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _accessoryView;
}

@end
