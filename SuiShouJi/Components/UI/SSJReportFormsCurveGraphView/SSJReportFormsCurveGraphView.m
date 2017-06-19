//
//  SSJReportFormsCurveGraphView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveGraphView.h"
#import "SSJReportFormsCurveGridView.h"
#import "SSJReportFormsCurveBalloonView.h"
#import "SSJReportFormsCurveCell.h"
#import "SSJReportFormsCurveDot.h"
#import "SSJReportFormsCurveSuspensionView.h"
#import "SSJReportFormsCurveView.h"

static NSString *const kSSJReportFormsCurveCellID = @"kSSJReportFormsCurveCellID";

@interface SSJReportFormsCurveGraphView () <UICollectionViewDataSource, UICollectionViewDelegate, SSJReportFormsCurveGridViewDataSource>

@property (nonatomic, strong) SSJReportFormsCurveGridView *gridView;

@property (nonatomic, strong) SSJReportFormsCurveBalloonView *ballonView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SSJReportFormsCurveSuspensionView *suspensionView;

@property (nonatomic, strong) NSMutableArray<SSJReportFormsCurveDot *> *dots;

@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;

@property (nonatomic, strong) NSMutableArray<UIColor *> *curveColors;

@property (nonatomic, strong) NSMutableArray<SSJReportFormsCurveSuspensionViewItem *> *suspensionItems;

@property (nonatomic, strong) NSMutableArray<NSArray *> *values;

@property (nonatomic, strong) NSMutableArray<SSJReportFormsCurveCellItem *> *items;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *visibleIndexs;

@property (nonatomic, strong) UIColor *defaultCurveColor;

@property (nonatomic) double maxValue;

@property (nonatomic) NSUInteger axisXCount;

@property (nonatomic) NSUInteger curveCount;

@property (nonatomic) NSUInteger currentIndex;

@property (nonatomic) BOOL userScrolled;

@property (nonatomic) BOOL hasReloaded;

@end

