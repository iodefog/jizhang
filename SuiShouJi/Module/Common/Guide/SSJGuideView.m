//
//  SSJGuideView.m
//  MoneyMore
//
//  Created by old lang on 15-5-7.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJGuideView.h"
#import "SSJGuideContentView.h"
#import "SSJGuideLastContentView.h"
#import "SSJPageControl.h"
#import "SSJBorderButton.h"

@interface SSJGuideView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *contentViews;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SSJPageControl *pageControl;

@property (nonatomic, strong) SSJBorderButton *beginButton;

@end

@implementation SSJGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self createContentViews];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)layoutSubviews {
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.contentViews.count * self.scrollView.width, self.scrollView.height);
    for (int idx = 0; idx < self.contentViews.count; idx ++) {
        UIView *contentView = _contentViews[idx];
        contentView.frame = CGRectMake(self.scrollView.width * idx, 0, self.scrollView.width, self.scrollView.height);
    }
    
    self.pageControl.center = CGPointMake(self.width * 0.5, self.height * 0.93);
    self.beginButton.center = CGPointMake(self.width * 0.5, self.height * 0.88);
    self.beginButton.center = self.pageControl.center;
}

- (void)showInView:(UIView *)view finish:(SSJGuideViewBeginBlock)finish {
    [UIView transitionWithView:view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [view addSubview:self];
    } completion:NULL];
    self.beginHandle = finish;
}

- (void)dismiss:(BOOL)animated {
    if (self.superview) {
        [UIView animateWithDuration:0.5f animations:^(void){
            self.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
            self.alpha = 0;
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger idx = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = idx;
    if (idx == self.contentViews.count - 1) {
        [UIView transitionFromView:self.pageControl toView:self.beginButton duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:NULL];
    } else {
        [UIView transitionFromView:self.beginButton toView:self.pageControl duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:NULL];
    }
}

- (void)pageControlAction {
    CGFloat offsetX = _pageControl.currentPage * _scrollView.width;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)createContentViews {
    if (!self.contentViews) {
        self.contentViews = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    NSArray *images = @[@"guide_1",@"guide_2",@"guide_3"];
    for (int i = 0; i < images.count; i ++) {
        UIImage *image = [UIImage ssj_compatibleImageNamed:images[i]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.scrollView addSubview:imageView];
        [self.contentViews addObject:imageView];
    }
}

- (void)beginButtonAciton {
    SSJAddLaunchTimesForCurrentVersion();
    if (self.beginHandle) {
        self.beginHandle(self);
        self.beginHandle = nil;
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (SSJPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[SSJPageControl alloc] init];
        _pageControl.numberOfPages = self.contentViews.count;
        _pageControl.pageImage = [UIImage imageNamed:@"dian_nor"];
        _pageControl.currentPageImage = [UIImage imageNamed:@"dian_sel"];
        _pageControl.spaceBetweenPages = 20.0;
        [_pageControl addTarget:self action:@selector(pageControlAction) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

- (SSJBorderButton *)beginButton {
    if (!_beginButton) {
        _beginButton = [[SSJBorderButton alloc] initWithFrame:CGRectMake(0, 0, 132, 40)];
        [_beginButton setCornerRadius:20];
        [_beginButton setFontSize:18];
        [_beginButton setTitle:@"立即体验" forState:SSJBorderButtonStateNormal];
        [_beginButton setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:SSJBorderButtonStateNormal];
        [_beginButton setTitleColor:[UIColor whiteColor] forState:SSJBorderButtonStateHighlighted];
        [_beginButton setBorderColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:SSJBorderButtonStateNormal];
        [_beginButton setBackgroundColor:[UIColor whiteColor] forState:SSJBorderButtonStateNormal];
        [_beginButton setBackgroundColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:SSJBorderButtonStateHighlighted];
        [_beginButton addTarget:self action:@selector(beginButtonAciton)];
    }
    return _beginButton;
}

@end
