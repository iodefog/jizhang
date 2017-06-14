//
//  SCYSlidePagingHeaderView.m
//  SCYSlidePagingControl
//
//  Created by old lang on 15-4-30.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SCYSlidePagingHeaderView.h"

@interface SCYSlidePagingHeaderView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic) CGSize tabSize;

@property (nonatomic) BOOL userTapped;

@end

@implementation SCYSlidePagingHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _enable = YES;
        _titleFont = 15;
        _titleColor = [UIColor lightGrayColor];
        _selectedTitleColor = [UIColor blueColor];
        
        _buttons = [[NSMutableArray alloc] init];
        _tabView = [[UIView alloc] init];
        _tabView.backgroundColor = _selectedTitleColor;
        [self addSubview:_tabView];
        
//        _bottomLine = [[UIView alloc] init];
//        _bottomLine.backgroundColor = [UIColor blueColor];
//        [self addSubview:_bottomLine];
        
        self.backgroundColor = [UIColor whiteColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.titles.count <= 0) {
        return;
    }
    
    CGFloat autualCount = self.displayedButtonCount;
    if (autualCount <= 0 || autualCount > self.titles.count) {
        autualCount = self.titles.count;
    }
    
    CGFloat width = self.width / autualCount;
    CGFloat height = self.height;
    
    for (int idx = 0; idx < _buttons.count; idx ++) {
        UIButton *button = _buttons[idx];
        if (![button isKindOfClass:[UIButton class]]) {
            continue;
        }
        CGFloat axisX = width *idx;
        CGFloat axisY = 0;
        button.frame = CGRectMake(axisX, axisY, width, height);
        [button ssj_layoutContent];
    }
    
    CGFloat tabWidth = MIN(_tabSize.width, width);
    CGFloat tabHeight = MIN(_tabSize.height, self.height);
    _tabView.size = CGSizeMake(tabWidth, tabHeight);
    
    if (_tabSize.width <= 0) {
        _tabView.width = width;
    }
    
    if (_tabSize.height <= 0) {
        _tabView.height = 2.0;
    }
    
    _tabView.bottom = self.height;
    _tabView.centerX = width * 0.5 + width * _selectedIndex;
    self.contentSize = CGSizeMake(width * _buttons.count, height);
    
//    CGFloat scale = [UIScreen mainScreen].scale;
//    _bottomLine.frame = CGRectMake(0, self.height - 1 / scale, self.contentSize.width, 1 / scale);
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    if (delegate != self) {
        return;
    }
    [super setDelegate:delegate];
}

- (void)setDisplayedButtonCount:(CGFloat)displayedButtonCount {
    if (displayedButtonCount < 0) {
        return;
    }
    
    if (_displayedButtonCount != displayedButtonCount) {
        _displayedButtonCount = displayedButtonCount;
        [self setNeedsLayout];
    }
}

- (void)setTitleFont:(CGFloat)titleFont {
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        for (UIButton *button in _buttons) {
            button.titleLabel.font = [UIFont systemFontOfSize:_titleFont];
        }
    }
}

