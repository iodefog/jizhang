//
//  SSJEditCollectionView.m
//  SSRecordMakingDemo
//
//  Created by old lang on 16/5/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJEditableCollectionView.h"

static const CGFloat kMaxSpeed = 100;

@interface SSJEditableCollectionView () <UICollectionViewDataSource>

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic) BOOL editable;

@property (nonatomic) BOOL movable;

@property (nonatomic, strong) NSIndexPath *moveIndexPath;

@property (nonatomic, strong) UIImageView *movedCell;

@property (nonatomic) CGPoint touchPointInCell;

@property (nonatomic) CGPoint fixedPoint;

@property (nonatomic) BOOL shouldCheckIntersection;

@end

@implementation SSJEditableCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        _shouldCheckIntersection = YES;
        
        _movedCell = [[UIImageView alloc] init];
        _movedCell.hidden = YES;
        [self addSubview:_movedCell];
        
        _movedCell.layer.borderColor = [UIColor redColor].CGColor;
        _movedCell.layer.borderWidth = 1;
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginEditingWhenLongPressBegin)];
        [self addGestureRecognizer:_longPressGesture];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingWhenTapped)];
        _tapGesture.enabled = NO;
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_editDataSource && [_editDataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        return [_editDataSource collectionView:collectionView numberOfItemsInSection:section];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_editDataSource && [_editDataSource respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
        UICollectionViewCell *cell = [_editDataSource collectionView:collectionView cellForItemAtIndexPath:indexPath];
        if (_movable) {
            cell.hidden = [_moveIndexPath compare:indexPath] == NSOrderedSame;
        }
        return cell;
    }
    return [[UICollectionViewCell alloc] init];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_editDataSource && [_editDataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        return [_editDataSource numberOfSectionsInCollectionView:collectionView];
    }
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (_editDataSource && [_editDataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        return [_editDataSource collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    return [[UICollectionReusableView alloc] init];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_editDataSource && [_editDataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
        return [_editDataSource collectionView:collectionView canMoveItemAtIndexPath:indexPath];
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    if (_editDataSource && [_editDataSource respondsToSelector:@selector(collectionView:moveItemAtIndexPath:toIndexPath:)]) {
        [_editDataSource collectionView:collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"%@", self.delegate);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (_movable) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        _movedCell.leftTop = CGPointMake(touchPoint.x - _touchPointInCell.x, touchPoint.y - _touchPointInCell.y);
        
        [self checkIfHasIntersectantCells];
        _fixedPoint = CGPointMake(_movedCell.left, _movedCell.top - self.contentOffset.y);
        [self keepCurrentMovedCellVisible];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    _movable = NO;
    _longPressGesture.enabled = YES;
    self.scrollEnabled = YES;
    if (_editable && _moveIndexPath) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:_moveIndexPath];
        [UIView animateWithDuration:0.25 animations:^{
            _movedCell.transform = CGAffineTransformMakeScale(1, 1);
            _movedCell.frame = attributes.frame;
        } completion:^(BOOL finished) {
            _movedCell.hidden = YES;
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:_moveIndexPath];
            cell.hidden = NO;
        }];
    }
}

- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    _movable = NO;
    _longPressGesture.enabled = YES;
    self.scrollEnabled = YES;
    if (_editable && _moveIndexPath) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:_moveIndexPath];
        [UIView animateWithDuration:0.25 animations:^{
            _movedCell.transform = CGAffineTransformMakeScale(1, 1);
            _movedCell.frame = attributes.frame;
        } completion:^(BOOL finished) {
            _movedCell.hidden = YES;
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:_moveIndexPath];
            cell.hidden = NO;
        }];
    }
}

