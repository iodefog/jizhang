//
//  SSJNewUserStartViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewUserFirstStartViewController.h"
#import "SSJStartViewHelper.h"
#import "SSJStartChoiceView.h"
#import "SSJNavigationController.h"

@interface SSJNewUserFirstStartViewController ()

@property (nonatomic, strong) SSJStartChoiceView *choiceView;

@property (nonatomic, strong) YYAnimatedImageView *gifImageView;

@property (nonatomic, strong) YYImage *gifImage;

@property (nonatomic, strong) UIButton *jumpOutButton;

@end

@implementation SSJNewUserFirstStartViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesNavigationBarWhenPushed = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)dealloc {
    [self.gifImageView removeObserver:self forKeyPath:@"currentIsPlayingAnimation"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.gifImageView addObserver:self forKeyPath:@"currentIsPlayingAnimation" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.gifImageView];
    [self.view addSubview:self.choiceView];
    [self.view addSubview:self.jumpOutButton];
    [self.view setNeedsUpdateConstraints];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.gifImageView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewConstraints {
    [self.gifImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(self.view);
    }];
    
    [self.choiceView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(self.view);
    }];
    
    [self.jumpOutButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(85);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
    
    [super updateViewConstraints];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!self.gifImageView.currentIsPlayingAnimation && self.gifImageView.currentAnimatedImageIndex == self.gifImage.animatedImageFrameCount - 1) {
        self.gifImageView.hidden = YES;
        self.choiceView.hidden = NO;
        [self.choiceView startAnimating];
    }
}

#pragma mark - Getter
- (YYAnimatedImageView *)gifImageView {
    if (!_gifImageView) {
        _gifImageView = [[YYAnimatedImageView alloc] initWithImage:self.gifImage];
        _gifImageView.autoPlayAnimatedImage = NO;
    }
    return _gifImageView;
}

- (YYImage *)gifImage {
    if (!_gifImage) {
        _gifImage = [YYImage imageNamed:@"newuserguide1.gif"];
    }
    return _gifImage;
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

- (SSJStartChoiceView *)choiceView {
    if (!_choiceView) {
        _choiceView = [[SSJStartChoiceView alloc] init];
        _choiceView.hidden = YES;
    }
    return _choiceView;
}

- (void)jumpOutButtonClicked:(id)sender {
    [SSJStartViewHelper jumpOutOnViewController:self];
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
