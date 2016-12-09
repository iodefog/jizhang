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

static const CGFloat kTriangleHeight = 8;

@interface SSJListMenu () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CAShapeLayer *outlineLayer;

@property (nonatomic, strong) NSMutableArray *cellItems;

@property (nonatomic, copy) void (^dismissHandle)(SSJListMenu *);

@property (nonatomic) CGPoint showPoint;

@end

@implementation SSJListMenu

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _selectedIndex = -1;
        _titleFontSize = 16;
        _rowHeight = 44;
        _minDisplayRowCount = 0;
        _maxDisplayRowCount = 0;
        _imageSize = CGSizeZero;
        _gapBetweenImageAndTitle = 10;
        _contentInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _contentAlignment = UIControlContentHorizontalAlignmentCenter;
        
        self.backgroundColor = [UIColor clearColor];
        [self.layer addSublayer:self.outlineLayer];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    _tableView.frame = CGRectMake(0, kTriangleHeight, self.width, self.height - kTriangleHeight);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat displayRowCount = MAX(_minDisplayRowCount, _items.count);
    if (_maxDisplayRowCount > 0) {
        displayRowCount = MIN(displayRowCount, _maxDisplayRowCount);
    }
    
//    return CGSizeMake(self.width, displayRowCount * _rowHeight + kTriangleHeight);
    return CGSizeMake(CGRectGetWidth(self.bounds), displayRowCount * _rowHeight + kTriangleHeight);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
}

#pragma mark - Public
- (void)setItems:(NSArray<SSJListMenuItem *> *)items {
    if (items && [_items isEqualToArray:items]) {
        return;
    }
    
    _items = items;
    _selectedIndex = -1;
    [self organiseCellItems];
    [self sizeToFit];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex >= _items.count) {
        SSJPRINT(@"selectedIndex大于数组items元素个数");
        return;
    }
    
    _selectedIndex = selectedIndex;
    [self updateCellItems];
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    if (CGColorEqualToColor(_normalTitleColor.CGColor, normalTitleColor.CGColor)) {
        return;
    }
    
    _normalTitleColor = normalTitleColor;
    [self updateCellItems];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    if (CGColorEqualToColor(_selectedTitleColor.CGColor, selectedTitleColor.CGColor)) {
        return;
    }
    
    _selectedTitleColor = selectedTitleColor;
    [self updateCellItems];
}

- (void)setNormalImageColor:(UIColor *)normalImageColor {
    if (CGColorEqualToColor(_normalImageColor.CGColor, normalImageColor.CGColor)) {
        return;
    }
    
    _normalImageColor = normalImageColor;
    [self updateCellItems];
}

- (void)setSelectedImageColor:(UIColor *)selectedImageColor {
    if (CGColorEqualToColor(_selectedImageColor.CGColor, selectedImageColor.CGColor)) {
        return;
    }
    
    _selectedImageColor = selectedImageColor;
    [self updateCellItems];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    _outlineLayer.fillColor = fillColor.CGColor;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    _tableView.separatorColor = _separatorColor;
}

- (void)setMinDisplayRowCount:(CGFloat)minDisplayRowCount {
    if (_minDisplayRowCount < 0) {
        SSJPRINT(@"minDisplayRowCount不能小于0");
        return;
    }
    
    if (_minDisplayRowCount != minDisplayRowCount) {
        _minDisplayRowCount = minDisplayRowCount;
        [self sizeToFit];
    }
    
}

- (void)setMaxDisplayRowCount:(CGFloat)maxDisplayRowCount {
    if (_maxDisplayRowCount < 0) {
        SSJPRINT(@"maxDisplayRowCount不能小于0");
        return;
    }
    
    if (_maxDisplayRowCount != maxDisplayRowCount) {
        _maxDisplayRowCount = maxDisplayRowCount;
        [self sizeToFit];
    }
}

- (void)setRowHeight:(CGFloat)rowHeight {
    if (rowHeight < 0) {
        SSJPRINT(@"rowHeight不能小于0");
        return;
    }
    
    if (_rowHeight != rowHeight) {
        _rowHeight = rowHeight;
        _tableView.rowHeight = _rowHeight;
        [self sizeToFit];
    }
}

