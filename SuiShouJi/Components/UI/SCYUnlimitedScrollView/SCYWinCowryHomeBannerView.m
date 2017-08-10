//
//  SCYWinCowryHomeBannerView.m
//  YYDB
//
//  Created by old lang on 15/10/30.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SCYWinCowryHomeBannerView.h"
#import "SSJUnlimitedScrollView.h"
#import "UIImageView+WebCache.h"

static const NSTimeInterval kAutoRollInterval = 5;

@interface SCYWinCowryHomeBannerView () <SSJUnlimitedScrollViewDataSource, SSJUnlimitedScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) SSJUnlimitedScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SCYWinCowryHomeBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageArray = [@[] mutableCopy];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)layoutSubviews {
    self.scrollView.frame = self.bounds;
    self.pageControl.center = CGPointMake(self.width * 0.5, self.height - 10);
}

#pragma mark - SCYUnlimitedScrollViewDataSource
- (NSUInteger)numberOfPagesInScrollView:(SSJUnlimitedScrollView *)scrollView {
    return self.imageArray.count;
}

- (UIView *)scrollView:(SSJUnlimitedScrollView *)scrollView subViewAtPageIndex:(NSUInteger)index {
    return [self.imageArray objectAtIndex:index];
}

#pragma mark - SCYUnlimitedScrollViewDelegate
- (void)scrollView:(SSJUnlimitedScrollView *)scrollView didScrollAtPageIndex:(NSUInteger)index {
    [self.pageControl setCurrentPage:index];
}

#pragma mark - Event
- (void)tapImageAction:(UITapGestureRecognizer *)gesture {
    NSUInteger tapImageIndex = [self.imageArray indexOfObject:gesture.view];
    if (tapImageIndex != NSNotFound) {
        if (self.tapAction) {
            self.tapAction(self, tapImageIndex);
        }
    }
}

#pragma mark - Public
- (void)setImageUrls:(NSArray *)imageUrls {
    if (![_imageUrls isEqualToArray:imageUrls]) {
        _imageUrls = imageUrls;
        [self createImages];
        self.pageControl.numberOfPages = imageUrls.count;
        self.pageControl.size = [self.pageControl sizeForNumberOfPages:imageUrls.count];
        [self setNeedsLayout];
    }
}

- (void)beginAutoRoll {
    if (!self.timer.valid && self.imageUrls.count > 1) {
        self.timer = [NSTimer timerWithTimeInterval:kAutoRollInterval target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAutoRoll {
    [self.timer invalidate];
}

#pragma mark - Private
- (void)createImages {
    for (NSString *urlString in self.imageUrls) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        if ([urlString isKindOfClass:[NSString class]]) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlString]
                         placeholderImage:[UIImage imageNamed:@"networkDefaultImage"] options:0
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    imageView.contentMode = UIViewContentModeScaleToFill;
                                }];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageAction:)];
        [imageView addGestureRecognizer:tap];
        
        [self.imageArray addObject:imageView];
        [self.scrollView reloadSubViews];
    }
}

- (void)scrollToNextPage {
    [self.scrollView scrollToNextPage];
}

#pragma mark - Getter
- (SSJUnlimitedScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[SSJUnlimitedScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.pageIndicatorTintColor = [UIColor ssj_colorWithHex:@"#333333" alpha:0.2];
        _pageControl.currentPageIndicatorTintColor = [UIColor ssj_colorWithHex:@"#333333" alpha:0.4];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

@end