@implementation SSJReportFormsCurveGraphView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _unitAxisXLength = 50;
        _axisYCount = 6;
        _curveInsets = UIEdgeInsetsMake(46, 0, 56, 0);
        _scaleColor = [UIColor lightGrayColor];
        _scaleTitleFontSize = 10;
        _showCurveShadow = YES;
        _showOriginAndTerminalCurve = NO;
        _valueColor = [UIColor blackColor];
        _valueFontSize = 12;
        
        _curveCount = 1;
        _dots = [[NSMutableArray alloc] init];
        _labels = [[NSMutableArray alloc] init];
        _curveColors = [[NSMutableArray alloc] init];
        _suspensionItems = [[NSMutableArray alloc] init];
        _values = [[NSMutableArray alloc] init];
        _items = [[NSMutableArray alloc] init];
        _visibleIndexs = [[NSMutableArray alloc] init];
        _defaultCurveColor = [UIColor redColor];
        
        [self addSubview:self.gridView];
        [self addSubview:self.ballonView];
        [self addSubview:self.collectionView];
        [self addSubview:self.suspensionView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [self updateVisibleIndex];
    [self caculateCurvePoint];
    [self updateDotsAndLabelsPosition];
//    [self updateBallonHeight];
    
    [_gridView reloadData];
    
    for (SSJReportFormsCurveCellItem *item in _items) {
        item.scaleTop = self.height - _curveInsets.bottom;
    }
    
    _gridView.frame = self.bounds;
    
    _ballonView.top = 10;
    _ballonView.height = self.height - _curveInsets.bottom - _ballonView.top;
    _ballonView.centerX = self.width * 0.5;
    
    [_collectionView.collectionViewLayout invalidateLayout];
    _collectionView.frame = CGRectMake(0, 0, self.width, self.height - _curveInsets.bottom + _scaleTitleFontSize + 14);
    [self updateContentInset];
    
    _suspensionView.frame = CGRectMake(0, _collectionView.bottom, self.width, self.height - _collectionView.bottom);
    
    static BOOL firstLayout = YES;
    if (firstLayout) {
        firstLayout = NO;
        _userScrolled = NO;
        [self updateContentOffset:NO];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormsCurveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSSJReportFormsCurveCellID forIndexPath:indexPath];
    if (_items.count > indexPath.item) {
        SSJReportFormsCurveCellItem *item = [_items ssj_safeObjectAtIndex:indexPath.item];
        cell.cellItem = item;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < 0 || indexPath.item >= _items.count - 1) {
        return;
    }
    
    if (_currentIndex != indexPath.item) {
        for (SSJReportFormsCurveDot *dot in _dots) {
            dot.hidden = YES;
        }
        
        for (UILabel *label in _labels) {
            label.hidden = YES;
        }
    }
    
    _userScrolled = YES;
    _currentIndex = indexPath.item;
    [self updateVisibleIndex];
    [self updateBallonAndLablesTitle];
    [self updateDotsAndLabelsPosition];
//    [self updateBallonHeight];
    [self updateContentOffset:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (_items.count > indexPath.item) {
//        SSJReportFormsCurveCellItem *item = [_items objectAtIndex:indexPath.item];
//        ((SSJReportFormsCurveCell *)cell).cellItem = item;
//    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0 || indexPath.item == _items.count - 1) {
        return CGSizeMake(_unitAxisXLength * 0.5, _collectionView.height);
    } else {
        return CGSizeMake(_unitAxisXLength, _collectionView.height);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tracking || scrollView.dragging || scrollView.decelerating) {
        for (SSJReportFormsCurveDot *dot in _dots) {
            dot.hidden = YES;
        }
        for (UILabel *label in _labels) {
            label.hidden = YES;
        }
    }
    
    _suspensionView.contentOffsetX = _collectionView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSIndexPath *indexPath = [self indexPathForCenterX];
    if (indexPath && indexPath.item >= 0 && indexPath.item < _axisXCount) {
        
        _userScrolled = YES;
        _currentIndex = indexPath.item;
        [self updateVisibleIndex];
        [self updateBallonAndLablesTitle];
        [self updateDotsAndLabelsPosition];
//        [self updateBallonHeight];
        [self updateContentOffset:YES];
        
        if (_currentIndex == 0 || _currentIndex == _axisXCount - 1) {
            for (SSJReportFormsCurveDot *dot in _dots) {
                dot.hidden = !_showBalloon;
            }
            
            for (UILabel *label in _labels) {
                label.hidden = !_showBalloon;
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(curveGraphView:didScrollToAxisXIndex:)]) {
                [_delegate curveGraphView:self didScrollToAxisXIndex:_currentIndex];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        
        NSIndexPath *indexPath = [self indexPathForCenterX];
        if (indexPath && indexPath.item >= 0 && indexPath.item < _axisXCount) {
            _userScrolled = YES;
            _currentIndex = indexPath.item;
            [self updateVisibleIndex];
            [self updateBallonAndLablesTitle];
            [self updateDotsAndLabelsPosition];
//            [self updateBallonHeight];
            [self updateContentOffset:YES];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    for (SSJReportFormsCurveDot *dot in _dots) {
        dot.hidden = !_showBalloon;
    }
    
    for (UILabel *label in _labels) {
        label.hidden = !_showBalloon;
    }
    
    if (_userScrolled && _delegate && [_delegate respondsToSelector:@selector(curveGraphView:didScrollToAxisXIndex:)]) {
        [_delegate curveGraphView:self didScrollToAxisXIndex:_currentIndex];
    }
}

#pragma mark - SSJReportFormsCurveGridViewDataSource
- (NSUInteger)numberOfHorizontalLineInGridView:(SSJReportFormsCurveGridView *)gridView {
    return _axisYCount;
}

- (CGFloat)gridView:(SSJReportFormsCurveGridView *)gridView headerSpaceOnHorizontalLineAtIndex:(NSUInteger)index {
    if (index == 0) {
        return _curveInsets.top;
    } else {
        if (_axisYCount > 1) {
            return (self.height - _curveInsets.bottom - _curveInsets.top) / (_axisYCount - 1);
        } else if (_axisYCount == 1) {
            return self.height - _curveInsets.bottom;
        } else {
            return 0;
        }
    }
}

- (nullable NSString *)gridView:(SSJReportFormsCurveGridView *)gridView titleAtIndex:(NSUInteger)index {
    if (_axisYCount > 1) {
        double unitValue = _maxValue / (_axisYCount - 1);
        double value = _maxValue - unitValue * index;
        return [NSString stringWithFormat:@"%.2f", value];
    } else if (_axisYCount == 1) {
        return @"0.00";
    } else {
        return nil;
    }
}

#pragma mark - Pulic
- (void)setUnitAxisXLength:(CGFloat)unitAxisXLength {
    if (_unitAxisXLength != unitAxisXLength) {
        _unitAxisXLength = unitAxisXLength;
        _suspensionView.unitSpace = _unitAxisXLength;
        [self updateContentInset];
        [self updateContentOffset:NO];
        [self updateVisibleIndex];
        [self setNeedsLayout];
    }
}

- (void)setAxisYCount:(NSUInteger)axisYCount {
    if (_axisYCount != axisYCount) {
        _axisYCount = axisYCount;
        [_gridView reloadData];
    }
}

- (void)setCurveInsets:(UIEdgeInsets)curveInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_curveInsets, curveInsets)) {
        _curveInsets = curveInsets;
        [self setNeedsLayout];
    }
}

- (void)setScaleColor:(UIColor *)scaleColor {
    if (!CGColorEqualToColor(_scaleColor.CGColor, scaleColor.CGColor)) {
        _scaleColor = scaleColor;
        _gridView.titleColor = _scaleColor;
        _gridView.lineColor = _scaleColor;
        
        for (SSJReportFormsCurveCellItem *item in _items) {
            item.scaleColor = _scaleColor;
            item.titleColor = _scaleColor;
        }
    }
}

- (void)setScaleTitleFontSize:(CGFloat)scaleTitleFontSize {
    if (_scaleTitleFontSize != scaleTitleFontSize) {
        _scaleTitleFontSize = scaleTitleFontSize;
        _gridView.titleFont = [UIFont systemFontOfSize:_scaleTitleFontSize];
        [_items makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:_scaleTitleFontSize]];
    }
}

