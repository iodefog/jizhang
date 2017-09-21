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
#import "SSJStartThemeService.h"

@interface SSJStarterUserGuideViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *jumpOutButton;

@property (nonatomic, strong) NSMutableArray <UIView <SSJAnimatedGuideViewProtocol> *> *contentViews;

@property (nonatomic, strong) SSJStartThemeService *themeService;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIButton *beginButton;

@end

@implementation SSJStarterUserGuideViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesNavigationBarWhenPushed = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.appliesTheme = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createContentViews];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageControl];
    [self.view addSubview:self.jumpOutButton];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.jumpOutButton.rightTop = CGPointMake(self.view.width - 30, 45);
    self.jumpOutButton.size = CGSizeMake(50, 20);
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.contentViews.count * self.scrollView.width, self.scrollView.height);
    for (int idx = 0; idx < self.contentViews.count; idx ++) {
        UIView *contentView = (UIView *)_contentViews[idx];
        contentView.frame = CGRectMake(self.scrollView.width * idx, 0, self.scrollView.width, self.scrollView.height);
    }
    self.pageControl.size = [self.pageControl sizeForNumberOfPages:3];
    self.pageControl.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.93);
    self.beginButton.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.93);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self.contentViews objectAtIndex:0] startAnimating];
    [self.themeService requestWithThemeIds:@[@"0",@"7",@"5",@"8",@"3",@"10"]];
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

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.pageIndicatorTintColor = [UIColor ssj_colorWithHex:@"#333333" alpha:0.2];
        _pageControl.currentPageIndicatorTintColor = [UIColor ssj_colorWithHex:@"#333333" alpha:0.4];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.numberOfPages = 3;
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

- (UIButton *)jumpOutButton {
    if (!_jumpOutButton) {
        _jumpOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_jumpOutButton setTitle:@"跳过" forState:UIControlStateNormal];
        [_jumpOutButton addTarget:self action:@selector(jumpOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _jumpOutButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_jumpOutButton setTitleColor:[UIColor ssj_colorWithHex:@"#EE4F4F"] forState:UIControlStateNormal];
        _jumpOutButton.layer.cornerRadius = 4.f;
        _jumpOutButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#EE4F4F"].CGColor;
        _jumpOutButton.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    }
    return _jumpOutButton;
}

- (SSJStartThemeService *)themeService {
    if (!_themeService) {
        _themeService = [[SSJStartThemeService alloc] initWithDelegate:self];
    }
    return _themeService;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if ([service.returnCode isEqualToString:@"1"]) {
        SSJThemeGuideView *themeGuideView = (SSJThemeGuideView *)[self.contentViews objectAtIndex:2];
        themeGuideView.themeItems = self.themeService.themeItems;
    }
}

#pragma mark - Event
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger idx = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = idx;
    if (idx == self.contentViews.count - 1) {        
        [UIView transitionFromView:self.pageControl toView:self.beginButton duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            for (int i = 0; i < self.contentViews.count; i ++) {
                if (i == idx) {
                    [[self.contentViews objectAtIndex:i] startAnimating];
                } else {
                    [self.contentViews objectAtIndex:i].isNormalState = YES;
                }
            }
        }];

      
    } else {
        [UIView transitionFromView:self.beginButton toView:self.pageControl duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            for (int i = 0; i < self.contentViews.count; i ++) {
                if (i == idx) {
                    [[self.contentViews objectAtIndex:i] startAnimating];
                } else {
                    [self.contentViews objectAtIndex:i].isNormalState = YES;
                }
            }
        }];
    }
}

- (void)pageControlAction {
    CGFloat offsetX = _pageControl.currentPage * _scrollView.width;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    [[self.contentViews objectAtIndex:_pageControl.currentPage] startAnimating];
}

- (void)beginButtonAciton {
    [SSJStartViewHelper jumpOutOnViewController:self];
}

- (void)jumpOutButtonClicked:(id)sender {
    [SSJStartViewHelper jumpOutOnViewController:self];
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
