//
//  SSJEditCollectionView.m
//  SSRecordMakingDemo
//
//  Created by old lang on 16/5/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJEditableCollectionView.h"
#import "SSJViewAddition.h"

static const CGFloat kMaxSpeed = 100;

@interface SSJEditableCollectionView () <UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic) BOOL editing;

@property (nonatomic) BOOL moving;

@property (nonatomic, strong) NSIndexPath *currentMovedIndexPath;

@property (nonatomic, strong) NSIndexPath *originalMovedIndexPath;

@property (nonatomic, strong) UIImageView *movedCell;

@property (nonatomic) CGPoint touchPointInCell;

@property (nonatomic) CGPoint fixedPoint;

@property (nonatomic) BOOL shouldCheckIntersection;

@end

@implementation SSJEditableCollectionView

- (void)dealloc {
    [_panGesture removeObserver:self forKeyPath:@"state"];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        _shouldCheckIntersection = YES;
        
        _movedCellScale = 1;
        
        _movedCell = [[UIImageView alloc] init];
        _movedCell.hidden = YES;
        [self addSubview:_movedCell];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginEditingWhenLongPressBegin)];
        _longPressGesture.delegate = self;
        [self addGestureRecognizer:_longPressGesture];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditingWhenTapped)];
        _tapGesture.delegate = self;
        [self addGestureRecognizer:_tapGesture];
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(beginMoving)];
        _panGesture.delegate = self;
        [_panGesture addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
        [self addGestureRecognizer:_panGesture];
    }
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if (object == _panGesture && [keyPath isEqualToString:@"state"]) {
        UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
        if (state == UIGestureRecognizerStateEnded
            || state == UIGestureRecognizerStateFailed) {
            [self endMovingCell];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _tapGesture) {
        return _editing;
    } else if (gestureRecognizer == _panGesture) {
        return _moving;
    } /*else if (gestureRecognizer == _longPressGesture) {
        NSLog(@"state:%@", [self debugDescWithState:gestureRecognizer.state]);
    }*/
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == _longPressGesture && otherGestureRecognizer == _panGesture) {
        return YES;
    }
    return NO;
}

#pragma mark - UIResponder
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (_editing) {
        return;
    }
    
    if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        NSIndexPath *touchIndex = [self indexPathForItemAtPoint:touchPoint];
        if (touchIndex) {
            [_editDelegate collectionView:self didSelectItemAtIndexPath:touchIndex];
        }
    }
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
        if (_moving && _currentMovedIndexPath) {
            cell.hidden = [_currentMovedIndexPath compare:indexPath] == NSOrderedSame;
        } else {
            cell.hidden = NO;
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

#pragma mark - Event
- (void)beginEditingWhenLongPressBegin {
    _longPressGesture.enabled = NO;
//    if (_moving) {
//        return;
//    }
    
    CGPoint touchPoint = [_longPressGesture locationInView:self];
    NSIndexPath *touchIndexPath = [self indexPathForItemAtPoint:touchPoint];
    UICollectionViewCell *touchedCell = [self cellForItemAtIndexPath:touchIndexPath];
    
    if (!_editing) {
        BOOL couldBeginEdit = YES;
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:shouldBeginEditingWhenPressAtIndexPath:)]) {
            couldBeginEdit = [_editDelegate collectionView:self shouldBeginEditingWhenPressAtIndexPath:touchIndexPath];
        }
        
        if (couldBeginEdit) {
            _editing = YES;
            if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:didBeginEditingWhenPressAtIndexPath:)]) {
                [_editDelegate collectionView:self didBeginEditingWhenPressAtIndexPath:touchIndexPath];
            }
        }
    }
    
    if (!_moving && touchedCell) {
        
        BOOL shouldBeginMoving = YES;
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:shouldBeginMovingCellAtIndexPath:)]) {
            shouldBeginMoving = [_editDelegate collectionView:self shouldBeginMovingCellAtIndexPath:touchIndexPath];
        }
        
        if (!shouldBeginMoving) {
            return;
        }
        
        _moving = YES;
        
        _currentMovedIndexPath = touchIndexPath;
        _originalMovedIndexPath = _currentMovedIndexPath;
        
        _touchPointInCell = [_longPressGesture locationInView:touchedCell];
        
        _movedCell.frame = touchedCell.frame;
        [_movedCell setImage:[touchedCell.layer.presentationLayer ssj_takeScreenShotWithSize:_movedCell.size opaque:NO scale:0]];
        _movedCell.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            _movedCell.transform = CGAffineTransformMakeScale(_movedCellScale, _movedCellScale);
        }];
        touchedCell.hidden = YES;
    }
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

- (void)beginMoving {
    if (_moving) {
        CGPoint touchPoint = [_panGesture locationInView:self];
        _movedCell.leftTop = CGPointMake(touchPoint.x - _touchPointInCell.x, touchPoint.y - _touchPointInCell.y);
        
        [self checkIfHasIntersectantCells];
        _fixedPoint = CGPointMake(_movedCell.left, _movedCell.top - self.contentOffset.y);
        [self keepCurrentMovedCellVisible];
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
    if (!_editing) {
        _editing = YES;
        
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:didBeginEditingWhenPressAtIndexPath:)]) {
            [_editDelegate collectionView:self didBeginEditingWhenPressAtIndexPath:nil];
        }
    }
}

- (void)endEditing {
    [self endMovingCell];
    
    if (_editing) {
        _editing = NO;
        
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionViewDidEndEditing:)]) {
            [_editDelegate collectionViewDidEndEditing:self];
        }
    }
}

