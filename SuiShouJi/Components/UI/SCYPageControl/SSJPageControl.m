//
//  SSJPageControl.m
//  MoneyMore
//
//  Created by old lang on 15-5-7.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJPageControl.h"

@interface SSJPageControl ()

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation SSJPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentPage = 0;
        _numberOfPages = 0;
        _buttons = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_numberOfPages == 0) {
        return;
    }
    
    CGFloat width = _pageImage.size.width;
    CGFloat height = _pageImage.size.height;
    for (int idx = 0; idx < _buttons.count; idx ++) {
        UIButton *button = _buttons[idx];
        button.frame = CGRectMake((width + _spaceBetweenPages) * idx, 0, width + _spaceBetweenPages, height);
    }
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    if (_numberOfPages != numberOfPages) {
        _numberOfPages = numberOfPages;
        [self p_reload];
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        for (int idx = 0; idx < _buttons.count; idx ++) {
            UIButton *button = _buttons[idx];
            button.selected = (idx == _currentPage);
        }
    }
}

- (void)setPageImage:(UIImage *)pageImage {
    _pageImage = pageImage;
    [self p_reload];
    [self sizeToFit];
}

- (void)setCurrentPageImage:(UIImage *)currentPageImage {
    _currentPageImage = currentPageImage;
    [self p_reload];
}

- (void)setSpaceBetweenPages:(CGFloat)spaceBetweenPages {
    if (_spaceBetweenPages != spaceBetweenPages) {
        _spaceBetweenPages = spaceBetweenPages;
        [self sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    for (UIButton *button in self.buttons) {
        button.tintColor = tintColor;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (!_pageImage) {
        return CGSizeZero;
    }
    CGFloat width = _pageImage.size.width;
    CGFloat height = _pageImage.size.height;
    return CGSizeMake(width * _numberOfPages + _spaceBetweenPages * _numberOfPages, height);
}

- (void)p_reload {
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttons removeAllObjects];
    
    if (!_pageImage || !_currentPageImage) {
        return;
    }
    
    for (int idx = 0; idx < _numberOfPages; idx ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.selected = (idx == _currentPage);
        [button setImage:_pageImage forState:UIControlStateNormal];
        [button setImage:_currentPageImage forState:UIControlStateSelected];
        [button setImage:_currentPageImage forState:(UIControlStateHighlighted | UIControlStateSelected)];
        [button addTarget:self action:@selector(p_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = self.tintColor;
        [_buttons addObject:button];
        [self addSubview:button];
    }
}

- (void)p_buttonAction:(UIButton *)button {
    if ([_buttons containsObject:button]) {
        NSUInteger idx = [_buttons indexOfObject:button];
        [self setCurrentPage:idx];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
