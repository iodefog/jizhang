//
//  SSJOlderUserStartViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJOlderUserStartViewController.h"
#import "SSJNewUserGifGuideView.h"
#import "SSJStartViewHelper.h"
#import "SSJNavigationController.h"

@interface SSJOlderUserStartViewController ()

@property (nonatomic, strong) SSJNewUserGifGuideView *guideView;

@property (nonatomic, strong) UIButton *jumpOutButton;

@property (nonatomic, strong) UIButton *beginButton;

@end

@implementation SSJOlderUserStartViewController

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
    [self.view addSubview:self.beginButton];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.guideView startAnimating];
    self.beginButton.alpha = 0;
    [UIView animateWithDuration:2.f animations:^{
        self.beginButton.alpha = 1;
    } completion:NULL];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.guideView.frame = self.view.bounds;
    self.jumpOutButton.size = CGSizeMake(50, 20);
    self.jumpOutButton.rightTop = CGPointMake(self.view.width - 30, 45);
    self.beginButton.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.93);
}

#pragma mark - Getter
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

- (SSJNewUserGifGuideView *)guideView {
    if (!_guideView) {
        _guideView = [[SSJNewUserGifGuideView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) WithImageName:@"newuserguide5.gif" title:@"老司机记账数据丢不得!" subTitle:@"导入记账老数据,换app更舒心"];
    }
    return _guideView;
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
        [_beginButton setBackgroundImage:[UIImage imageNamed:@"startImport_btn"] forState:UIControlStateNormal];
        [_beginButton addTarget:self action:@selector(beginButtonAciton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beginButton;
}

#pragma mark - Event
- (void)jumpOutButtonClicked:(id)sender {
    [SSJStartViewHelper jumpOutOnViewController:self];
}

- (void)beginButtonAciton {
    [SSJStartViewHelper jumpToImportViewController:self];
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
