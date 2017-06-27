//
//  SSJLoginCommonViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginCommonViewController.h"

@interface SSJLoginCommonViewController ()

@end

@implementation SSJLoginCommonViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.appliesTheme = NO;
        self.backgroundView.hidden = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self updateViewConst];
    [self initialNav];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

#pragma mark - Private
- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topView];
    [self.scrollView addSubview:self.titleL];
}

- (void)initialNav {
    self.showNavigationBarBaseLine = NO;
    [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
}

- (void)updateViewConst {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
    }];
    
    [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView.mas_centerX);
        make.bottom.mas_equalTo(self.topView.mas_bottom).offset(-13);
        make.width.greaterThanOrEqualTo(0);
    }];
}


#pragma mark - Lazy
- (TPKeyboardAvoidingScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.contentSize = CGSizeMake(0, self.view.height);
    }
    return _scrollView;
}

- (UIImageView *)topView
{
    if (!_topView) {
        _topView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_login"]];
    }
    return _topView;
}

- (UILabel *)titleL {
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.text = @"登录";
        _titleL.textColor = [UIColor whiteColor];
        _titleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleL.textColor = [UIColor ssj_colorWithHex:@"#EB4A64"];
    }
    return _titleL;
}

@end
