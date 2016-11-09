//
//  SSJSeparatorFormView.m
//  SuiShouJi
//
//  Created by old lang on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSeparatorFormView.h"

@implementation SSJSeparatorFormViewCellItem

+ (instancetype)itemWithTopTitle:(NSString *)topTitle
                     bottomTitle:(NSString *)bottomTitle
                   topTitleColor:(UIColor *)topTitleColor
                bottomTitleColor:(UIColor *)bottomTitleColor
                    topTitleFont:(UIFont *)topTitleFont
                 bottomTitleFont:(UIFont *)bottomTitleFont {
    
    SSJSeparatorFormViewCellItem *item = [[SSJSeparatorFormViewCellItem alloc] init];
    item.topTitle = topTitle;
    item.bottomTitle = bottomTitle;
    item.topTitleColor = topTitleColor;
    item.bottomTitleColor = bottomTitleColor;
    item.topTitleFont = topTitleFont;
    item.bottomTitleFont = bottomTitleFont;
    return item;
}

@end

@interface SSJSeparatorFormViewCell : UIView

@property (nonatomic, strong) SSJSeparatorFormViewCellItem *item;

@end

@interface SSJSeparatorFormViewCell ()

@property (nonatomic, strong) UILabel *topLab;

@property (nonatomic, strong) UILabel *bottomLab;

@end

@implementation SSJSeparatorFormViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _topLab = [[UILabel alloc] init];
        [self addSubview:_topLab];
        
        _bottomLab = [[UILabel alloc] init];
        [self addSubview:_bottomLab];
    }
    return self;
}

- (void)layoutSubviews {
    [_topLab sizeToFit];
    [_bottomLab sizeToFit];
    
    CGFloat baseGap = (self.height - _topLab.height - _bottomLab.height) * 0.2;
    CGFloat top = baseGap * 2;
    _topLab.top = top;
    _bottomLab.top = _topLab.bottom + baseGap;
    _topLab.centerX = _bottomLab.centerX = self.width * 0.5;
}

- (void)setItem:(SSJSeparatorFormViewCellItem *)item {
    [self setNeedsLayout];
    _topLab.text = item.topTitle;
    _topLab.font = item.topTitleFont;
    _topLab.textColor = item.topTitleColor;
    
    _bottomLab.text = item.bottomTitle;
    _bottomLab.font = item.bottomTitleFont;
    _bottomLab.textColor = item.bottomTitleColor;
}

@end

#define SEPARATOR_WIDTH (1 / [UIScreen mainScreen].scale)

@interface SSJSeparatorFormView ()

@property (nonatomic, strong) NSMutableArray *cells;

@property (nonatomic, strong) NSMutableArray *horizontalSeparators;

@property (nonatomic, strong) NSMutableArray *verticalSeparators;

@end

@implementation SSJSeparatorFormView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cells = [[NSMutableArray alloc] init];
        _horizontalSeparators = [[NSMutableArray alloc] init];
        _verticalSeparators = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat rowHeight = self.height / _cells.count;
    for (NSUInteger rowIdx = 0; rowIdx < _cells.count; rowIdx ++) {
        
        NSArray *rowCells = _cells[rowIdx];
        CGFloat cellWidth = self.width / rowCells.count;
        
        if (rowIdx < _horizontalSeparators.count) {
            UIView *rowSeparator = _horizontalSeparators[rowIdx];
            rowSeparator.frame = CGRectMake(_horizontalSeparatorInset.left, (rowIdx + 1) * rowHeight, self.width - _horizontalSeparatorInset.left - _horizontalSeparatorInset.right, SEPARATOR_WIDTH);
        }
        
        NSArray *cellSeparators = _verticalSeparators[rowIdx];
        
        for (NSUInteger cellIdx = 0; cellIdx < rowCells.count; cellIdx ++) {
            SSJSeparatorFormViewCell *cell = rowCells[cellIdx];
            cell.frame = CGRectMake(cellWidth * cellIdx, rowHeight * rowIdx, cellWidth, rowHeight);
            
            if (cellSeparators.count > cellIdx) {
                UIView *cellSeparator = cellSeparators[cellIdx];
                CGFloat top = rowHeight * rowIdx;
                cellSeparator.frame = CGRectMake((cellIdx + 1) * cellWidth, top + _verticalSeparatorInset.top, SEPARATOR_WIDTH, rowHeight - _verticalSeparatorInset.top - _verticalSeparatorInset.bottom);
            }
        }
    }
    
}

- (void)reloadData {
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(numberOfRowsInSeparatorFormView:)]
        || ![_dataSource respondsToSelector:@selector(separatorFormView:numberOfCellsInRow:)
             ]
        || ![_dataSource respondsToSelector:@selector(separatorFormView:itemForCellAtIndex:)]) {
        return;
    }
    
    [self setNeedsLayout];
    
    [_cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_horizontalSeparators makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_verticalSeparators makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
            SSJSeparatorFormViewCellItem *item = [_dataSource separatorFormView:self itemForCellAtIndex:indexPath];
            
            SSJSeparatorFormViewCell *cell = [[SSJSeparatorFormViewCell alloc] init];
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
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    if (!CGColorEqualToColor(_separatorColor.CGColor, separatorColor.CGColor)) {
        _separatorColor = separatorColor;
        
        for (UIView *separator in _horizontalSeparators) {
            separator.backgroundColor = _separatorColor;
        }
        
        for (UIView *separator in _verticalSeparators) {
            separator.backgroundColor = _separatorColor;
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

@end