- (void)setShowBalloon:(BOOL)showBalloon {
    if (_showBalloon != showBalloon) {
        _showBalloon = showBalloon;
        
        for (SSJReportFormsCurveDot *dot in _dots) {
            dot.hidden = !_showBalloon;
        }
        
        for (UILabel *label in _labels) {
            label.hidden = !_showBalloon;
        }
        
        _ballonView.hidden = !_showBalloon;
        
        [self updateBallonAndLablesTitle];
    }
}

- (void)setBalloonTitleAttributes:(NSDictionary *)balloonTitleAttributes {
    _ballonView.titleFont = balloonTitleAttributes[NSFontAttributeName];
    _ballonView.titleColor = balloonTitleAttributes[NSForegroundColorAttributeName];
    _ballonView.ballonColor = balloonTitleAttributes[NSBackgroundColorAttributeName];
}

- (void)setShowValuePoint:(BOOL)showValuePoint {
    if (_showValuePoint != showValuePoint) {
        _showValuePoint = showValuePoint;
        
        if ([_dataSource respondsToSelector:@selector(curveGraphView:shouldShowValuePointForCurveAtIndex:axisXIndex:)]) {
            return;
        }
        
        for (SSJReportFormsCurveCellItem *cellItem in _items) {
            for (SSJReportFormsCurveViewItem *curveItem in cellItem.curveItems) {
                curveItem.showDot = _showValuePoint;
                curveItem.showValue = _showValuePoint;
            }
        }
    }
}

