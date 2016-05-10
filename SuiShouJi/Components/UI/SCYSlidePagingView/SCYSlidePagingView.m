//
//  SCYSlidePagingView.m
//  SCYSlidePagingControl
//
//  Created by old lang on 15-4-30.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SCYSlidePagingView.h"

@interface SCYSlidePagingView () <SCYSlidePagingHeaderViewDelegate> {
    struct {
        BOOL isLayouted;
        BOOL isAnimated;
        BOOL isPresetIndex;
        NSUInteger presetIndex;
    } _presetIndexFlags;
}

@property (nonatomic) NSUInteger numberOfPages;
@property (nonatomic, strong) NSMutableArray *contentViews;
@property (nonatomic) BOOL setOffsetFlag;

@end

@implementation SCYSlidePagingView



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _contentViews = [[NSMutableArray alloc] init];
        
        _headerView = [[SCYSlidePagingHeaderView alloc] init];
        _headerView.bounces = NO;
        _headerView.decelerationRate = UIScrollViewDecelerationRateFast;
        _headerView.titleColor = [UIColor lightGrayColor];
        _headerView.selectedTitleColor = [UIColor blueColor];
        _headerView.customDelegate = self;
        [self addSubview:_headerView];
        
        _bodyView = [[UIScrollView alloc] init];
        _bodyView.pagingEnabled = YES;
        _bodyView.delegate = self;
        _bodyView.showsHorizontalScrollIndicator = NO;
        _bodyView.showsVerticalScrollIndicator = NO;
        _bodyView.bounces = NO;
        [self addSubview:_bodyView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_numberOfPages == 0) {
        return;
    }
    
    _headerView.displayedButtonCount = MIN(_headerView.displayedButtonCount, _numberOfPages);
    _headerView.frame = CGRectMake(0, 0, self.width, 44);
    _bodyView.frame = CGRectMake(0, _headerView.bottom, self.width, self.height - _headerView.bottom);
    _bodyView.contentSize = CGSizeMake(_numberOfPages * _bodyView.width, _bodyView.height);
    for (int idx = 0; idx < _contentViews.count; idx ++) {
        UIView *contentView  = _contentViews[idx];
        contentView.frame = CGRectMake(idx * _bodyView.width, 0, _bodyView.width, _bodyView.height);
    }
    
    
    _presetIndexFlags.isLayouted = YES;
    if (_presetIndexFlags.isPresetIndex) {
        _presetIndexFlags.isPresetIndex = NO;
        [self setSelectedIndex:_presetIndexFlags.presetIndex animated:_presetIndexFlags.isAnimated];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview && _dataSource) {
        [self reload];
    }
}

- (void)setDataSource:(id<SCYSlidePagingViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        if (_dataSource && self.superview) {
            [self reload];
        }
    }
}

- (void)reload {
    _numberOfPages = 0;
    [_contentViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_contentViews removeAllObjects];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesInSlidePagingView:)]) {
        _numberOfPages = [_dataSource numberOfPagesInSlidePagingView:self];
    }
    
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:_numberOfPages];
    for (int idx = 0; idx < _numberOfPages; idx ++) {
        if (_dataSource && [_dataSource respondsToSelector:@selector(slidePagingView:headerTitleAtPagingIndex:)]) {
            NSString *title = [_dataSource slidePagingView:self headerTitleAtPagingIndex:idx];
            [titles addObject:title];
        }
        if (_dataSource && [_dataSource respondsToSelector:@selector(slidePagingView:contentViewAtPagingIndex:)]) {
            UIView *contentView = [_dataSource slidePagingView:self contentViewAtPagingIndex:idx];
            [_contentViews addObject:contentView];
            [_bodyView addSubview:contentView];
        }
    }
    _headerView.titles = titles;
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    
    if (!_presetIndexFlags.isLayouted) {
        _presetIndexFlags.isPresetIndex = YES;
        _presetIndexFlags.presetIndex = selectedIndex;
        _presetIndexFlags.isAnimated = animated;
        return;
    }
    
    if (selectedIndex >= _numberOfPages) {
        return;
    }
    
    if (_selectedIndex != selectedIndex) {
        BOOL shouldMove = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(slidePagingView:shouldMoveToPageAtIndex:)]) {
            shouldMove = [_delegate slidePagingView:self shouldMoveToPageAtIndex:selectedIndex];
        }
        
        if (shouldMove) {
            _selectedIndex = selectedIndex;
            if (_delegate && [_delegate respondsToSelector:@selector(slidePagingView:willMoveToPageAtIndex:)]) {
                [_delegate slidePagingView:self willMoveToPageAtIndex:selectedIndex];
            }
            
            [_headerView setSelectedIndex:selectedIndex animated:animated];
            [_bodyView setContentOffset:CGPointMake(_bodyView.width * selectedIndex, 0) animated:animated];

            if (!animated) {
                if (_delegate && [_delegate respondsToSelector:@selector(slidePagingView:didMoveToPageAtIndex:)]) {
                    [_delegate slidePagingView:self didMoveToPageAtIndex:_selectedIndex];
                }
            }
            
        }
    }
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView willSelectButtonAtIndex:(NSUInteger)index {
    _setOffsetFlag = YES;
    _selectedIndex = index;
    CGFloat contentOffsetX = index *_bodyView.width;
    [_bodyView setContentOffset:CGPointMake(contentOffsetX, 0) animated:YES];
}

- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    _setOffsetFlag = NO;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_bodyView == scrollView) {
        if (_bodyView.tracking || _bodyView.dragging || _bodyView.decelerating) {
            CGFloat tabOffsetX = _bodyView.contentOffset.x / _bodyView.contentSize.width * _headerView.contentSize.width;
            _headerView.tabView.centerX = _headerView.width / _numberOfPages * 0.5 + tabOffsetX;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_bodyView == scrollView) {
        if (_setOffsetFlag) {
            return;
        }
        
        NSUInteger index = _bodyView.contentOffset.x / _bodyView.width;
        if (_selectedIndex != index) {
            _selectedIndex = index;
            [_headerView setSelectedIndex:_selectedIndex animated:YES];
            
            if (_delegate && [_delegate respondsToSelector:@selector(slidePagingView:didMoveToPageAtIndex:)]) {
                [_delegate slidePagingView:self didMoveToPageAtIndex:_selectedIndex];
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(slidePagingView:didMoveToPageAtIndex:)]) {
        [_delegate slidePagingView:self didMoveToPageAtIndex:_selectedIndex];
    }
}

@end