#pragma mark - Event
- (void)beginEditingWhenLongPressBegin {
    CGPoint touchPoint = [_longPressGesture locationInView:self];
    NSIndexPath *touchIndexPath = [self indexPathForItemAtPoint:touchPoint];
    
    BOOL couldBeginEdit = YES;
    if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:shouldBeginEditingWhenPressAtIndexPath:)]) {
        couldBeginEdit = [_editDelegate collectionView:self shouldBeginEditingWhenPressAtIndexPath:touchIndexPath];
    }
    
    if (!couldBeginEdit) {
        return;
    }
    
    if (!_movable) {
        CGPoint touchPoint = [_longPressGesture locationInView:self];
        _moveIndexPath = [self indexPathForItemAtPoint:touchPoint];
        
//        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:willMoveCellAtIndexPath:)]) {
//            [_editDelegate collectionView:self willMoveCellAtIndexPath:_moveIndexPath];
//        }
        
        UICollectionViewCell *movedCell = [self cellForItemAtIndexPath:_moveIndexPath];
        _touchPointInCell = [_longPressGesture locationInView:movedCell];
        
        _movedCell.frame = movedCell.frame;
        [_movedCell setImage:[movedCell.layer.presentationLayer ssj_takeScreenShotWithSize:_movedCell.size opaque:NO scale:0]];
        _movedCell.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            _movedCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
        movedCell.hidden = YES;
        _movable = YES;
        _longPressGesture.enabled = NO;
        self.scrollEnabled = NO;
    }
    
    [self beginEditingIfNeededWithTouchPressIndex:touchIndexPath];
}

- (void)reloadData {
    [super reloadData];
}

- (void)endEditingWhenTapped {
    BOOL shouldEndEditing = YES;
    if (_editDelegate && [_editDelegate respondsToSelector:@selector(shouldCollectionViewEndEditingWhenUserTapped:)]) {
        shouldEndEditing = [_editDelegate shouldCollectionViewEndEditingWhenUserTapped:self];
    }
    if (shouldEndEditing) {
        [self endEditing];
    }
}

#pragma mark - Public
- (void)setEditDataSource:(id<SSJEditableCollectionViewDataSource>)editDataSource {
    _editDataSource = editDataSource;
    self.dataSource = _editDataSource ? self : nil;
}

- (void)setEditDelegate:(id<SSJEditableCollectionViewDelegate>)editDelegate {
    _editDelegate = editDelegate;
    self.delegate = _editDelegate;
}

- (void)beginEditing {
    [self beginEditingIfNeededWithTouchPressIndex:nil];
}

- (void)endEditing {
    if (_editable) {
        _editable = NO;
        _tapGesture.enabled = NO;
        
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionViewDidEndEditing:)]) {
            [_editDelegate collectionViewDidEndEditing:self];
        }
    }
}

// 将当前移动的cell保持在可视范围内
- (void)keepCurrentMovedCellVisible {
    if (!_movable || !_moveIndexPath || !_movedCell) {
        return;
    }
    
    static BOOL shouldSetContentOffSet = YES;
    
    if (shouldSetContentOffSet) {
        shouldSetContentOffSet = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            shouldSetContentOffSet = YES;
        });
        
        CGFloat axisY = _fixedPoint.y + self.contentOffset.y;
        _movedCell.leftTop = CGPointMake(_fixedPoint.x, axisY);
        
        CGFloat speedFactor = 2;
        if (_movedCell.top < self.contentOffset.y && self.contentOffset.y > 0) {
            CGFloat speed = MIN(ABS(_fixedPoint.y) * speedFactor, kMaxSpeed);
            CGFloat contentOffSetY = MAX(self.contentOffset.y - speed, 0);
            [self setContentOffset:CGPointMake(self.contentOffset.x, contentOffSetY) animated:YES];
        } else if (_movedCell.bottom > self.contentOffset.y + self.height && self.contentOffset.y < self.contentSize.height - self.height) {
            CGFloat speed = (_fixedPoint.y + _movedCell.height - self.height) * speedFactor;
            speed = MIN(speed, kMaxSpeed);
            CGFloat contentOffSetY = self.contentOffset.y + speed;
            contentOffSetY = MIN(contentOffSetY, self.contentSize.height - self.height);
            [self setContentOffset:CGPointMake(self.contentOffset.x, contentOffSetY) animated:YES];
        }
    }
}

