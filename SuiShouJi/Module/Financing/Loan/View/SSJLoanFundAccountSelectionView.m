//
//  SSJLoanFundAccountSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/8/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanFundAccountSelectionView.h"
#import "SSJLoanFundAccountSelectionCell.h"
#import "SSJLoanFundAccountSelectionCellItem.h"

static NSString *const kCellId = @"SSJLoanFundAccountSelectionCell";

@interface SSJLoanFundAccountSelectionView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *cellItems;

@end

@implementation SSJLoanFundAccountSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.closeButton];
        [self addSubview:self.tableView];
        [self updateAppearance];
        
        _cellItems = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews {
    _titleLabel.frame = CGRectMake(0, 0, self.width, 44);
    _closeButton.frame = CGRectMake(0, 0, 44, 44);
    _tableView.top = 44;
    _tableView.height = self.height - 44;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJLoanFundAccountSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    cell.cellItem = [self.cellItems ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL shouldSelect = YES;
    if (_shouldSelectAccountAction) {
        shouldSelect = _shouldSelectAccountAction(self, indexPath.row);
    }
    
    if (shouldSelect) {
        self.selectedIndex = indexPath.row;
    }
    
    if (_selectAccountAction) {
        _selectAccountAction(self);
    }
    
    [self dismiss];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex >= (NSInteger)_cellItems.count) {
        SSJPRINT(@"警告：selectedIndex大于数组的范围");
        return;
    }
    
    _selectedIndex = selectedIndex;
    for (int i = 0; i < _cellItems.count; i ++) {
        SSJLoanFundAccountSelectionCellItem *cellItem = _cellItems[i];
        cellItem.showCheckMark = (i == _selectedIndex);
    }
}

- (void)setItems:(NSArray<SSJLoanFundAccountSelectionViewItem *> *)items {
    _items = items;
    [_cellItems removeAllObjects];
    
    _selectedIndex = 0;
    
    for (int i = 0; i < _items.count; i ++) {
        SSJLoanFundAccountSelectionViewItem *item = _items[i];
        SSJLoanFundAccountSelectionCellItem *cellItem = [SSJLoanFundAccountSelectionCellItem cellItemWithViewItem:item];
        cellItem.showCheckMark = i == _selectedIndex;
        [_cellItems addObject:cellItem];
    }
    
    [self.tableView reloadData];
}

- (void)updateAppearance {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _closeButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    [_titleLabel ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [_titleLabel ssj_setBorderStyle:SSJBorderStyleBottom];
    [_titleLabel ssj_setBorderWidth:1];
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
    
    if (_selectedIndex >= 0 && _selectedIndex < [_tableView numberOfRowsInSection:0]) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
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

#pragma mark - Event
- (void)closeButtonClicked {
    [self dismiss];
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = self.title.length ? self.title : @"选择资金账户";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView registerClass:[SSJLoanFundAccountSelectionCell class] forCellReuseIdentifier:kCellId];
        [_tableView ssj_clearExtendSeparator];
    }
    return _tableView;
}

@end