- (void)setValueColor:(UIColor *)valueColor {
    if (!CGColorEqualToColor(_valueColor.CGColor, valueColor.CGColor)) {
        _valueColor = valueColor;
        
        for (SSJReportFormsCurveCellItem *cellItem in _items) {
            for (SSJReportFormsCurveViewItem *curveItem in cellItem.curveItems) {
                curveItem.valueColor = _valueColor;
            }
        }
    }
}

- (void)setValueFontSize:(CGFloat)valueFontSize {
    if (_valueFontSize != valueFontSize) {
        _valueFontSize = valueFontSize;
        
        for (SSJReportFormsCurveCellItem *cellItem in _items) {
            for (SSJReportFormsCurveViewItem *curveItem in cellItem.curveItems) {
                curveItem.valueFont = [UIFont systemFontOfSize:_valueFontSize];
            }
        }
    }
}

- (void)setShowCurveShadow:(BOOL)showCurveShadow {
    if (_showCurveShadow != showCurveShadow) {
        _showCurveShadow = showCurveShadow;
        
        for (SSJReportFormsCurveCellItem *cellItem in _items) {
            for (SSJReportFormsCurveViewItem *curveItem in cellItem.curveItems) {
                curveItem.showShadow = _showCurveShadow;
            }
        }
    }
}

- (void)setShowOriginAndTerminalCurve:(BOOL)showOriginAndTerminalCurve {
    if (_showOriginAndTerminalCurve != showOriginAndTerminalCurve) {
        _showOriginAndTerminalCurve = showOriginAndTerminalCurve;
        
        for (int cellIdx = 0; cellIdx < _items.count; cellIdx ++) {
            
            SSJReportFormsCurveCellItem *cellItem = _items[cellIdx];
            
            for (SSJReportFormsCurveViewItem *curveItem in cellItem.curveItems) {
                
                if (_showOriginAndTerminalCurve) {
                    curveItem.showCurve = YES;
                    curveItem.showShadow = _showCurveShadow;
                } else {
                    if (cellIdx > 0 && cellIdx < _axisXCount) {
                        curveItem.showCurve = YES;
                        curveItem.showShadow = _showCurveShadow;
                    } else {
                        curveItem.showCurve = NO;
                        curveItem.showShadow = NO;
                    }
                }
            }
        }
    }
}

- (void)reloadData {
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(numberOfAxisXInCurveGraphView:)]
        || ![_dataSource respondsToSelector:@selector(curveGraphView:valueForCurveAtIndex:axisXIndex:)]) {
        return;
    }
    
    _hasReloaded = YES;
    _maxValue = 0;
    _currentIndex = 0;
    [self updateVisibleIndex];
    
    [_curveColors removeAllObjects];
    [_values removeAllObjects];
    [_items removeAllObjects];
    
    [_dots makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_dots removeAllObjects];
    
    [_labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_labels removeAllObjects];
    
    [_suspensionItems removeAllObjects];
    
    _ballonView.title = nil;
    
    _axisXCount = [_dataSource numberOfAxisXInCurveGraphView:self];
    if (_axisXCount == 0) {
        [_collectionView reloadData];
        _suspensionView.items = nil;
        _ballonView.hidden = YES;
        return;
    }
    
    if ([_dataSource respondsToSelector:@selector(numberOfCurveInCurveGraphView:)]) {
        _curveCount = [_dataSource numberOfCurveInCurveGraphView:self];
        if (_curveCount == 0) {
            [_collectionView reloadData];
            _suspensionView.items = nil;
            _ballonView.hidden = YES;
            return;
        }
    }
    
    _ballonView.hidden = !_showBalloon;
    
    [self updateVisibleIndex];
    
    [self updateContentOffset:NO];
    
    [self reorganiseCurveColors];
    
    [self reorganiseValues];
    
    [self reorganiseItems];
    
    [self reorganiseSuspensionViewItem];
    
    [self reorganiseDotsAndLabels];
    
    [self updateBallonAndLablesTitle];
    
    int approach = pow(10, (int)log10(_maxValue));
    double remainder = _maxValue / approach - (int)(_maxValue / approach);
    _maxValue = remainder == 0 ? _maxValue : ((int)(_maxValue / approach) + 1.0) * approach;
    
    [self caculateCurvePoint];
    [self updateDotsAndLabelsPosition];