// 检测是否有与当前移动的cell相交的cell
- (void)checkIfHasIntersectantCells {
    if (!_shouldCheckIntersection || !_moveIndexPath || !_movedCell) {
        return;
    }
    
    NSIndexPath *topIndex = [self indexPathForItemAtPoint:CGPointMake(_movedCell.centerX, _movedCell.top)];
    if ([self exchangeCellsIfNeededWithIndexPath:topIndex]) {
        return;
    }
    
    NSIndexPath *leftTopIndex = [self indexPathForItemAtPoint:_movedCell.leftTop];
    if ([self exchangeCellsIfNeededWithIndexPath:leftTopIndex]) {
        return;
    }
    
    NSIndexPath *leftIndex = [self indexPathForItemAtPoint:CGPointMake(_movedCell.left, _movedCell.centerY)];
    if ([self exchangeCellsIfNeededWithIndexPath:leftIndex]) {
        return;
    }
    
    NSIndexPath *leftBottomIndex = [self indexPathForItemAtPoint:_movedCell.leftBottom];
    if ([self exchangeCellsIfNeededWithIndexPath:leftBottomIndex]) {
        return;
    }
    
    NSIndexPath *bottomIndex = [self indexPathForItemAtPoint:CGPointMake(_movedCell.centerX, _movedCell.bottom)];
    if ([self exchangeCellsIfNeededWithIndexPath:bottomIndex]) {
        return;
    }
    
    NSIndexPath *bottomRightIndex = [self indexPathForItemAtPoint:_movedCell.rightBottom];
    if ([self exchangeCellsIfNeededWithIndexPath:bottomRightIndex]) {
        return;
    }
    
    NSIndexPath *rightIndex = [self indexPathForItemAtPoint:CGPointMake(_movedCell.right, _movedCell.centerY)];
    if ([self exchangeCellsIfNeededWithIndexPath:rightIndex]) {
        return;
    }
    
    NSIndexPath *rightTopIndex = [self indexPathForItemAtPoint:_movedCell.rightTop];
    if ([self exchangeCellsIfNeededWithIndexPath:rightTopIndex]) {
        return;
    }
}

#pragma mark - Private
- (void)beginEditingIfNeededWithTouchPressIndex:(NSIndexPath *)indexPath {
    if (!_editable) {
        _editable = YES;
        _tapGesture.enabled = YES;
        
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:didBeginEditingWhenPressAtIndexPath:)]) {
            [_editDelegate collectionView:self didBeginEditingWhenPressAtIndexPath:indexPath];
        }
    }
}

// 如果两个cell相交就交换它们
- (BOOL)exchangeCellsIfNeededWithIndexPath:(NSIndexPath *)indexPath {
    if (!_moveIndexPath || !indexPath) {
        return NO;
    }
    
    if ([indexPath compare:_moveIndexPath] == NSOrderedSame) {
        return NO;
    }
    
    CGRect exchangeCellRegion1 = CGRectMake(_movedCell.left + _exchangeCellRegion.origin.x, _movedCell.top + _exchangeCellRegion.origin.y, _exchangeCellRegion.size.width, _exchangeCellRegion.size.height);
    
    UICollectionViewCell *anotherCell = [self cellForItemAtIndexPath:indexPath];
    CGRect exchangeCellRegion2 = CGRectMake(anotherCell.left + _exchangeCellRegion.origin.x, anotherCell.top + _exchangeCellRegion.origin.y, _exchangeCellRegion.size.width, _exchangeCellRegion.size.height);
    
    if (CGRectIntersectsRect(exchangeCellRegion1, exchangeCellRegion2)) {
        
        BOOL couldExchangeCell = YES;
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:shouldExchangeCellsWithIndexPath:anotherIndexPath:)]) {
            couldExchangeCell = [_editDelegate collectionView:self shouldExchangeCellsWithIndexPath:_moveIndexPath anotherIndexPath:indexPath];
        }
        
        if (couldExchangeCell) {
            [self moveItemAtIndexPath:_moveIndexPath toIndexPath:indexPath];
            
            if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:didExchangeCellsWithIndexPath:anotherIndexPath:)]) {
                [_editDelegate collectionView:self didExchangeCellsWithIndexPath:_moveIndexPath anotherIndexPath:indexPath];
            }
            
            _moveIndexPath = indexPath;
            
            _shouldCheckIntersection = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _shouldCheckIntersection = YES;
            });
            return YES;
        }
    }
    
    return NO;
}

@end
