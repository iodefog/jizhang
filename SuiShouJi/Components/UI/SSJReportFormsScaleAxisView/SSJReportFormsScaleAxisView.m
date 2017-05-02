//
//  SSJReportFormsScaleAxisView.m
//  SSJReportFormsScaleAxisView
//
//  Created by old lang on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsScaleAxisView.h"
#import "SSJReportFormsScaleAxisCell.h"

#pragma mark - 
#pragma mark - SSJReportFormsScaleAxixOutlineView

static const CGFloat kSubscriptWidth = 9;
static const CGFloat kSubscriptHeight = 4;

@interface SSJReportFormsScaleAxixOutlineView : UIView

/**
 底部角标的位置，取值范围[0~1]，默认0.5
 */
@property (nonatomic) CGFloat subscriptPosition;

/**
 实际的角标位置，以逻辑像素为单位，根据subscriptPosition的值计算出来
 */
@property (nonatomic, readonly) CGFloat actualSubscriptPosition;

@property (nonatomic, strong) CAShapeLayer *bottomLine;

@end

@implementation SSJReportFormsScaleAxixOutlineView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.bottomLine = [CAShapeLayer layer];
        self.bottomLine.lineWidth = 0.5;
        self.bottomLine.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:self.bottomLine];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updatePath];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updatePath];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.shapeLayer.fillColor = backgroundColor.CGColor;
}

- (void)setSubscriptPosition:(CGFloat)subscriptPosition {
    _subscriptPosition = subscriptPosition;
    [self updatePath];
}

- (CGFloat)actualSubscriptPosition {
    CGFloat startPointX = self.width * self.subscriptPosition - kSubscriptWidth * 0.5;
    startPointX = MAX(0, startPointX);
    return startPointX + kSubscriptWidth * 0.5;
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)[super layer];
}

- (void)updatePath {
    self.shapeLayer.path = [self outlinePath].CGPath;
    self.bottomLine.path = [self bottomLinePath].CGPath;
}

- (UIBezierPath *)outlinePath {
    if (CGRectIsEmpty(self.bounds)) {
        return nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(0, self.height)];
    [path appendPath:[self bottomLinePath]];
    [path addLineToPoint:CGPointMake(self.width, 0)];
    [path addLineToPoint:CGPointZero];
    return path;
}

- (UIBezierPath *)bottomLinePath {
    if (CGRectIsEmpty(self.bounds)) {
        return nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.height)];
    [self.subscriptPoints enumerateObjectsUsingBlock:^(NSNumber *pointValue, NSUInteger idx, BOOL * _Nonnull stop) {
        [path addLineToPoint:[pointValue CGPointValue]];
    }];
    [path addLineToPoint:CGPointMake(self.width, self.height)];
    return path;
}

- (NSArray<NSNumber *> *)subscriptPoints {
    CGFloat startPointX = self.width * self.subscriptPosition - kSubscriptWidth * 0.5;
    startPointX = MAX(0, startPointX);
    CGPoint subscriptPoint_1 = CGPointMake(startPointX, self.height);
    CGPoint subscriptPoint_2 = CGPointMake(startPointX + kSubscriptWidth * 0.5, self.height - kSubscriptHeight);
    CGPoint subscriptPoint_3 = CGPointMake(startPointX + kSubscriptWidth, self.height);
    return @[[NSValue valueWithCGPoint:subscriptPoint_1],
             [NSValue valueWithCGPoint:subscriptPoint_2],
             [NSValue valueWithCGPoint:subscriptPoint_3]];
}

@end

#pragma mark -
#pragma mark - SSJReportFormsScaleAxisView

static const CGFloat kItemWidth = 70;

static NSString *const kCellId = @"SSJReportFormsScaleAxisCell";
//static NSString *const kRedScaleColor = @"EB4A64";
//static NSString *const kGrayScaleColor = @"CCCCCC";

@interface SSJReportFormsScaleAxisView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) SSJReportFormsScaleAxixOutlineView *outlineView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIImageView *subscriptView;

@property (nonatomic, strong) NSArray<SSJReportFormsScaleAxisCellItem *> *items;

@end

@implementation SSJReportFormsScaleAxisView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.subscriptPosition = 0.5;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.outlineView];
        [self addSubview:self.collectionView];
        [self addSubview:self.subscriptView];
    }
    return self;
}

- (void)layoutSubviews {
    _outlineView.frame = self.bounds;
    _collectionView.frame = self.bounds;
    [self updateCollectionViewLayout];
    [self updateSubscriptPosition];
}

- (void)reloadData {
    if (!_delegate
        || ![_delegate respondsToSelector:@selector(numberOfAxisInScaleAxisView:)]
        || ![_delegate respondsToSelector:@selector(scaleAxisView:titleForAxisAtIndex:)]
        || ![_delegate respondsToSelector:@selector(scaleAxisView:heightForAxisAtIndex:)]) {
        return;
    }
    
    NSMutableArray *tmpItems = [[NSMutableArray alloc] init];
    self.selectedIndex = 0;
    NSUInteger axisCount = [_delegate numberOfAxisInScaleAxisView:self];
    for (NSUInteger idx = 0; idx < axisCount; idx ++) {
        SSJReportFormsScaleAxisCellItem *item = [[SSJReportFormsScaleAxisCellItem alloc] init];
        item.scaleValue = [_delegate scaleAxisView:self titleForAxisAtIndex:idx];
        item.scaleHeight = [_delegate scaleAxisView:self heightForAxisAtIndex:idx];
        item.scaleColor = self.selectedIndex == idx ? self.selectedScaleColor : self.scaleColor;
        item.scaleMarkShowed = self.scaleMarkShowed;
        [tmpItems addObject:item];
    }
    _items = [tmpItems copy];
    [_collectionView reloadData];
}