//    [self updateBallonHeight];
    
    [_gridView reloadData];
    [_collectionView reloadData];
    _suspensionView.items = _suspensionItems;
}

- (void)scrollToAxisXAtIndex:(NSUInteger)index animated:(BOOL)animted {
    if (index >= _axisXCount) {
        NSLog(@"index必须小于%d", (int)_axisXCount);
        return;
    }
    
    if (animted && _currentIndex != index) {
        for (SSJReportFormsCurveDot *dot in _dots) {
            dot.hidden = YES;
        }
        
        for (UILabel *label in _labels) {
            label.hidden = YES;
        }
    }
    
    _userScrolled = NO;
    _currentIndex = index;
    [self updateVisibleIndex];
    [self updateBallonAndLablesTitle];
    [self updateDotsAndLabelsPosition];
//    [self updateBallonHeight];
    [self updateContentOffset:animted];
}

#pragma mark - Private
- (void)reorganiseCurveColors {
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        UIColor *curveColor = [_dataSource curveGraphView:self colorForCurveAtIndex:curveIdx];
        [_curveColors addObject:(curveColor ?: _defaultCurveColor)];
    }
}

- (void)reorganiseValues {
    NSMutableArray *originValues = [[NSMutableArray alloc] initWithCapacity:_curveCount];
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        [originValues addObject:@0];
    }
    [_values addObject:originValues];
    
    for (int axisXIdx = 0; axisXIdx < _axisXCount; axisXIdx ++) {
        NSMutableArray *valuesPerAxisX = [[NSMutableArray alloc] initWithCapacity:_curveCount];
        for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
            double value = [_dataSource curveGraphView:self valueForCurveAtIndex:curveIdx axisXIndex:axisXIdx];
            [valuesPerAxisX addObject:@(value)];
            _maxValue = MAX(value, _maxValue);
        }
        [_values addObject:valuesPerAxisX];
    }
    
    NSMutableArray *terminalValues = [[NSMutableArray alloc] initWithCapacity:_curveCount];
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        [terminalValues addObject:@0];
    }
    [_values addObject:terminalValues];
}

- (void)reorganiseItems {
    
    BOOL responsed = [_dataSource respondsToSelector:@selector(curveGraphView:shouldShowValuePointForCurveAtIndex:axisXIndex:)];
    
    for (int axisXIdx = 0; axisXIdx < _axisXCount + 1; axisXIdx ++) {
        
        SSJReportFormsCurveCellItem *cellItem = [[SSJReportFormsCurveCellItem alloc] init];
        
        NSMutableArray *curveItems = [[NSMutableArray alloc] initWithCapacity:_curveCount];
        
        if (axisXIdx < _axisXCount) {
            cellItem.title = [_dataSource curveGraphView:self titleAtAxisXIndex:axisXIdx];
            cellItem.titleFont = [UIFont systemFontOfSize:_scaleTitleFontSize];
            cellItem.titleColor = _scaleColor;
            cellItem.scaleColor = _scaleColor;
            cellItem.scaleTop = self.height - _curveInsets.bottom;
        }
        
        for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
            
            SSJReportFormsCurveViewItem *curveItem = [[SSJReportFormsCurveViewItem alloc] init];
            curveItem.curveColor = [_curveColors objectAtIndex:curveIdx];
            curveItem.curveWidth = 1;
            curveItem.shadowWidth = 3;
            curveItem.shadowOffset = CGSizeMake(0, 10);
            curveItem.shadowAlpha = 0.2;
            curveItem.valueColor = _valueColor;
            curveItem.valueFont = [UIFont systemFontOfSize:_valueFontSize];
            curveItem.dotColor = [_curveColors objectAtIndex:curveIdx];
            curveItem.dotAlpha = 0.3;
            
            if (_showOriginAndTerminalCurve) {
                curveItem.showCurve = YES;
                curveItem.showShadow = _showCurveShadow;
            } else {
                if (axisXIdx > 0 && axisXIdx < _axisXCount) {
                    curveItem.showCurve = YES;
                    curveItem.showShadow = _showCurveShadow;
                } else {
                    curveItem.showCurve = NO;
                    curveItem.showShadow = NO;
                }
            }
            
            if (axisXIdx < _axisXCount) {
                NSArray *valuesPerAxis = _values[axisXIdx + 1];
                double value = [valuesPerAxis[curveIdx] doubleValue];
                curveItem.value = [NSString stringWithFormat:@"%.2f", value];
                
                BOOL showValuePoint = _showValuePoint;
                if (responsed) {
                    showValuePoint = [_dataSource curveGraphView:self shouldShowValuePointForCurveAtIndex:curveIdx axisXIndex:axisXIdx];
                }
                
                curveItem.showValue = showValuePoint;
                curveItem.showDot = showValuePoint;
            }
            
            [curveItems addObject:curveItem];
        }
        
        cellItem.curveItems = curveItems;
        [_items addObject:cellItem];
    }
}