// 将当前移动的cell保持在可视范围内
- (void)keepCurrentMovedCellVisible {
    if (!_moving || !_currentMovedIndexPath || !_movedCell) {
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
    if (!_shouldCheckIntersection || !_currentMovedIndexPath || !_movedCell) {
        return;
    }
    
    NSIndexPath *topIndex = [self indexPathForItemAtPoint:CGPointMake(_movedCell.centerX, _movedCell.top)];
    if ([self moveCellToIndexPathIfNeeded:topIndex]) {
        return;
    }
    
    NSIndexPath *leftTopIndex = [self indexPathForItemAtPoint:_movedCell.leftTop];
    if ([self moveCellToIndexPathIfNeeded:leftTopIndex]) {
        return;
    }
    
    NSIndexPath *leftIndex = [self indexPathForItemAtPoint:CGPointMake(_movedCell.left, _movedCell.centerY)];
    if ([self moveCellToIndexPathIfNeeded:leftIndex]) {
        return;
    }
    
    NSIndexPath *leftBottomIndex = [self indexPathForItemAtPoint:_movedCell.leftBottom];
    if ([self moveCellToIndexPathIfNeeded:leftBottomIndex]) {
        return;
    }
    
    NSIndexPath *bottomIndex = [self indexPathForItemAtPoint:CGPointMake(_movedCell.centerX, _movedCell.bottom)];
    if ([self moveCellToIndexPathIfNeeded:bottomIndex]) {
        return;
    }
    
    NSIndexPath *bottomRightIndex = [self indexPathForItemAtPoint:_movedCell.rightBottom];
    if ([self moveCellToIndexPathIfNeeded:bottomRightIndex]) {
        return;
    }
    
    NSIndexPath *rightIndex = [self indexPathForItemAtPoint:CGPointMake(_movedCell.right, _movedCell.centerY)];
    if ([self moveCellToIndexPathIfNeeded:rightIndex]) {
        return;
    }
    
    NSIndexPath *rightTopIndex = [self indexPathForItemAtPoint:_movedCell.rightTop];
    if ([self moveCellToIndexPathIfNeeded:rightTopIndex]) {
        return;
    }
}

#pragma mark - Private
// 如果两个cell相交就交换它们
- (BOOL)moveCellToIndexPathIfNeeded:(NSIndexPath *)toIndexPath {
    if (!_currentMovedIndexPath || !toIndexPath) {
        return NO;
    }
    
    if ([toIndexPath compare:_currentMovedIndexPath] == NSOrderedSame) {
        return NO;
    }
    
    CGRect exchangeCellRegion1 = UIEdgeInsetsInsetRect(_movedCell.frame, _exchangeCellRegion);
    
    UICollectionViewCell *anotherCell = [self cellForItemAtIndexPath:toIndexPath];
    CGRect exchangeCellRegion2 = UIEdgeInsetsInsetRect(anotherCell.frame, _exchangeCellRegion);
    
    if (CGRectIntersectsRect(exchangeCellRegion1, exchangeCellRegion2)) {
        
        BOOL couldExchangeCell = YES;
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:shouldMoveCellAtIndexPath:toIndexPath:)]) {
            couldExchangeCell = [_editDelegate collectionView:self shouldMoveCellAtIndexPath:_currentMovedIndexPath toIndexPath:toIndexPath];
        }
        
        if (couldExchangeCell) {
            [self moveItemAtIndexPath:_currentMovedIndexPath toIndexPath:toIndexPath];
            
            if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:didMoveCellAtIndexPath:toIndexPath:)]) {
                [_editDelegate collectionView:self didMoveCellAtIndexPath:_currentMovedIndexPath toIndexPath:toIndexPath];
            }
            
            _currentMovedIndexPath = toIndexPath;
            
            _shouldCheckIntersection = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _shouldCheckIntersection = YES;
            });
            return YES;
        }
    }
    
    return NO;
}

- (void)endMovingCell {
    _longPressGesture.enabled = YES;
    if (!_moving || !_originalMovedIndexPath || !_currentMovedIndexPath) {
        return;
    }
    
    if ([_originalMovedIndexPath compare:_currentMovedIndexPath] != NSOrderedSame) {
        if (_editDelegate && [_editDelegate respondsToSelector:@selector(collectionView:didEndMovingCellFromIndexPath:toTargetIndexPath:)]) {
            [_editDelegate collectionView:self didEndMovingCellFromIndexPath:_originalMovedIndexPath toTargetIndexPath:_currentMovedIndexPath];
        }
    }
    
    _moving = NO;
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:_currentMovedIndexPath];
    [UIView animateWithDuration:0.25 animations:^{
        _movedCell.transform = CGAffineTransformMakeScale(1, 1);
        _movedCell.frame = attributes.frame;
    } completion:^(BOOL finished) {
        _movedCell.hidden = YES;
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:_currentMovedIndexPath];
        cell.hidden = NO;
        
        _currentMovedIndexPath = nil;
        _originalMovedIndexPath = nil;
    }];
}

- (NSString *)debugDescWithState:(UIGestureRecognizerState)state {
    switch (state) {
        case UIGestureRecognizerStatePossible:
            return @"UIGestureRecognizerStatePossible";
            break;
            
        case UIGestureRecognizerStateBegan:
            return @"UIGestureRecognizerStateBegan";
            break;
            
        case UIGestureRecognizerStateChanged:
            return @"UIGestureRecognizerStateChanged";
            break;
            
        case UIGestureRecognizerStateEnded:
            return @"UIGestureRecognizerStateEnded";
            break;
            
        case UIGestureRecognizerStateCancelled:
            return @"UIGestureRecognizerStateCancelled";
            break;
            
        case UIGestureRecognizerStateFailed:
            return @"UIGestureRecognizerStateFailed";
            break;
            
        default:
            break;
    }
}

@end