- (NSUInteger)asixCount {
    return _items.count;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (_items.count == 0) {
        return;
    }
    if (selectedIndex >= _items.count) {
        SSJPRINT(@"selectedIndex不能大于axisCount");
        return;
    }
    
    _selectedIndex = selectedIndex;
    [_collectionView setContentOffset:CGPointMake(kItemWidth * _selectedIndex, 0) animated:animated];
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    _outlineView.backgroundColor = fillColor;
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor {
    _bottomLineColor = bottomLineColor;
    _outlineView.bottomLine.strokeColor = bottomLineColor.CGColor;
}

- (void)setSubscriptPosition:(CGFloat)subscriptPosition {
    _subscriptPosition = subscriptPosition;
    self.outlineView.subscriptPosition = _subscriptPosition;
    [self updateCollectionViewLayout];
    [self updateSubscriptPosition];
}

- (void)setScaleMarkShowed:(BOOL)scaleMarkShowed {
    if (_scaleMarkShowed != scaleMarkShowed) {
        _scaleMarkShowed = scaleMarkShowed;
        [self updateItems];
    }
}

- (void)setScaleColor:(UIColor *)scaleColor {
    if (!CGColorEqualToColor(_scaleColor.CGColor, scaleColor.CGColor)) {
        _scaleColor = scaleColor;
        [self updateItems];
    }
}

- (void)setSelectedScaleColor:(UIColor *)selectedScaleColor {
    if (!CGColorEqualToColor(_selectedScaleColor.CGColor, selectedScaleColor.CGColor)) {
        _selectedScaleColor = selectedScaleColor;
        _subscriptView.tintColor = selectedScaleColor;
        [self updateItems];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormsScaleAxisCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.item = [_items ssj_safeObjectAtIndex:indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedIndex:indexPath.item animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(scaleAxisView:didSelectedScaleAxisAtIndex:)]) {
        [_delegate scaleAxisView:self didSelectedScaleAxisAtIndex:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        NSIndexPath *indexPath = [self indexPathAtSubscriptPosition];
        for (int idx = 0; idx < _items.count; idx ++) {
            SSJReportFormsScaleAxisCellItem *item = _items[idx];
            item.scaleColor = idx == indexPath.item ? _selectedScaleColor : _scaleColor;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _collectionView) {
        if (!decelerate) {
            NSIndexPath *indexPath = [self indexPathAtSubscriptPosition];
            if (!indexPath) {
                return;
            }
            
            [self setSelectedIndex:indexPath.item animated:YES];
            if (_delegate && [_delegate respondsToSelector:@selector(scaleAxisView:didSelectedScaleAxisAtIndex:)]) {
                [_delegate scaleAxisView:self didSelectedScaleAxisAtIndex:_selectedIndex];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        NSIndexPath *indexPath = [self indexPathAtSubscriptPosition];
        if (!indexPath) {
            return;
        }
        
        [self setSelectedIndex:indexPath.item animated:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(scaleAxisView:didSelectedScaleAxisAtIndex:)]) {
            [_delegate scaleAxisView:self didSelectedScaleAxisAtIndex:_selectedIndex];
        }
    }
}

#pragma mark - Private
- (nullable NSIndexPath *)indexPathAtSubscriptPosition {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    CGFloat subscriptAxisX = layout.sectionInset.left + layout.itemSize.width * 0.5 + _collectionView.contentOffset.x;
    return [_collectionView indexPathForItemAtPoint:CGPointMake(subscriptAxisX, 0)];
}

- (void)updateItems {
    [_items enumerateObjectsUsingBlock:^(SSJReportFormsScaleAxisCellItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.scaleColor = self.selectedIndex == idx ? self.selectedScaleColor : self.scaleColor;
        obj.scaleMarkShowed = self.scaleMarkShowed;
    }];
}

- (void)updateCollectionViewLayout {
    if (!CGRectIsEmpty(self.bounds) || !CGRectIsEmpty(self.collectionView.bounds)) {
        CGFloat left = self.outlineView.actualSubscriptPosition - kItemWidth * 0.5;
        CGFloat right = self.width - (self.outlineView.actualSubscriptPosition + kItemWidth * 0.5);
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        [layout invalidateLayout];
        layout.itemSize = CGSizeMake(kItemWidth, CGRectGetHeight(self.bounds));
        layout.sectionInset = UIEdgeInsetsMake(0, left, 0, right);
    }
}

- (void)updateSubscriptPosition {
    _subscriptView.bottom = self.height;
    _subscriptView.centerX = self.outlineView.actualSubscriptPosition;
}

- (UICollectionViewFlowLayout *)layout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    return layout;
}

- (SSJReportFormsScaleAxixOutlineView *)outlineView {
    if (!_outlineView) {
        _outlineView = [[SSJReportFormsScaleAxixOutlineView alloc] initWithFrame:self.bounds];
        _outlineView.subscriptPosition = self.subscriptPosition;
    }
    return _outlineView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[self layout]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[SSJReportFormsScaleAxisCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (UIImageView *)subscriptView {
    if (!_subscriptView) {
        _subscriptView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"reportForms_subscript"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _subscriptView;
}

@end
