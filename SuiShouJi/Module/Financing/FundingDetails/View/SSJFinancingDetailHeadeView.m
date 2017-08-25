//
//  SSJFinancingDetailHeadeView.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFinancingDetailHeadeView.h"

#import "SSJSeparatorFormView.h"

@implementation SSJFinancingDetailHeadeViewCellItem

+ (instancetype)itemWithTopTitle:(NSString *)topTitle
                     bottomTitle:(NSString *)bottomTitle
                   topTitleColor:(UIColor *)topTitleColor
                bottomTitleColor:(UIColor *)bottomTitleColor
                    topTitleFont:(UIFont *)topTitleFont
                 bottomTitleFont:(UIFont *)bottomTitleFont
                   contentInsets:(UIEdgeInsets)contentInsets {
    
    SSJFinancingDetailHeadeViewCellItem *item = [[SSJFinancingDetailHeadeViewCellItem alloc] init];
    item.topTitle = topTitle;
    item.bottomTitle = bottomTitle;
    item.topTitleColor = topTitleColor;
    item.bottomTitleColor = bottomTitleColor;
    item.topTitleFont = topTitleFont;
    item.bottomTitleFont = bottomTitleFont;
    item.contentInsets = contentInsets;
    return item;
}

@end

@interface SSJFinancingDetailHeadeViewCell : UIView

@property (nonatomic, strong) UILabel *topLab;

@property (nonatomic, strong) UILabel *bottomLab;

@property (nonatomic, strong) SSJFinancingDetailHeadeViewCellItem *item;

@property (nonatomic, strong) UIActivityIndicatorView *topIndicator;

@property (nonatomic, strong) UIActivityIndicatorView *bottomIndicator;

@property (nonatomic) UIEdgeInsets contentInsets;

@end

@implementation SSJFinancingDetailHeadeViewCell

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _topLab = [[UILabel alloc] init];
        _topLab.adjustsFontSizeToFitWidth = YES;
        _topLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_topLab];
        
        _bottomLab = [[UILabel alloc] init];
        _bottomLab.adjustsFontSizeToFitWidth = YES;
        _bottomLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bottomLab];
        
        _topIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_topIndicator];
        
        _bottomIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_bottomIndicator];
    }
    return self;
}

- (void)layoutSubviews {
    
    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
    _topLab.width = CGRectGetWidth(contentFrame);
    _bottomLab.width = CGRectGetWidth(contentFrame);
    _topLab.height = _item.topTitleFont.pointSize;
    _bottomLab.height = _item.bottomTitleFont.pointSize;
    
    CGFloat baseGap = (self.height - _topLab.height - _bottomLab.height) * 0.2;
    CGFloat top = baseGap * 2;
    _bottomLab.top = top;
    _topLab.top = _bottomLab.bottom + baseGap;
    _bottomLab.centerX = _topLab.centerX = self.width * 0.5;
    
    _topIndicator.center = _bottomLab.center;
    _bottomIndicator.center = _topLab.center;
}

