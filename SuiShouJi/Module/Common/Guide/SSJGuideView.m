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

@interface SSJGuideView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *contentViews;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SSJPageControl *pageControl;

@property (nonatomic, strong) UIButton *beginButton;

@property (nonatomic, copy) void (^finishHandle)();

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
//    self.beginButton.center = self.pageControl.center;
}

- (void)showIfNeeded {
    if (!self.superview && SSJIsFirstLaunchForCurrentVersion()) {
        [self showWithFinish:NULL];
    }
}

- (void)showWithFinish:(void (^)())finish {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIView transitionWithView:window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [window addSubview:self];
    } completion:NULL];
    self.finishHandle = finish;
}

- (void)dismiss:(BOOL)animated {
    if (self.superview) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:(animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone)];
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
    for (int i = 0; i < 3; i ++) {
        UIImage *image = [UIImage ssj_compatibleImageNamed:images[i]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.scrollView addSubview:imageView];
        [self.contentViews addObject:imageView];
    }
}

- (void)beginButtonAciton {
    [self dismiss:YES];
    SSJAddLaunchTimesForCurrentVersion();
    if (self.finishHandle) {
        self.finishHandle();
        self.finishHandle = nil;
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
        _pageControl.pageImage = [[UIImage imageNamed:@"circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _pageControl.currentPageImage = [[UIImage imageNamed:@"solid_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _pageControl.spaceBetweenPages = 20.0;
        _pageControl.tintColor = [UIColor whiteColor];
        [_pageControl addTarget:self action:@selector(pageControlAction) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

- (UIButton *)beginButton {
    if (!_beginButton) {
        _beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _beginButton.clipsToBounds = YES;
        _beginButton.size = CGSizeMake(150, 45);
        _beginButton.layer.cornerRadius = 3;
        _beginButton.layer.borderWidth = 1;
        _beginButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#dfff2b"].CGColor;
        _beginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_beginButton setTitle:@"立即体验" forState:UIControlStateNormal];
        [_beginButton setTitleColor:[UIColor ssj_colorWithHex:@"#dfff2b"] forState:UIControlStateNormal];
        [_beginButton ssj_setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_beginButton addTarget:self action:@selector(beginButtonAciton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beginButton;
}

@end
