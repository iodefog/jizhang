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

static const CGFloat kTriangleHeight = 8;

static const CGFloat kCornerRadius = 2;

@interface SSJListMenu () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CAShapeLayer *outlineLayer;

@property (nonatomic, strong) NSMutableArray *cellItems;

@property (nonatomic, copy) void (^dismissHandle)(SSJListMenu *);

@property (nonatomic) CGPoint showPoint;

@property (nonatomic) UIEdgeInsets superViewInsets;

@end

@implementation SSJListMenu

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _selectedIndex = -1;
        _borderColor = [UIColor lightGrayColor];
        _fillColor = [UIColor whiteColor];
        _separatorColor = [UIColor lightGrayColor];
        _titleFont = [UIFont systemFontOfSize:16];
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

- (void)setBorderColor:(UIColor *)borderColor {
    if (!CGColorEqualToColor(_borderColor.CGColor, borderColor.CGColor)) {
        _borderColor = borderColor;
        _outlineLayer.strokeColor = _borderColor.CGColor;
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    _outlineLayer.fillColor = fillColor.CGColor;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    _tableView.separatorColor = _separatorColor;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_separatorInset, separatorInset)) {
        _separatorInset = separatorInset;
        _tableView.separatorInset = _separatorInset;
    }
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
    [self showInView:view atPoint:point superViewInsets:UIEdgeInsetsMake(0, 5, 0, 5) finishHandle:NULL dismissHandle:NULL];
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point superViewInsets:(UIEdgeInsets)insets finishHandle:(void(^)(SSJListMenu *listMenu))finishHandle dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle {
    if (!self.superview) {
        
        _showPoint = point;
        _superViewInsets = insets;
        CGFloat vertexX = [self vertexXWithShowPoint:_showPoint inView:view];
        
        _outlineLayer.path = [self drawPathWithVertexX:vertexX].CGPath;
        
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
        cellItem.titleFont = _titleFont;
        cellItem.gapBetweenImageAndTitle = _gapBetweenImageAndTitle;
        cellItem.contentAlignment = _contentAlignment;
        cellItem.contentInset = _contentInsets;
        cellItem.backgroundColor = item.backgroundColor;
        cellItem.attributeStr = item.attributedStr;

        if (idx == _selectedIndex) {
            cellItem.titleColor = item.selectedTitleColor ?: item.normalTitleColor;
            cellItem.imageColor = item.selectedImageColor ?: item.normalImageColor;
        } else {
            cellItem.titleColor = item.normalTitleColor;
            cellItem.imageColor = item.normalImageColor;
        }
        
        [_cellItems addObject:cellItem];
    }
    
    [_tableView reloadData];
}

- (CGFloat)vertexXWithShowPoint:(CGPoint)point inView:(UIView *)view {
    if (self.width * 0.5 > point.x) {
        return point.x - _superViewInsets.left;
    } else if (self.width * 0.5 > view.width - point.x) {
        return self.width - (view.width - point.x) + _superViewInsets.right;
    } else {
        return self.width * 0.5;
    }
}

- (UIBezierPath *)drawPathWithVertexX:(CGFloat)vertexX {
    UIBezierPath *path = [UIBezierPath bezierPath];
    //    path.lineJoinStyle = kCGLineJoinRound;
    [path moveToPoint:CGPointMake(vertexX - kTriangleHeight * 0.8, kTriangleHeight)];
    [path addLineToPoint:CGPointMake(vertexX, 0)];
    [path addLineToPoint:CGPointMake(vertexX + kTriangleHeight * 0.8, kTriangleHeight)];
    [path addLineToPoint:CGPointMake(self.width - kCornerRadius, kTriangleHeight)];
    [path addArcWithCenter:CGPointMake(self.width - kCornerRadius, kTriangleHeight + kCornerRadius) radius:kCornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(self.width, self.height - kCornerRadius)];
    [path addArcWithCenter:CGPointMake(self.width - kCornerRadius, self.height - kCornerRadius) radius:kCornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(kCornerRadius, self.height)];
    [path addArcWithCenter:CGPointMake(kCornerRadius, self.height - kCornerRadius) radius:kCornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, kTriangleHeight + kCornerRadius)];
    [path addArcWithCenter:CGPointMake(kCornerRadius, kTriangleHeight + kCornerRadius) radius:kCornerRadius startAngle:M_PI endAngle:M_PI * 1.5 clockwise:YES];
    [path closePath];
    
    return path;
}

- (void)updateCellItems {
    for (int i = 0; i < _cellItems.count; i ++) {
        SSJListMenuItem *item = _items[i];
        
        SSJListMenuCellItem *cellItem = _cellItems[i];
        cellItem.titleFont = _titleFont;
        cellItem.imageSize = _imageSize;
        cellItem.gapBetweenImageAndTitle = _gapBetweenImageAndTitle;
        cellItem.contentInset = _contentInsets;
        cellItem.contentAlignment = _contentAlignment;
        
        if (i == _selectedIndex) {
            cellItem.titleColor = item.selectedTitleColor ?: item.normalTitleColor;
            cellItem.imageColor = item.selectedImageColor ?: item.normalImageColor;
        } else {
            cellItem.titleColor = item.normalTitleColor;
            cellItem.imageColor = item.normalImageColor;
        }
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
        _tableView.bounces = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = _separatorColor;
        [_tableView ssj_clearExtendSeparator];
        [_tableView setSeparatorInset:_separatorInset];
    }
    return _tableView;
}

- (CAShapeLayer *)outlineLayer {
    if (!_outlineLayer) {
        _outlineLayer = [CAShapeLayer layer];
        _outlineLayer.fillColor = _fillColor.CGColor;
        _outlineLayer.strokeColor = _borderColor.CGColor;
        _outlineLayer.lineWidth = 1;
        _outlineLayer.shadowOpacity = 0.5;
        _outlineLayer.shadowOffset = CGSizeMake(0, 3);
        _outlineLayer.lineJoin = kCALineJoinRound;
    }
    return _outlineLayer;
}

@end


@implementation SSJListMenu (SSJTheme)

- (void)updateAppearance {
    self.fillColor = SSJ_SECONDARY_FILL_COLOR;
    self.borderColor = SSJ_CELL_SEPARATOR_COLOR;
    self.separatorColor = SSJ_CELL_SEPARATOR_COLOR;
    [self.cellItems makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:SSJ_MAIN_BACKGROUND_COLOR];
}

@end