- (void)reorganiseDotsAndLabels {
    NSUInteger currentIndex = _currentIndex + 1;
    if (_values.count <= currentIndex) {
        return;
    }
    
    NSArray *values = _values[currentIndex];
    if (![values isKindOfClass:[NSArray class]]) {
        return;
    }
    
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        
        UIColor *color = _curveColors[curveIdx];
        
        double value = [values[curveIdx] doubleValue];
        CGFloat maxCurveHeight = (self.height - _curveInsets.top - _curveInsets.bottom);
        CGFloat y = self.height - _curveInsets.bottom;
        y = _maxValue == 0 ?: y - value / _maxValue * maxCurveHeight;
        
        SSJReportFormsCurveDot *dot = [[SSJReportFormsCurveDot alloc] init];
        dot.outerColorAlpha = 0.2;
        dot.dotColor = color;
        dot.center = CGPointMake(self.width * 0.5, y);
        dot.hidden = !_showBalloon;
        [self addSubview:dot];
        [_dots addObject:dot];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:_valueFontSize];
        label.textColor = color;
        label.hidden = !_showBalloon;
        [self addSubview:label];
        [_labels addObject:label];
    }
}

- (void)reorganiseSuspensionViewItem {
    if (![_dataSource respondsToSelector:@selector(curveGraphView:suspensionTitleAtAxisXIndex:)]) {
        return;
    }
    
    SSJReportFormsCurveSuspensionViewItem *item = nil;
    NSUInteger rowCount = 0;
    
    for (int axisXIdx = 0; axisXIdx < _axisXCount; axisXIdx ++) {
        
        NSString *suspensionTitle = [_dataSource curveGraphView:self suspensionTitleAtAxisXIndex:axisXIdx];
        
        if (suspensionTitle) {
            
            if (item) {
                item.rowCount = rowCount;
                [_suspensionItems addObject:item];
            }
            
            item = [[SSJReportFormsCurveSuspensionViewItem alloc] init];
            item.titleColor = _scaleColor;
            item.titleFont = [UIFont systemFontOfSize:_scaleTitleFontSize];
            item.title = suspensionTitle;
            rowCount = 0;
            
        } else {
            
            if (!item) {
                item = [[SSJReportFormsCurveSuspensionViewItem alloc] init];
                item.titleColor = _scaleColor;
                item.titleFont = [UIFont systemFontOfSize:_scaleTitleFontSize];
            }
            
            rowCount ++;
        }
    }
    
    if (item) {
        item.rowCount = rowCount;
        [_suspensionItems addObject:item];
    }
}

