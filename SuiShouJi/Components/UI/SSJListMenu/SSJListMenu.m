//
//  SSJListMenu.m
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJListMenu.h"
#import "SSJListMenuCell.h"

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
//        self.layer.borderColor = [UIColor redColor].CGColor;
//        self.layer.borderWidth = 1;
        
        _items = items;
        [self organiseCellItems];
        
        [self.layer addSublayer:self.outlineLayer];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    _tableView.frame = CGRectMake(0, 3, self.width, self.height - 3);
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
        
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.leftTop = point;
        
        [view ssj_showViewWithBackView:self backColor:[UIColor clearColor] alpha:1 target:self touchAction:@selector(tapBackgroundViewAction) animation:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
            self.top = point.y;
            self.left = point.x - scale * self.width;
        } timeInterval:0.25 fininshed:NULL];
        
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
        } timeInterval:0.25 fininshed:^(BOOL complation) {
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
        [_cellItems addObject:cellItem];
    }
}

- (CGFloat)vertexXWithShowPoint:(CGPoint)point inView:(UIView *)view {
    if (point.x < self.width * 0.5) {
        return point.x;
    } else if (point.x > view.width - self.width * 0.5) {
        return self.width - (view.width - point.x);
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
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        [_tableView ssj_clearExtendSeparator];
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    return _tableView;
}

- (CAShapeLayer *)outlineLayer {
    if (!_outlineLayer) {
        _outlineLayer = [CAShapeLayer layer];
        _outlineLayer.fillColor = _fillColor.CGColor;
        _outlineLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _outlineLayer.lineWidth = 0.5;
    }
    return _outlineLayer;
}

@end
