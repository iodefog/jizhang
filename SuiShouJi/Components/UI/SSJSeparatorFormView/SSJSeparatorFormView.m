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
    
    CGFloat verticalGap = (self.height - _topLab.height - _bottomLab.height) * 0.33;
    _topLab.top = verticalGap;
    _bottomLab.top = _topLab.bottom + verticalGap;
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

@interface SSJSeparatorFormView ()

@property (nonatomic, strong) NSMutableArray *cells;

@property (nonatomic, strong) NSMutableArray *rowSeparators;

@property (nonatomic, strong) NSMutableArray *cellSeparators;

@end

@implementation SSJSeparatorFormView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cells = [[NSMutableArray alloc] init];
        _rowSeparators = [[NSMutableArray alloc] init];
        _cellSeparators = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat rowHeight = self.height / _cells.count;
    for (NSUInteger rowIdx = 0; rowIdx < _cells.count; rowIdx ++) {
        
        NSArray *rowCells = _cells[rowIdx];
        CGFloat cellWidth = self.width / rowCells.count;
        
        if (rowIdx < _rowSeparators.count) {
            UIView *rowSeparator = _rowSeparators[rowIdx];
            rowSeparator.frame = CGRectMake(_horizontalSeparatorInset.left, (rowIdx + 1) * rowHeight, self.width - _horizontalSeparatorInset.left - _horizontalSeparatorInset.right, 1);
        }
        
        NSArray *cellSeparators = _cellSeparators[rowIdx];
        
        for (NSUInteger cellIdx = 0; cellIdx < rowCells.count; cellIdx ++) {
            SSJSeparatorFormViewCell *cell = rowCells[cellIdx];
            cell.frame = CGRectMake(cellWidth * cellIdx, rowHeight * rowIdx, cellWidth, rowHeight);
            
            if (cellSeparators.count > cellIdx) {
                UIView *cellSeparator = cellSeparators[cellIdx];
                cellSeparator.frame = CGRectMake((cellIdx + 1) * cellWidth, _horizontalSeparatorInset.top, 1, self.width - _horizontalSeparatorInset.top - _horizontalSeparatorInset.bottom);
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
    
    [_cells removeAllObjects];
    [_rowSeparators removeAllObjects];
    [_cellSeparators removeAllObjects];
    
    NSUInteger rowCount = [_dataSource numberOfRowsInSeparatorFormView:self];
    
    for (NSUInteger rowIdx = 0; rowIdx < rowCount; rowIdx ++) {
        
        NSUInteger cellCount = [_dataSource separatorFormView:self numberOfCellsInRow:rowIdx];
        NSMutableArray *rowCells = [NSMutableArray arrayWithCapacity:cellCount];
        
        if (rowIdx > 0) {
            UIView *rowSeparator = [[UIView alloc] init];
            rowSeparator.backgroundColor = _separatorColor;
            [_rowSeparators addObject:rowSeparator];
        }
        
        NSMutableArray *cellSeparators = [NSMutableArray arrayWithCapacity:cellCount];
        
        for (NSUInteger cellIndex = 0; cellIndex < cellCount; cellIndex ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellCount inSection:rowCount];
            SSJSeparatorFormViewCellItem *item = [_dataSource separatorFormView:self itemForCellAtIndex:indexPath];
            
            SSJSeparatorFormViewCell *cell = [[SSJSeparatorFormViewCell alloc] init];
            cell.item = item;
            [self addSubview:cell];
            [rowCells addObject:cell];
            
            if (cellIndex > 0) {
                UIView *cellSeparator = [[UIView alloc] init];
                cellSeparator.backgroundColor = _separatorColor;
                [cellSeparators addObject:cellSeparator];
            }
        }
        
        [_cellSeparators addObject:cellSeparators];
        
        [_cells addObject:rowCells];
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    if (!CGColorEqualToColor(_separatorColor.CGColor, separatorColor.CGColor)) {
        _separatorColor = separatorColor;
        
        for (UIView *separator in _rowSeparators) {
            separator.backgroundColor = _separatorColor;
        }
        
        for (UIView *separator in _cellSeparators) {
            separator.backgroundColor = _separatorColor;
        }
    }
}

- (void)setHorizontalSeparatorInset:(UIEdgeInsets)horizontalSeparatorInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_horizontalSeparatorInset, horizontalSeparatorInset)) {
        _horizontalSeparatorInset = horizontalSeparatorInset;
        [self setNeedsLayout];
    }
}

- (void)setVerticalSeparatorInset:(UIEdgeInsets)verticalSeparatorInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_verticalSeparatorInset, verticalSeparatorInset)) {
        _verticalSeparatorInset = verticalSeparatorInset;
        [self setNeedsLayout];
    }
}

@end
