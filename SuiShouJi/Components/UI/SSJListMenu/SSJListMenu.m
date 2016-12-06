//
//  SSJListMenu.m
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJListMenu.h"
#import "SSJListMenuCell.h"

static const NSTimeInterval kDuration = 0.2;

static const CGFloat kGap = 5;

@interface SSJListMenu () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CAShapeLayer *outlineLayer;

@property (nonatomic, strong) NSMutableArray *cellItems;

@property (nonatomic, copy) void (^dismissHandle)(SSJListMenu *);

@property (nonatomic) CGPoint showPoint;

@end

@implementation SSJListMenu

- (instancetype)initWithItems:(NSArray *)items {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _titleFontSize = 16;
        _displayRowCount = 2;
        
        _items = items;
        [self organiseCellItems];
        
        [self.layer addSublayer:self.outlineLayer];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    _tableView.frame = CGRectMake(0, 3, self.width, self.height - 3);
    _tableView.rowHeight = _tableView.height / _displayRowCount;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= _items.count) {
        SSJPRINT(@"selectedIndex大于数组items元素个数");
        return;
    }
    
    _selectedIndex = selectedIndex;
    for (int i = 0; i < _cellItems.count; i ++) {
        SSJListMenuCellItem *cellItem = _cellItems[i];
        cellItem.titleColor = i == _selectedIndex ? _selectedTitleColor : _normalTitleColor;
    }
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    if (CGColorEqualToColor(_normalTitleColor.CGColor, normalTitleColor.CGColor)) {
        return;
    }
    
    _normalTitleColor = normalTitleColor;
    for (int i = 0; i < _cellItems.count; i ++) {
        SSJListMenuCellItem *cellItem = _cellItems[i];
        cellItem.titleColor = i == _selectedIndex ? _selectedTitleColor : _normalTitleColor;
    }
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    if (CGColorEqualToColor(_selectedTitleColor.CGColor, selectedTitleColor.CGColor)) {
        return;
    }
    
    _selectedTitleColor = selectedTitleColor;
    for (int i = 0; i < _cellItems.count; i ++) {
        SSJListMenuCellItem *cellItem = _cellItems[i];
        cellItem.titleColor = i == _selectedIndex ? _selectedTitleColor : _normalTitleColor;
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.outlineLayer.fillColor = fillColor.CGColor;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    _tableView.separatorColor = _separatorColor;
}

- (void)setImageColor:(UIColor *)imageColor {
    if (CGColorEqualToColor(_imageColor.CGColor, imageColor.CGColor)) {
        return;
    }
    
    _imageColor = imageColor;
    for (int i = 0; i < _cellItems.count; i ++) {
        SSJListMenuCellItem *cellItem = _cellItems[i];
        cellItem.imageColor = _imageColor;
    }
}

- (void)setDisplayRowCount:(CGFloat)displayRowCount {
    if (displayRowCount <= 0) {
        SSJPRINT(@"displayRowCount必须大于0");
    }
    [self setNeedsLayout];
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point {
    [self showInView:view atPoint:point dismissHandle:NULL];
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle {
    if (!self.superview) {
        
        _showPoint = point;
        CGFloat vertexX = [self vertexXWithShowPoint:_showPoint inView:view];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 3, self.width, self.height - 3) cornerRadius:2];
        [path moveToPoint:CGPointMake(vertexX, 0)];
        [path addLineToPoint:CGPointMake(vertexX - 3, 3)];
        [path addLineToPoint:CGPointMake(vertexX + 3, 3)];
        [path closePath];
        
        self.outlineLayer.path = path.CGPath;
        
        CGFloat scale = vertexX / self.width;
        
        _tableView.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.leftTop = point;
        
        [view ssj_showViewWithBackView:self backColor:[UIColor clearColor] alpha:1 target:self touchAction:@selector(tapBackgroundViewAction) animation:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
            self.top = point.y;
            self.left = point.x - scale * self.width;
        } timeInterval:kDuration fininshed:^(BOOL finished) {
            [_tableView reloadData];
            [UIView animateWithDuration:kDuration animations:^{
                _tableView.alpha = 1;
            }];
        }];
        
        _dismissHandle = dismissHandle;
    }
}

- (void)dismiss {
    if (self.superview) {
        
        CGFloat vertexX = [self vertexXWithShowPoint:_showPoint inView:self.superview];
        CGFloat scale = vertexX / self.width;
        
        [self.superview ssj_hideBackViewForView:self animation:^{
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.top = _showPoint.y;
            self.left = _showPoint.x - scale * self.width;
        } timeInterval:kDuration fininshed:^(BOOL complation) {
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
}

#pragma mark - Action
- (void)tapBackgroundViewAction {
    [self dismiss];
    if (_dismissHandle) {
        _dismissHandle(self);
        _dismissHandle = NULL;
    }
}

#pragma mark - Private
- (void)organiseCellItems {
    if (!_cellItems) {
        _cellItems = [NSMutableArray arrayWithCapacity:_items.count];
    }
    
    for (SSJListMenuItem *item in _items) {
        SSJListMenuCellItem *cellItem = [[SSJListMenuCellItem alloc] init];
        cellItem.imageName = item.imageName;
        cellItem.title = item.title;
        cellItem.titleColor = _normalTitleColor;
        cellItem.titleFont = [UIFont systemFontOfSize:_titleFontSize];
        [_cellItems addObject:cellItem];
    }
}

- (CGFloat)vertexXWithShowPoint:(CGPoint)point inView:(UIView *)view {
    if (point.x < self.width * 0.5) {
        return point.x - kGap;
    } else if (point.x > view.width - self.width * 0.5) {
        return self.width - (view.width - point.x) + kGap;
    } else {
        return self.width * 0.5;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    SSJListMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJListMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.cellItem = [_cellItems ssj_safeObjectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndex = indexPath.row;
    
    [self dismiss];
    if (_dismissHandle) {
        _dismissHandle(self);
        _dismissHandle = NULL;
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = _separatorColor;
        [_tableView ssj_clearExtendSeparator];
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    return _tableView;
}

- (CAShapeLayer *)outlineLayer {
    if (!_outlineLayer) {
        _outlineLayer = [CAShapeLayer layer];
        _outlineLayer.fillColor = _fillColor.CGColor;
        _outlineLayer.shadowOpacity = 0.5;
        _outlineLayer.shadowOffset = CGSizeMake(0, 3);
    }
    return _outlineLayer;
}

@end
