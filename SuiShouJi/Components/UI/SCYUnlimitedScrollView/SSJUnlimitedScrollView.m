//
//  SSJUnlimitedScrollView.m
//  MoneyMore
//
//  Created by old lang on 15/7/14.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJUnlimitedScrollView.h"

static const NSUInteger kContentCount = 3;

@interface SSJUnlimitedScrollView () <UIScrollViewDelegate> {
    struct {
        unsigned int numberOfPagesFlag : 1;
        unsigned int subViewAtPageIndexFlag : 1;
        unsigned int didScrollFlag : 1;
    } _protocolFlags;
}

@property (nonatomic, strong) UIScrollView *scrollView;             //
@property (nonatomic, strong) NSMutableArray *subViews;             // 所有的子视图
@property (nonatomic, strong) NSMutableArray *displayedSubViews;    // 显示的子视图（只有3个，上一个、当前、下一个）

@end

@implementation SSJUnlimitedScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _subViews = [@[] mutableCopy];
        _displayedSubViews = [[NSMutableArray alloc] initWithCapacity:kContentCount];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    if (_subViews.count > 1) {
        _scrollView.contentSize = CGSizeMake(_scrollView.width * kContentCount, _scrollView.height);
        _scrollView.contentOffset = CGPointMake(_scrollView.width, 0);
    } else {
        _scrollView.contentSize = _scrollView.size;
        _scrollView.contentOffset = CGPointMake(0, 0);
    }
    
    for (int idx = 0; idx < _displayedSubViews.count; idx ++) {
        UIView *subView = _displayedSubViews[idx];
        subView.frame = CGRectMake(idx * _scrollView.width, 0, _scrollView.width, _scrollView.height);
    }
}

- (void)setDataSource:(id<SSJUnlimitedScrollViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        _protocolFlags.numberOfPagesFlag = (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)]);
        _protocolFlags.subViewAtPageIndexFlag = (_dataSource && [_dataSource respondsToSelector:@selector(scrollView:subViewAtPageIndex:)]);
        [self reloadSubViews];
    }
}

- (void)setDelegate:(id<SSJUnlimitedScrollViewDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        _protocolFlags.didScrollFlag = (_delegate && [_delegate respondsToSelector:@selector(scrollView:didScrollAtPageIndex:)]);
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_protocolFlags.numberOfPagesFlag &&
        _protocolFlags.subViewAtPageIndexFlag &&
        currentIndex >= [_subViews count]) {
        SSJPRINT(@"<<< 警告！currentIndex超出数组范围 %@ %@ >>>",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        return;
    }
    
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        if (_protocolFlags.numberOfPagesFlag && _protocolFlags.subViewAtPageIndexFlag) {
            [self reloadDisplayedSubViews];
        }
    }
}

- (void)scrollToNextPage {
    if (self.subViews.count > 1) {
        [self.scrollView setContentOffset:CGPointMake(self.width * 2, 0) animated:YES];
    }
}

- (void)scrollToPreviousPage {
    if (self.subViews.count > 1) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

//  重载子视图
- (void)reloadSubViews {
    [_subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_subViews removeAllObjects];
    
    NSUInteger numberOfPages = 0;
    if (_protocolFlags.numberOfPagesFlag) {
        numberOfPages = [_dataSource numberOfPagesInScrollView:self];
        if (numberOfPages <= 1) {
            _scrollView.contentSize = _scrollView.size;
            _scrollView.contentOffset = CGPointMake(0, 0);
        }
    }
    
    for (NSUInteger idx = 0; idx < numberOfPages; idx ++) {
        if (_protocolFlags.subViewAtPageIndexFlag) {
            UIView *subView = [_dataSource scrollView:self subViewAtPageIndex:idx];
            if (subView) {
                [_subViews addObject:subView];
            }
        }
    }
    
    [self reloadDisplayedSubViews];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_displayedSubViews.count == 2) {
        if (scrollView.contentOffset.x < scrollView.width) {
            UIView *preSubView = _displayedSubViews[0];
            preSubView.left = 0;
        } else if (scrollView.contentOffset.x > scrollView.width) {
            UIView *preSubView = _displayedSubViews[0];
            preSubView.left = _scrollView.width * 2;
        }
    }
    
    if (scrollView.contentOffset.x <= 0) {
        scrollView.contentOffset = CGPointMake(scrollView.width, 0);
        _currentIndex --;
        if (_currentIndex < 0) {
            _currentIndex = _subViews.count - 1;
        }
        if (_protocolFlags.didScrollFlag) {
            [_delegate scrollView:self didScrollAtPageIndex:_currentIndex];
        }
        [self reloadDisplayedSubViews];
    } else if (scrollView.contentOffset.x >= scrollView.width * 2) {
        scrollView.contentOffset = CGPointMake(scrollView.width, 0);
        _currentIndex ++;
        if (_currentIndex >= _subViews.count) {
            _currentIndex = 0;
        }
        if (_protocolFlags.didScrollFlag) {
            [_delegate scrollView:self didScrollAtPageIndex:_currentIndex];
        }
        [self reloadDisplayedSubViews];
    }
}

#pragma mark - Private
//  移除字视图，根据下标取出当前、前一个、后一个字视图，再重新布局
- (void)reloadDisplayedSubViews {
    if (_subViews.count == 0) {
        return;
    }
    
    UIView *currentView = _subViews[_currentIndex];
    
    NSInteger nextIndex = _currentIndex + 1;
    if (nextIndex >= _subViews.count) {
        nextIndex = 0;
    }
    UIView *nextView = _subViews[nextIndex];
    
    NSInteger preIndex = _currentIndex - 1;
    if (preIndex < 0) {
        preIndex = _subViews.count - 1;
    }
    UIView *preView = _subViews[preIndex];
    
    [_displayedSubViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_displayedSubViews removeAllObjects];
    
    NSUInteger numberOfPages = _subViews.count;
    if (numberOfPages == 1) {
        [_scrollView addSubview:currentView];
        [_displayedSubViews addObject:currentView];
    } else if (numberOfPages == 2) {
        [_scrollView addSubview:preView];
        [_scrollView addSubview:currentView];
        [_displayedSubViews addObject:preView];
        [_displayedSubViews addObject:currentView];
    } else if (numberOfPages >= 3) {
        [_scrollView addSubview:preView];
        [_scrollView addSubview:currentView];
        [_scrollView addSubview:nextView];
        [_displayedSubViews addObject:preView];
        [_displayedSubViews addObject:currentView];
        [_displayedSubViews addObject:nextView];
    }
    
    [self setNeedsLayout];
}

@end
