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
    
    self.pageControl.center = CGPointMake(self.width * 0.5, self.height * 0.85);
    self.beginButton.center = CGPointMake(self.width * 0.5, self.height * 0.8);
    self.beginButton.center = self.pageControl.center;
}

- (void)show:(BOOL)animated {
    if (!self.superview) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:(animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone)];
        [UIView transitionWithView:window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [window addSubview:self];
        } completion:NULL];
    }
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
        [UIView transitionFromView:self.pageControl toView:self.beginButton duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve completion:NULL];
    } else {
        [UIView transitionFromView:self.beginButton toView:self.pageControl duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve completion:NULL];
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
    for (int idx = 0; idx < 4; idx ++) {
        UIView *contentView = nil;
        if (idx < 3) {
            NSString *imageName = images[idx];
            contentView = [[SSJGuideContentView alloc] init];
            ((SSJGuideContentView *)contentView).imageName = imageName;
        } else {
            contentView = [[SSJGuideLastContentView alloc] init];
        }
        
        [self.scrollView addSubview:contentView];
        [self.contentViews addObject:contentView];
    }
}

- (void)beginButtonAciton {
    [self dismiss:YES];
    if (self.beginHandle) {
        self.beginHandle(self);
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
        _pageControl.pageImage = [UIImage imageNamed:@"point_hollow"];
        _pageControl.currentPageImage = [UIImage imageNamed:@"point_solid"];
        _pageControl.spaceBetweenPages = 20.0;
        [_pageControl addTarget:self action:@selector(pageControlAction) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

- (UIButton *)beginButton {
    if (!_beginButton) {
        _beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _beginButton.clipsToBounds = YES;
        _beginButton.size = CGSizeMake(195, 40);
        _beginButton.layer.cornerRadius = 3;
        _beginButton.layer.borderWidth = 1;
        _beginButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#ea5559"].CGColor;
        _beginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_beginButton setTitle:@"立即体验" forState:UIControlStateNormal];
        [_beginButton setTitleColor:[UIColor ssj_colorWithHex:@"#ea5559"] forState:UIControlStateNormal];
        [_beginButton ssj_setBackgroundColor:[[UIColor ssj_colorWithHex:@"#ea5559"]  colorWithAlphaComponent:0.15] forState:UIControlStateNormal];
        [_beginButton addTarget:self action:@selector(beginButtonAciton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beginButton;
}

@end
