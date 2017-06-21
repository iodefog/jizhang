//
//  SSJLoginVerifyPhoneViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginVerifyPhoneViewController.h"

#import "SSJLoginVerifyPhoneNumViewModel.h"

@interface SSJLoginVerifyPhoneViewController ()
/**手机号输入框*/
@property (nonatomic, strong) UITextField *numTextF;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *verifyPhoneViewModel;

@property (nonatomic, strong) UIButton *verifyPhoneBtn;
@end

@implementation SSJLoginVerifyPhoneViewController

#pragma mark - System
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.numTextF];
    [self.view addSubview:self.verifyPhoneBtn];
    [self updateViewConstraints];
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [self.numTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    
    [self.verifyPhoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.mas_equalTo(self.numTextF);
        make.top.mas_equalTo(self.numTextF.mas_bottom).offset(40);
    }];
    [super updateViewConstraints];
}

#pragma mark - Lazy
- (UITextField *)numTextF {
    if (!_numTextF) {
        _numTextF = [[UITextField alloc] init];
        _numTextF.placeholder = @"placeholder";
        _numTextF.backgroundColor = [UIColor cyanColor];
    }
    return _numTextF;
}

- (UIButton *)verifyPhoneBtn {
    if (!_verifyPhoneBtn) {
        _verifyPhoneBtn = [[UIButton alloc] init];
        [_verifyPhoneBtn setTitle:@"下一步" forState:UIControlStateNormal];
        _verifyPhoneBtn.backgroundColor = [UIColor brownColor];
        RAC(_verifyPhoneBtn,enabled) = self.verifyPhoneViewModel.enableVerifySignal;
        @weakify(self);
        [[_verifyPhoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
//            [self.verifyPhoneViewModel.verifyPhoneNumRequestCommand execute:nil];
            [[self.verifyPhoneViewModel.verifyPhoneNumRequestCommand execute:nil] subscribeNext:^(id x) {
                NSLog(@"-----%%%%))*)()%@",x);
            }];
        }];
    }
    return _verifyPhoneBtn;
}

- (SSJLoginVerifyPhoneNumViewModel *)verifyPhoneViewModel {
    if (!_verifyPhoneViewModel) {
        _verifyPhoneViewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
    }
    return _verifyPhoneViewModel;
}

@end
