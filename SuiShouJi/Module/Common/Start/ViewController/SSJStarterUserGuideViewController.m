//
//  SSJStarterUserGuideViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJStarterUserGuideViewController.h"
#import "SSJPageControl.h"
#import "SSJStartViewHelper.h"
#import "SSJNewUserGifGuideView.h"
#import "SSJThemeGuideView.h"
#import "SSJNavigationController.h"

@interface SSJStarterUserGuideViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *jumpOutButton;

@property (nonatomic, strong) NSMutableArray <UIView <SSJAnimatedGuideViewProtocol> *> *contentViews;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SSJPageControl *pageControl;

@property (nonatomic, strong) UIButton *beginButton;

@end

@implementation SSJStarterUserGuideViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesNavigationBarWhenPushed = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    [self createContentViews];
    [self.view addSubview:self.pageControl];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.contentViews.count * self.scrollView.width, self.scrollView.height);
    for (int idx = 0; idx < self.contentViews.count; idx ++) {
        UIView *contentView = (UIView *)_contentViews[idx];
        contentView.frame = CGRectMake(self.scrollView.width * idx, 0, self.scrollView.width, self.scrollView.height);
    }
    
    self.pageControl.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.93);
    self.beginButton.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.80);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self.contentViews objectAtIndex:0] startAnimating];
}

#pragma mark - Getter
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
        _pageControl.pageImage = [[UIImage imageNamed:@"dian_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _pageControl.currentPageImage = [[UIImage imageNamed:@"dian_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _pageControl.spaceBetweenPages = 20.0;
        _pageControl.tintColor = [UIColor ssj_colorWithHex:@"aad97f"];
        [_pageControl addTarget:self action:@selector(pageControlAction) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

- (UIButton *)beginButton {
    if (!_beginButton) {
        _beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _beginButton.clipsToBounds = YES;
        _beginButton.layer.cornerRadius = 6;
        _beginButton.frame = CGRectMake(0, 0, 317, 48);
        _beginButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        //        [_beginButton setTitle:@"立即体验" forState:UIControlStateNormal];
        [_beginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [_beginButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f17272"] forState:UIControlStateNormal];
        [_beginButton setBackgroundImage:[UIImage imageNamed:@"aimateguide_btn_background"] forState:UIControlStateNormal];
        [_beginButton addTarget:self action:@selector(beginButtonAciton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beginButton;
}

#pragma mark - Private
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger idx = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = idx;
    if (idx == self.contentViews.count - 1) {
        [UIView transitionFromView:self.pageControl toView:self.beginButton duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            [[self.contentViews objectAtIndex:idx] startAnimating];
            
        }];
    } else {
        [UIView transitionFromView:self.beginButton toView:self.pageControl duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            [[self.contentViews objectAtIndex:idx] startAnimating];
        }];
    }
}

- (void)pageControlAction {
    CGFloat offsetX = _pageControl.currentPage * _scrollView.width;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    [[self.contentViews objectAtIndex:_pageControl.currentPage] startAnimating];
}


#pragma mark - Private
- (void)createContentViews {
    if (!self.contentViews) {
        self.contentViews = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    
    for (int i = 0; i < 3; i ++) {
        switch (i) {
            case 0:{
                SSJNewUserGifGuideView *guideView = [[SSJNewUserGifGuideView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) WithImageName:@"newuserguide3.gif" title:@"做好资金和预算设置,账目记起来" subTitle:@"资金列表、预算"];
                [self.contentViews addObject:guideView];
                [self.scrollView addSubview:guideView];
            }
                break;
                
            case 1:{
                SSJNewUserGifGuideView *guideView = [[SSJNewUserGifGuideView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) WithImageName:@"newuserguide4.gif" title:@"多样报表帮你分析收支" subTitle:@"手指哪个占大头?\n收支何时不寻常"];
                [self.contentViews addObject:guideView];
                [self.scrollView addSubview:guideView];
            }
                break;
                
            case 2:{
                SSJThemeGuideView *themeGuideView = [[SSJThemeGuideView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
                [self.contentViews addObject:themeGuideView];
                [self.scrollView addSubview:themeGuideView];
            }
                break;
                
                
            default:
                break;
        }
    }
}


- (void)beginButtonAciton {
    [SSJStartViewHelper jumpOutOnViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
