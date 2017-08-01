//
//  SSJWishManageViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishManageViewController.h"
#import "SSJMakeWishViewController.h"
#define kbtnSpace 0
#define kbtnHeigh 43
@interface SSJWishManageViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>
{
    NSMutableArray *_vcArray;
    UIPageViewController *_pageCtrl;
    UIScrollView *_topScrollView;//按钮的滚动视图
    NSInteger _curPage;
    UIView *_inidicatorView;//按钮下面的横线
}

@end

@implementation SSJWishManageViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createVCArray];
    [self createPageVC];
    [self initTopView];
    [self setUpNav];

    self.title = @"为心愿存钱";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    [self updateAppearanceAfterThemeChanged];
}

- (void)setUpNav {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"wish_add_wish"] style:UIBarButtonItemStylePlain target:self action:@selector(navRightClick)];
}

- (void)navRightClick {
    SSJMakeWishViewController *makeWish = [[SSJMakeWishViewController alloc] init];
    [self.navigationController pushViewController:makeWish animated:YES];
}

- (void)initTopView {
    NSArray *btnTitle = @[@"心愿清单",@"历史心愿"];
    _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, SSJSCREENWITH, 44)];
    CGFloat kbtnWith = SSJSCREENWITH * 0.5;
    for (NSInteger i=0; i<btnTitle.count; i++) {
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btn.frame = CGRectMake(kbtnSpace+i*kbtnWith, kbtnSpace, kbtnWith, kbtnHeigh);
        [btn setTitle:btnTitle[i] forState:(UIControlStateNormal)];
        [btn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:(UIControlStateNormal)];
//        [btn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:(UIControlStateSelected)];
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
        btn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_topScrollView addSubview:btn];
    }
    _topScrollView.contentSize = CGSizeMake(kbtnSpace+btnTitle.count*kbtnWith, kbtnHeigh);
    
    _inidicatorView = [[UIView alloc] initWithFrame:CGRectMake(kbtnSpace, kbtnHeigh, kbtnWith, 2)];
    
    [_topScrollView addSubview:_inidicatorView];
    
    [self.view addSubview:_topScrollView];
}


- (void)btnClicked:(UIButton *)btn
{
    NSInteger index = btn.tag - 100;
    if (index == 0) {
        btn.selected = !btn.selected;
        
    } else if (index == 1) {
        btn.selected = !btn.selected;
    }
    [_pageCtrl setViewControllers:@[_vcArray[index]] direction:index<=_curPage animated:YES completion:^(BOOL finished) {
        _curPage = index;
    }];
}

- (void)createVCArray
{
    _vcArray = [NSMutableArray array];
    NSArray *vcArray = @[@"SSJWishIngViewController",@"SSJWishFinishedViewController"];
    for (NSInteger i=0; i<vcArray.count; i++) {
        Class cls = NSClassFromString(vcArray[i]);
        UIViewController *vc = [[cls alloc] init];
        [_vcArray addObject:vc];
    }
}

- (void)createPageVC
{
    _pageCtrl = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:(UIPageViewControllerNavigationOrientationHorizontal) options:nil];
    _pageCtrl.delegate = self;
    _pageCtrl.dataSource = self;
    [_pageCtrl setViewControllers:@[_vcArray[0]] direction:(UIPageViewControllerNavigationDirectionForward) animated:YES completion:nil];
    _pageCtrl.view.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM + _topScrollView.height, SSJSCREENWITH, SSJSCREENHEIGHT - SSJ_NAVIBAR_BOTTOM - _topScrollView.height);
    [self.view addSubview:_pageCtrl.view];
    for (UIView *view in _pageCtrl.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)view).delegate = self;
        }
    }
}

#pragma mark - Private
- (void)updateAppearanceAfterThemeChanged {
    _inidicatorView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
    _topScrollView.backgroundColor = [UIColor clearColor];
}

-(void)ssj_backOffAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIPageViewController
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [_vcArray indexOfObject:viewController];
    if (index+1 == _vcArray.count) {
        return _vcArray[0];
    }
    return _vcArray[index+1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [_vcArray indexOfObject:viewController];
    if (index == 0) {
        return _vcArray[_vcArray.count-1];
    }
    return _vcArray[index-1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    _curPage = [_vcArray indexOfObject:pageViewController.viewControllers[0]];
}

//开始滚动的时候
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offSet = scrollView.contentOffset;
    CGFloat width = SSJSCREENWITH;
    CGFloat kbtnWith = SSJSCREENWITH / _vcArray.count;
    CGRect frame = _inidicatorView.frame;
    CGFloat ratio = kbtnWith/width;
    
    frame.origin.x = (offSet.x - width)*ratio+_curPage*kbtnWith;
    _inidicatorView.frame = frame;
    
    CGFloat maxX = CGRectGetMaxX(_inidicatorView.frame);
    CGRect topScrollViewFrame = _topScrollView.frame;
    if (maxX<=_inidicatorView.frame.size.width) {//如果滑块的滑动距离小于滑块的宽度,topScrollView的偏移量不变
        _topScrollView.contentOffset = CGPointZero;
    }
    if (maxX >= topScrollViewFrame.size.width && maxX <=_vcArray.count*kbtnWith+kbtnSpace) {
        _topScrollView.contentOffset = CGPointMake(maxX-topScrollViewFrame.size.width, 0);
    }
}

@end