- (void)caculateCurvePoint {
    for (int cellIdx = 0; cellIdx < _items.count; cellIdx ++) {
        SSJReportFormsCurveCellItem *cellItem = _items[cellIdx];
        
        NSArray *startValues = _values[cellIdx];
        NSArray *endValues = _values[cellIdx + 1];
        
        SSJReportFormsCurveCellItem *preItem = nil;
        if (cellIdx > 0) {
            preItem = [_items ssj_safeObjectAtIndex:cellIdx - 1];
        }
        
        for (int curveIdx = 0; curveIdx < cellItem.curveItems.count; curveIdx ++) {
            
            CGFloat maxCurveHeight = self.height - _curveInsets.top - _curveInsets.bottom;
            
            double startValue = [startValues[curveIdx] doubleValue];
            double startPintY = self.height - (startValue / _maxValue) * maxCurveHeight - _curveInsets.bottom;
            
            double endValue = [endValues[curveIdx] doubleValue];
            CGFloat endPintY = self.height - _curveInsets.bottom;
            endPintY = _maxValue == 0 ?: endPintY - (endValue / _maxValue) * maxCurveHeight;
            
            CGFloat endPointX = (cellIdx == 0 || cellIdx == _items.count - 1) ? _unitAxisXLength * 0.5 : _unitAxisXLength;
            
            SSJReportFormsCurveViewItem *curveItem = cellItem.curveItems[curveIdx];
            curveItem.startPoint = CGPointMake(0, startPintY);
            curveItem.endPoint = CGPointMake(endPointX, endPintY);
            
            if (preItem) {
                SSJReportFormsCurveViewItem *preCurveItem = preItem.curveItems[curveIdx];
                if (curveItem.showValue && preCurveItem.showValue) {
                    [curveItem testOverlapPreItem:preCurveItem space:_unitAxisXLength];
                }
            }
        }
    }
}

- (void)updateContentOffset:(BOOL)animated {
    CGFloat offsetX = (_currentIndex + 0.5) * _unitAxisXLength - _collectionView.width * 0.5;
    [_collectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)updateContentInset {
    CGFloat horizontalInset = (_collectionView.width - _unitAxisXLength) * 0.5;
    _collectionView.contentInset = UIEdgeInsetsMake(0, horizontalInset, 0, horizontalInset);
}

- (void)updateDotsAndLabelsPosition {
    if (_maxValue == 0) {
        return;
    }
    
    NSUInteger currentIndex = _currentIndex + 1;
    if (_values.count <= currentIndex) {
        return;
    }
    
    NSArray *values = _values[currentIndex];
    if (![values isKindOfClass:[NSArray class]]) {
        return;
    }
    
    for (int idx = 0; idx < _dots.count; idx ++) {
        if (values.count <= idx) {
            return;
        }
        
        double value = [values[idx] doubleValue];
        CGFloat maxCurveHeight = (self.height - _curveInsets.top - _curveInsets.bottom);
        CGFloat y = self.height - _curveInsets.bottom - value / _maxValue * maxCurveHeight;
        
        SSJReportFormsCurveDot *dot = _dots[idx];
        dot.center = CGPointMake(self.width * 0.5, y);
        
        UILabel *label = _labels[idx];
        if (idx % 2 == 0) {
            label.left = dot.right + 2;
            label.centerY = dot.centerY;
        } else {
            label.right = dot.left - 2;
            label.centerY = dot.centerY;
        }
    }
}

/**
 根据当前的最大值调整中间气球的高度
 */
- (void)updateBallonHeight {
//    if (_maxValue == 0) {
//        return;
//    }
//    
//    NSUInteger currentIndex = _currentIndex + 1;
//    if (_values.count <= currentIndex) {
//        return;
//    }
//    
//    NSArray *values = _values[currentIndex];
//    if (![values isKindOfClass:[NSArray class]]) {
//        return;
//    }
//
//    CGFloat maxValue = [[values valueForKeyPath:@"@max.floatValue"] floatValue];
//    CGFloat maxCurveHeight = (self.height - _curveInsets.top - _curveInsets.bottom);
//    CGFloat y = self.height - _curveInsets.bottom - maxValue / _maxValue * maxCurveHeight;
//    
//    _ballonView.top = MAX(y - 55, 10);
//    _ballonView.height = self.height - _curveInsets.bottom - _ballonView.top;
//    _ballonView.centerX = self.width * 0.5;
}

- (void)updateBallonAndLablesTitle {
    if (!_showBalloon || !_hasReloaded) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(curveGraphView:titleForBallonAtAxisXIndex:)]) {
        _ballonView.title = [_delegate curveGraphView:self titleForBallonAtAxisXIndex:_currentIndex];
    }
    
    for (int curveIdx = 0; curveIdx < _curveCount; curveIdx ++) {
        
        if (_labels.count <= curveIdx) {
            break;
        }
        
        UILabel *label = _labels[curveIdx];
        
        if (_delegate && [_delegate respondsToSelector:@selector(curveGraphView:titleForBallonLabelAtCurveIndex:axisXIndex:)]) {
            label.text = [_delegate curveGraphView:self titleForBallonLabelAtCurveIndex:curveIdx axisXIndex:_currentIndex];
            [label sizeToFit];
        }
    }
}

