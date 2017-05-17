//
//  SSJFundingTransferPeriodSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 17/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferPeriodSelectionView.h"
#import "SSJBaseTableViewCell.h"

static const CGFloat kTitleHeight = 48;
static const CGFloat kRowHeight = 50;

static NSString *kCellID = @"cellID";

@interface SSJFundingTransferPeriodSelectionView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *accessoryView;

@property (nonatomic, strong) NSArray *cycleTypes;

@end

@implementation SSJFundingTransferPeriodSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectedType = SSJCyclePeriodTypeOnce;
        _cycleTypes = @[@(SSJCyclePeriodTypeOnce),
                        @(SSJCyclePeriodTypeDaily),
                        @(SSJCyclePeriodTypeWorkday),
                        @(SSJCyclePeriodTypePerWeekend),
                        @(SSJCyclePeriodTypeWeekly),
                        @(SSJCyclePeriodTypePerMonth),
                        @(SSJCyclePeriodTypeLastDayPerMonth),
                        @(SSJCyclePeriodTypePerYear)];
        
        [self addSubview:self.titleLab];
        [self addSubview:self.tableView];
        [self sizeToFit];
        [self updateAppearanceAccordingToTheme];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLab.frame = CGRectMake(0, 0, self.width, kTitleHeight);
    self.tableView.frame = CGRectMake(0, kTitleHeight, self.width, kRowHeight * self.cycleTypes.count);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, kTitleHeight + kRowHeight * _cycleTypes.count);
}

- (void)setSelectedType:(SSJCyclePeriodType)selectedType {
    if (_selectedType != selectedType) {
        _selectedType = selectedType;
        [self.tableView reloadData];
    }
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

- (void)updateAppearanceAccordingToTheme {
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [self.tableView reloadData];
    [self.tableView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor]];
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    self.accessoryView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cycleTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    SSJCyclePeriodType type = [[_cycleTypes ssj_safeObjectAtIndex:indexPath.row] integerValue];
    cell.textLabel.text = SSJTitleForCycleType(type);
    cell.accessoryView = type == _selectedType ? self.accessoryView : nil;
    cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedType = [[_cycleTypes ssj_safeObjectAtIndex:indexPath.row] integerValue];
    [self.tableView reloadData];
    [self dismiss];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Lazy
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.text = @"周期";
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = kRowHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.scrollEnabled = NO;
        
        [_tableView ssj_setBorderWidth:2];
        [_tableView ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _tableView;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _accessoryView;
}

@end
