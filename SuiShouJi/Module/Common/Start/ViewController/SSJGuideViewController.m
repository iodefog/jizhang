//
//  SSJGuideViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJGuideViewController.h"
#import "SSJGuideView.h"
#import "SSJNavigationController.h"
#import "SSJStartViewHelper.h"

@interface SSJGuideViewController ()

@property (nonatomic, strong) SSJGuideView *guideView;

@property (nonatomic, strong) UIButton *jumpOutButton;

@end

@implementation SSJGuideViewController

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
    [self.view addSubview:self.guideView];
    [self.view addSubview:self.jumpOutButton];
    [self.view updateConstraintsIfNeeded];
    // Do any additional setup after loading the view.
}

- (void)updateViewConstraints {
    [self.guideView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(self.view);
    }];
    
    [self.jumpOutButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(45);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Getter
- (SSJGuideView *)guideView {
    if (!_guideView) {
        _guideView = [[SSJGuideView alloc] init];
    }
    return _guideView;
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

- (void)jumpOutButtonClicked:(id)sender {
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