- (void)setItem:(SSJFinancingDetailHeadeViewCellItem *)item {
    [self setNeedsLayout];
    
    [self removeObserver];
    _item = item;
    [self addObserver];
    [self updateAppearance];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

- (void)addObserver {
    [_item addObserver:self forKeyPath:@"topTitle" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"topTitleFont" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"topTitleColor" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"bottomTitle" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"bottomTitleFont" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"bottomTitleColor" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserver {
    [_item removeObserver:self forKeyPath:@"topTitle"];
    [_item removeObserver:self forKeyPath:@"topTitleFont"];
    [_item removeObserver:self forKeyPath:@"topTitleColor"];
    [_item removeObserver:self forKeyPath:@"bottomTitle"];
    [_item removeObserver:self forKeyPath:@"bottomTitleFont"];
    [_item removeObserver:self forKeyPath:@"bottomTitleColor"];
}

- (void)updateAppearance {
    _topLab.text = _item.topTitle;
    _topLab.font = _item.topTitleFont;
    _topLab.textColor = _item.topTitleColor;
    
    _bottomLab.text = _item.bottomTitle;
    _bottomLab.font = _item.bottomTitleFont;
    _bottomLab.textColor = _item.bottomTitleColor;
    
    self.contentInsets = _item.contentInsets;
}

@end

#define SEPARATOR_WIDTH (1 / [UIScreen mainScreen].scale)

@interface SSJFinancingDetailHeadeView ()

@property (nonatomic, strong) NSMutableArray<NSArray *> *cells;

@property (nonatomic, strong) NSMutableArray<UIView *> *horizontalSeparators;

@property (nonatomic, strong) NSMutableArray<NSArray *> *verticalSeparators;

@property(nonatomic, strong) CAGradientLayer *backLayer;

@end

@implementation SSJFinancingDetailHeadeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cells = [[NSMutableArray alloc] init];
        _horizontalSeparators = [[NSMutableArray alloc] init];
        _verticalSeparators = [[NSMutableArray alloc] init];
        [self.layer addSublayer:self.backLayer];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat rowHeight = self.height / _cells.count;
    for (NSUInteger rowIdx = 0; rowIdx < _cells.count; rowIdx ++) {
        
        NSArray *rowCells = _cells[rowIdx];
        CGFloat cellWidth = (self.width - 30) / rowCells.count;
        
        if (rowIdx < _horizontalSeparators.count) {
            UIView *rowSeparator = _horizontalSeparators[rowIdx];
            rowSeparator.frame = CGRectMake(_horizontalSeparatorInset.left, (rowIdx + 1) * rowHeight, self.width - _horizontalSeparatorInset.left - _horizontalSeparatorInset.right, SEPARATOR_WIDTH);
        }
        
        NSArray *cellSeparators = _verticalSeparators[rowIdx];
        
        for (NSUInteger cellIdx = 0; cellIdx < rowCells.count; cellIdx ++) {
            SSJFinancingDetailHeadeViewCell *cell = rowCells[cellIdx];
            cell.frame = CGRectMake(self.backLayer.left + cellWidth * cellIdx, rowHeight * rowIdx, cellWidth, rowHeight);
            
            if (cellSeparators.count > cellIdx) {
                UIView *cellSeparator = cellSeparators[cellIdx];
                CGFloat top = rowHeight * rowIdx;
                cellSeparator.frame = CGRectMake(self.backLayer.left + (cellIdx + 1) * cellWidth, top + _verticalSeparatorInset.top, SEPARATOR_WIDTH, rowHeight - _verticalSeparatorInset.top - _verticalSeparatorInset.bottom);
            }
        }
    }
    
}

- (void)reloadData {
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(numberOfRowsInSeparatorFormView:)]
        || ![_dataSource respondsToSelector:@selector(separatorFormView:numberOfCellsInRow:)]
        || ![_dataSource respondsToSelector:@selector(separatorFormView:itemForCellAtIndex:)]) {
        return;
    }
    
    [self setNeedsLayout];
    
    for (NSArray *rowCells in _cells) {
        [rowCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [_horizontalSeparators makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NSArray *cellSeparators in _verticalSeparators) {
        [cellSeparators makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [_cells removeAllObjects];
    [_horizontalSeparators removeAllObjects];
    [_verticalSeparators removeAllObjects];
    
    NSUInteger rowCount = [_dataSource numberOfRowsInSeparatorFormView:self];
    
    for (NSUInteger rowIdx = 0; rowIdx < rowCount; rowIdx ++) {
        
        NSUInteger cellCount = [_dataSource separatorFormView:self numberOfCellsInRow:rowIdx];
        NSMutableArray *rowCells = [NSMutableArray arrayWithCapacity:cellCount];
        
        if (rowIdx > 0) {
            UIView *rowSeparator = [[UIView alloc] init];
            rowSeparator.backgroundColor = _separatorColor;
            [self insertSubview:rowSeparator atIndex:100];
            [_horizontalSeparators addObject:rowSeparator];
        }
        
        NSMutableArray *cellSeparators = [NSMutableArray arrayWithCapacity:cellCount];
        
        for (NSUInteger cellIndex = 0; cellIndex < cellCount; cellIndex ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:rowIdx];
            SSJFinancingDetailHeadeViewCellItem *item = [_dataSource separatorFormView:self itemForCellAtIndex:indexPath];
            
            SSJFinancingDetailHeadeViewCell *cell = [[SSJFinancingDetailHeadeViewCell alloc] init];
            cell.item = item;
            [self addSubview:cell];
            [rowCells addObject:cell];
            
            if (cellIndex > 0) {
                UIView *cellSeparator = [[UIView alloc] init];
                cellSeparator.backgroundColor = _separatorColor;
                [self insertSubview:cellSeparator atIndex:100];
                [cellSeparators addObject:cellSeparator];
            }
        }
        
        [_verticalSeparators addObject:cellSeparators];
        
        [_cells addObject:rowCells];
        
        _backLayer.size = CGSizeMake(self.width - 30, self.height - 20);
        _backLayer.position = CGPointMake(self.width / 2, self.height / 2);
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            _backLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, _backLayer.width + 4, _backLayer.height + 4) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
        }
    }
}

- (CAGradientLayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [CAGradientLayer layer];
        _backLayer.startPoint = CGPointMake(0, 0.5);
        _backLayer.endPoint = CGPointMake(1, 0.5);
        _backLayer.cornerRadius = 8;
        _backLayer.shadowRadius = 10;
        _backLayer.shadowOpacity = 0.3;
    }
    return _backLayer;
}