- (void)setTitles:(NSArray *)titles {
    if (!titles || titles.count == 0) {
        SSJPRINT(@"titles至少有1个元素");
        return;
    }
    
    if (![_titles isEqualToArray:titles]) {
        _titles = titles;
        [self setSelectedIndex:0 animated:NO];
        [self reload];
        [self setNeedsLayout];
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    for (UIButton *button in _buttons) {
        if (![button isKindOfClass:[UIButton class]]) {
            continue;
        }
        [button setTitleColor:_titleColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    _tabView.backgroundColor = _selectedTitleColor;
    for (UIButton *button in _buttons) {
        if (![button isKindOfClass:[UIButton class]]) {
            continue;
        }
        [button setTitleColor:_selectedTitleColor forState:UIControlStateSelected];
        [button setTitleColor:_selectedTitleColor forState:(UIControlStateHighlighted | UIControlStateSelected)];
    }
}

- (void)setEnable:(BOOL)enable {
    if (_enable != enable) {
        _enable = enable;
        for (UIButton *btn in _buttons) {
            btn.enabled = enable;
        }
    }
}

- (NSArray *)getButtons {
    return [NSArray arrayWithArray:self.buttons];
}

- (void)setTabSize:(CGSize)tabSize {
    if (!CGSizeEqualToSize(_tabSize, tabSize)) {
        _tabSize = tabSize;
        [self setNeedsLayout];
    }
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    _userTapped = NO;
    [self p_setSelectedIndex:index animated:animated];
}

- (void)setButtonImage:(UIImage *)image layoutType:(SSJButtonLayoutType)type spaceBetweenImageAndTitle:(CGFloat)space forControlState:(UIControlState)state atIndex:(NSInteger)index {
    UIButton *button = [_buttons ssj_safeObjectAtIndex:index];
    
    if (state == UIControlStateNormal) {
        [button setImage:image forState:UIControlStateNormal];
    } else if (state == UIControlStateSelected) {
        [button setImage:image forState:UIControlStateSelected];
        [button setImage:image forState:(UIControlStateHighlighted | UIControlStateSelected)];
    }
    button.contentLayoutType = type;
    button.spaceBetweenImageAndTitle = space;
}

#pragma mark - Private
- (void)reload {
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttons removeAllObjects];
    
    for (int idx = 0; idx < _titles.count; idx ++) {
        NSString *title = _titles[idx];
        if (![title isKindOfClass:[NSString class]]) {
            continue;
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:_titleFont];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p_titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:_titleColor forState:UIControlStateNormal];
        [button setTitleColor:_selectedTitleColor forState:UIControlStateSelected];
        [button setTitleColor:_selectedTitleColor forState:(UIControlStateHighlighted | UIControlStateSelected)];
        button.selected = idx == _selectedIndex;
        button.enabled = _enable;
        [_buttons addObject:button];
        [self addSubview:button];
    }
}

- (void)p_titleButtonAction:(UIButton *)button {
    if ([_buttons containsObject:button]) {
        
        NSUInteger selectedIndex = [_buttons indexOfObject:button];
        if (_customDelegate && [_customDelegate respondsToSelector:@selector(slidePagingHeaderView:willSelectButtonAtIndex:)]) {
            [_customDelegate slidePagingHeaderView:self willSelectButtonAtIndex:selectedIndex];
        }
        
        _userTapped = YES;
        
        [self p_setSelectedIndex:selectedIndex animated:_buttonClickAnimated];
        
        if (!_buttonClickAnimated) {
            if (_customDelegate && [_customDelegate respondsToSelector:@selector(slidePagingHeaderView:didSelectButtonAtIndex:)]) {
                [_customDelegate slidePagingHeaderView:self didSelectButtonAtIndex:selectedIndex];
            }
        }
    }
}

- (void)p_setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    if (index >= _buttons.count) {
        return;
    }
    
//    if (_selectedIndex == index) {
//        return;
//    }
    
    _selectedIndex = index;
    
    [UIView animateWithDuration:(animated ? 0.25 : 0.0) animations:^{
        for (int idx = 0; idx < _buttons.count; idx ++) {
            UIButton *button = _buttons[idx];
            button.selected = idx == _selectedIndex;
            if (button.selected) {
                _tabView.centerX = button.centerX;
            }
        }
    } completion:^(BOOL finished) {
        UIButton *selectedButton = _buttons[_selectedIndex];
        CGFloat targetPosition = self.contentOffset.x + self.width * 0.5;
        CGFloat offSetX = self.contentOffset.x - (targetPosition - selectedButton.centerX);
        offSetX = MAX(0, offSetX);
        offSetX = MIN((self.contentSize.width - self.width), offSetX);
        
        if (offSetX == 0) {
            if (_userTapped && self.customDelegate && [_customDelegate respondsToSelector:@selector(slidePagingHeaderView:didSelectButtonAtIndex:)]) {
                [_customDelegate slidePagingHeaderView:self didSelectButtonAtIndex:_selectedIndex];
            }
        } else {
            [self setContentOffset:CGPointMake(offSetX, 0) animated:animated];
        }
    }];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.customDelegate scrollViewDidScroll:self];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.customDelegate scrollViewDidZoom:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.customDelegate scrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.customDelegate scrollViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.customDelegate scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.customDelegate scrollViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.customDelegate scrollViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.customDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
    
    if (_userTapped && self.customDelegate && [_customDelegate respondsToSelector:@selector(slidePagingHeaderView:didSelectButtonAtIndex:)]) {
        [_customDelegate slidePagingHeaderView:self didSelectButtonAtIndex:_selectedIndex];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.customDelegate viewForZoomingInScrollView:self];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.customDelegate scrollViewWillBeginZooming:self withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.customDelegate scrollViewDidEndZooming:self withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.customDelegate scrollViewShouldScrollToTop:self];
    }
    return NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (self.customDelegate && [self.customDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.customDelegate scrollViewDidScrollToTop:self];
    }
}

@end