- (void)setImageSize:(CGSize)imageSize {
    if (!CGSizeEqualToSize(_imageSize, imageSize)) {
        _imageSize = imageSize;
        [self updateCellItems];
    }
}

- (void)setGapBetweenImageAndTitle:(CGFloat)gapBetweenImageAndTitle {
    if (_gapBetweenImageAndTitle != gapBetweenImageAndTitle) {
        _gapBetweenImageAndTitle = gapBetweenImageAndTitle;
        [self updateCellItems];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
        _contentInsets = contentInsets;
        [self updateCellItems];
    }
}

- (void)setContentAlignment:(UIControlContentHorizontalAlignment)contentAlignment {
    if (_contentAlignment != contentAlignment) {
        _contentAlignment = contentAlignment;
        [self updateCellItems];
    }
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point {
    [self showInView:view atPoint:point finishHandle:NULL dismissHandle:NULL];
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle {
    [self showInView:view atPoint:point finishHandle:NULL dismissHandle:dismissHandle];
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point finishHandle:(void(^)(SSJListMenu *listMenu))finishHandle dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle {
    if (!self.superview) {
        
        _showPoint = point;
        CGFloat vertexX = [self vertexXWithShowPoint:_showPoint inView:view];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, kTriangleHeight, self.width, self.height - kTriangleHeight) cornerRadius:2];
        [path moveToPoint:CGPointMake(vertexX, 0)];
        [path addLineToPoint:CGPointMake(vertexX - kTriangleHeight * 0.8, kTriangleHeight)];
        [path addLineToPoint:CGPointMake(vertexX + kTriangleHeight * 0.8, kTriangleHeight)];
        [path closePath];
        
        _outlineLayer.path = path.CGPath;
        
        CGFloat scale = vertexX / self.width;
        
        _tableView.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.leftTop = point;
        
        [view ssj_showViewWithBackView:self backColor:[UIColor clearColor] alpha:1 target:self touchAction:@selector(tapBackgroundViewAction) animation:^{
            self.transform = CGAffineTransformIdentity;
            self.top = point.y;
            self.left = point.x - scale * self.width;
        } timeInterval:kDuration fininshed:^(BOOL finished) {
            [_tableView reloadData];
            [UIView animateWithDuration:kDuration animations:^{
                _tableView.alpha = 1;
                if (finishHandle) {
                    finishHandle(self);
                }
            }];
        }];
        
        [self setNeedsLayout];
        
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
            self.transform = CGAffineTransformIdentity;
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
    
    [_cellItems removeAllObjects];
    
    for (int idx = 0; idx < _items.count; idx ++) {
        SSJListMenuItem *item = _items[idx];
        SSJListMenuCellItem *cellItem = [[SSJListMenuCellItem alloc] init];
        cellItem.imageName = item.imageName;
        cellItem.title = item.title;
        cellItem.titleColor = idx == _selectedIndex ? _normalTitleColor : _selectedTitleColor;
        cellItem.titleFont = [UIFont systemFontOfSize:_titleFontSize];
        cellItem.gapBetweenImageAndTitle = _gapBetweenImageAndTitle;
        cellItem.contentAlignment = _contentAlignment;
        cellItem.contentInset = _contentInsets;
        [_cellItems addObject:cellItem];
    }
    
    [_tableView reloadData];
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

- (void)updateCellItems {
    UIColor *selectedColor = _selectedTitleColor ?: _normalTitleColor;
    UIColor *selectedImageColor = _selectedImageColor ?: _normalImageColor;
    
    for (int i = 0; i < _cellItems.count; i ++) {
        SSJListMenuCellItem *cellItem = _cellItems[i];
        cellItem.titleColor = i == _selectedIndex ? selectedColor : _normalTitleColor;
        cellItem.imageColor = i == _selectedIndex ? selectedImageColor : _normalImageColor;
        cellItem.titleFont = [UIFont systemFontOfSize:_titleFontSize];
        cellItem.imageSize = _imageSize;
        cellItem.gapBetweenImageAndTitle = _gapBetweenImageAndTitle;
        cellItem.contentInset = _contentInsets;
        cellItem.contentAlignment = _contentAlignment;
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