- (void)showTopLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex {
    SSJFinancingDetailHeadeViewCell *cell = [self cellAtRowIndex:rowIndex cellIndex:cellIndex];
    if (cell) {
        cell.topLab.hidden = YES;
        [cell.topIndicator startAnimating];
    }
}

- (void)hideTopLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex {
    SSJFinancingDetailHeadeViewCell *cell = [self cellAtRowIndex:rowIndex cellIndex:cellIndex];
    if (cell) {
        cell.topLab.hidden = NO;
        [cell.topIndicator stopAnimating];
    }
}

- (void)showBottomLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex {
    SSJFinancingDetailHeadeViewCell *cell = [self cellAtRowIndex:rowIndex cellIndex:cellIndex];
    if (cell) {
        cell.bottomLab.hidden = NO;
        [cell.bottomIndicator startAnimating];
    }
}

- (void)hideBottomLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex {
    SSJFinancingDetailHeadeViewCell *cell = [self cellAtRowIndex:rowIndex cellIndex:cellIndex];
    if (cell) {
        cell.bottomLab.hidden = NO;
        [cell.bottomIndicator stopAnimating];
    }
}

- (SSJFinancingDetailHeadeViewCell *)cellAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex {
    if (_cells.count <= rowIndex) {
        SSJPRINT(@"rowIndex必须小于%d", (int)_cells.count);
        return nil;
    }
    
    NSArray *rowCells = _cells[rowIndex];
    if (rowCells.count <= cellIndex) {
        SSJPRINT(@"cellIndex必须小于%d", (int)rowCells.count);
        return nil;
    }
    
    SSJFinancingDetailHeadeViewCell *cell = rowCells[cellIndex];
    return cell;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    if (!CGColorEqualToColor(_separatorColor.CGColor, separatorColor.CGColor)) {
        _separatorColor = separatorColor;
        
        for (UIView *separator in _horizontalSeparators) {
            separator.backgroundColor = _separatorColor;
        }
        
        for (NSArray *separators in _verticalSeparators) {
            for (UIView *separator in separators) {
                separator.backgroundColor = _separatorColor;
            }
        }
    }
}

- (void)setHorizontalSeparatorInset:(UIEdgeInsets)horizontalSeparatorInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_horizontalSeparatorInset, horizontalSeparatorInset)) {
        _horizontalSeparatorInset = horizontalSeparatorInset;
        [self setNeedsLayout];
    }
}

- (void)setVerticalSeparatorInset:(UIEdgeInsets)verticalSeparatorInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_verticalSeparatorInset, verticalSeparatorInset)) {
        _verticalSeparatorInset = verticalSeparatorInset;
        [self setNeedsLayout];
    }
}

- (void)setColorItem:(SSJFinancingGradientColorItem *)colorItem {

    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:colorItem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:colorItem.endColor].CGColor];
        self.backLayer.shadowColor = [UIColor ssj_colorWithHex:colorItem.startColor].CGColor;
    } else {
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            self.backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:colorItem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:colorItem.endColor].CGColor];
            self.backLayer.shadowColor = [UIColor ssj_colorWithHex:colorItem.startColor].CGColor;
        } else {
            self.backLayer.colors = nil;
            if (SSJ_CURRENT_THEME.financingDetailHeaderColor.length) {
                self.backLayer.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha].CGColor;
            } else {
                self.backLayer.backgroundColor = [UIColor ssj_colorWithHex:colorItem.startColor].CGColor;
            }
        }
    }
}


- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}

@end
