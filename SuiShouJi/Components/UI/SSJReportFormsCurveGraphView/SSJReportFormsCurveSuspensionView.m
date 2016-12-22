//
//  SSJReportFormsCurveSuspensionView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveSuspensionView.h"

#pragma mark -
#pragma mark - SSJReportFormsCurveSuspensionViewItem
@implementation SSJReportFormsCurveSuspensionViewItem

@end

#pragma mark -
#pragma mark - _SSJReportFormsCurveSuspensionHeaderView
@interface _SSJReportFormsCurveSuspensionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) SSJReportFormsCurveSuspensionViewItem *item;

@end

@interface _SSJReportFormsCurveSuspensionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation _SSJReportFormsCurveSuspensionHeaderView

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blueColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:_titleLabel];
        
        self.backgroundView = [[UIView alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = self.contentView.bounds;
}

- (void)setItem:(SSJReportFormsCurveSuspensionViewItem *)item {
    [self removeObserver];
    _item = item;
    [self updateAppearance];
    [self addObserver];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

- (void)addObserver {
    [_item addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"titleColor" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"titleFont" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserver {
    [_item removeObserver:self forKeyPath:@"title"];
    [_item removeObserver:self forKeyPath:@"titleColor"];
    [_item removeObserver:self forKeyPath:@"titleFont"];
}

- (void)updateAppearance {
    _titleLabel.text = _item.title;
    _titleLabel.font = _item.titleFont;
    _titleLabel.textColor = _item.titleColor;
}

@end

#pragma mark -
#pragma mark - _SSJReportFormsCurveSuspensionTableView
@interface _SSJReportFormsCurveSuspensionTableView : UITableView

@end

@implementation _SSJReportFormsCurveSuspensionTableView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[_SSJReportFormsCurveSuspensionHeaderView class]]) {
            subview.width = self.height;
        }
    }
}

@end

#pragma mark -
static NSString *const kSSJReportFormsCurveSuspensionHeaderViewID = @"kSSJReportFormsCurveSuspensionHeaderViewID";

@interface SSJReportFormsCurveSuspensionView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) _SSJReportFormsCurveSuspensionTableView *tableView;

@end

@implementation SSJReportFormsCurveSuspensionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _unitSpace = 44;
        _contentOffsetX = 0;
        
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _tableView.frame = self.bounds;
    _tableView.contentOffset = CGPointMake(0, _contentOffsetX);
}

- (void)setUnitSpace:(CGFloat)unitSpace {
    if (_unitSpace != unitSpace) {
        _unitSpace = unitSpace;
        _tableView.sectionHeaderHeight = unitSpace;
        _tableView.rowHeight = unitSpace;
        [_tableView reloadData];
    }
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX {
    if (_contentOffsetX != contentOffsetX) {
        _contentOffsetX = contentOffsetX;
        _tableView.contentOffset = CGPointMake(0, _contentOffsetX);
    }
}

- (void)setItems:(NSArray<SSJReportFormsCurveSuspensionViewItem *> *)items {
    _items = items;
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_items.count > section) {
        SSJReportFormsCurveSuspensionViewItem *item = _items[section];
        return item.rowCount;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_items.count > section) {
        _SSJReportFormsCurveSuspensionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kSSJReportFormsCurveSuspensionHeaderViewID];
        headerView.item = _items[section];
        return headerView;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_items.count > section) {
        SSJReportFormsCurveSuspensionViewItem *item = _items[section];
        if (item.title) {
            return _unitSpace;
        }
    }
    
    return 0;
}

#pragma mark - LazyLoading
- (_SSJReportFormsCurveSuspensionTableView *)tableView {
    if (!_tableView) {
        _tableView = [[_SSJReportFormsCurveSuspensionTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[_SSJReportFormsCurveSuspensionHeaderView class] forHeaderFooterViewReuseIdentifier:kSSJReportFormsCurveSuspensionHeaderViewID];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = _unitSpace;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        _tableView.userInteractionEnabled = NO;
    }
    return _tableView;
}

@end