- (void)updateVisibleIndex {
    
    if (_unitAxisXLength <= 0 || _axisXCount == 0) {
        return;
    }
    
    [_visibleIndexs removeAllObjects];
    
    int scope = self.width * 0.5 / _unitAxisXLength;
    int minIndex = MAX((int)_currentIndex - scope, 0);
    int maxIndex = MIN((int)_axisXCount - 1, (int)_currentIndex + scope);
    
    for (NSUInteger idx = minIndex; idx <= maxIndex; idx ++) {
        [_visibleIndexs addObject:@(idx)];
    }
    
//    NSArray *visibleIndex = [_collectionView indexPathsForVisibleItems];
//    for (NSIndexPath *indexPath in visibleIndex) {
//        if (indexPath.item < 0 || indexPath.item >= _items.count - 1) {
//            continue;
//        }
//        
//        UICollectionViewLayoutAttributes *layout = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
//        if (CGRectGetMaxX(layout.frame) >= 0 && CGRectGetMaxX(layout.frame) <= _collectionView.contentOffset.x + _collectionView.width) {
//            [_visibleIndexs addObject:@(indexPath.item)];
//        }
//    }
//    
//    [_visibleIndexs sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        if ([obj1 intValue] < [obj2 intValue]) {
//            return NSOrderedAscending;
//        } else if ([obj1 intValue] > [obj2 intValue]) {
//            return NSOrderedDescending;
//        } else {
//            return NSOrderedSame;
//        }
//    }];
}

- (NSIndexPath *)indexPathForCenterX {
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:CGPointMake(_collectionView.width * 0.5 + _collectionView.contentOffset.x, 0)];
    if (indexPath) {
        UICollectionViewLayoutAttributes *layout = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
        CGFloat centerX = _collectionView.width * 0.5 + _collectionView.contentOffset.x;
        if (centerX < CGRectGetMidX(layout.frame)) {
            indexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
        }
        return indexPath;
    }
    
    return nil;
}

#pragma mark - LazyLoading
- (SSJReportFormsCurveGridView *)gridView {
    if (!_gridView) {
        _gridView = [[SSJReportFormsCurveGridView alloc] init];
        _gridView.dataSource = self;
    }
    return _gridView;
}

- (SSJReportFormsCurveBalloonView *)ballonView {
    if (!_ballonView) {
        _ballonView = [[SSJReportFormsCurveBalloonView alloc] init];
        _ballonView.hidden = !_showBalloon;
    }
    return _ballonView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[SSJReportFormsCurveCell class] forCellWithReuseIdentifier:kSSJReportFormsCurveCellID];
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (SSJReportFormsCurveSuspensionView *)suspensionView {
    if (!_suspensionView) {
        _suspensionView = [[SSJReportFormsCurveSuspensionView alloc] init];
        _suspensionView.unitSpace = _unitAxisXLength;
    }
    return _suspensionView;
}

@end
