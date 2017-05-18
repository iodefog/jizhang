
//
//  SSJSharebooksInviteViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSharebooksInviteViewController.h"
#import "SSJShareBooksHintView.h"
#import "SSJShareBooksHelper.h"

@interface SSJSharebooksInviteViewController ()

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) UIView *backView;

@property(nonatomic, strong) UITextField *codeInput;

@property(nonatomic, strong) UIButton *resendButton;

@property(nonatomic, strong) UIButton *sendButton;

@property(nonatomic, strong) UILabel *customCodeLab;

@property(nonatomic, strong) UILabel *expireDateLab;

@property(nonatomic, strong) UILabel *codeTitleLab;

@property(nonatomic, strong) UIImageView *codeLeftImage;

@property(nonatomic, strong) UIImageView *codeRightImage;

@property(nonatomic, strong) NSMutableArray *hintViews;

@property(nonatomic, strong) NSString *code;

@property(nonatomic, strong) NSString *expiredate;

@end

@implementation SSJSharebooksInviteViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"暗号添加成员";
        self.appliesTheme = NO;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"sharebk_backgroud"];
    self.titles = @[@"发送暗号给好友",@"对方打开有鱼记账App V2.5 以上版本",@"好友添加共享账本时，输入暗号",@"大功告成～"];
    [self.view addSubview:self.backView];
    [self.backView addSubview:self.codeTitleLab];
    [self.backView addSubview:self.codeLeftImage];
    [self.backView addSubview:self.codeRightImage];
    [self.backView addSubview:self.codeInput];
    [self.backView addSubview:self.customCodeLab];
    [self.backView addSubview:self.expireDateLab];
    [self.view addSubview:self.sendButton];
    [self initHintView];
    for (SSJShareBooksHintView *hintView in self.hintViews) {
        [self.view addSubview:hintView];
    }
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backView.size = CGSizeMake(self.view.width - 35, 255);
    self.backView.centerX = self.view.width / 2;
    self.backView.top = SSJ_NAVIBAR_BOTTOM + 30;
    self.backView.layer.shadowPath = (__bridge CGPathRef _Nullable)([UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.backView.width + 4, self.backView.height + 4) cornerRadius:16.f]);
    self.backView.layer.shadowColor = [UIColor ssj_colorWithHex:@"#000000"].CGColor;
    self.backView.layer.shadowOpacity = 0.15;
    self.codeTitleLab.centerX = self.backView.width / 2;
    self.codeTitleLab.top = 30;
    self.codeLeftImage.right = self.codeTitleLab.left - 10;
    self.codeRightImage.left = self.codeTitleLab.right + 10;
    self.codeLeftImage.centerY = self.codeRightImage.centerY = self.codeTitleLab.centerY;
    self.codeInput.size = CGSizeMake(self.backView.width - 44, 57);
    self.codeInput.top = self.codeTitleLab.bottom + 34;
    self.codeInput.centerX = self.backView.width / 2;
    self.customCodeLab.left = self.codeInput.left;
    self.expireDateLab.right = self.codeInput.right;
    self.customCodeLab.top = self.expireDateLab.top = self.codeInput.bottom + 15;
    self.sendButton.centerX = self.view.width / 2;
    self.sendButton.centerY = self.backView.bottom;
    for (SSJShareBooksHintView *hintView in self.hintViews) {
        NSInteger index = [self.hintViews indexOfObject:hintView];
        hintView.size = CGSizeMake(self.view.width, 38);
        hintView.top = self.sendButton.bottom + 48 + index * 38;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - Getter
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.cornerRadius = 16.f;
    }
    return _backView;
}

- (UILabel *)codeTitleLab {
    if (!_codeTitleLab) {
        _codeTitleLab = [[UILabel alloc] init];
        _codeTitleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _codeTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _codeTitleLab.text = @"暗号";
        [_codeTitleLab sizeToFit];
    }
    return _codeTitleLab;
}

- (UIImageView *)codeLeftImage {
    if (!_codeLeftImage) {
        _codeLeftImage = [[UIImageView alloc] init];
        _codeLeftImage.image = [UIImage imageNamed:@"sharebk_bracketleft"];
        [_codeLeftImage sizeToFit];
    }
    return _codeLeftImage;
}

- (UIImageView *)codeRightImage {
    if (!_codeRightImage) {
        _codeRightImage = [[UIImageView alloc] init];
        _codeRightImage.image = [UIImage imageNamed:@"sharebk_bracketright"];
        [_codeRightImage sizeToFit];
    }
    return _codeRightImage;
}

- (UITextField *)codeInput {
    if (!_codeInput) {
        _codeInput = [[UITextField alloc] init];
        _codeInput.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _codeInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_codeInput ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#DDDDDD"]];
        [_codeInput ssj_setBorderStyle:SSJBorderStyleBottom];
        [_codeInput ssj_setBorderWidth:1.f];
        _codeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入六位暗号" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#CCCCCC"]}];
        _codeInput.rightView = self.resendButton;
        _codeInput.rightViewMode = UITextFieldViewModeAlways;
        _codeInput.tintColor = [UIColor ssj_colorWithHex:@"#333333"];
    }
    return _codeInput;
}

- (UIButton *)resendButton {
    if (!_resendButton) {
        _resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resendButton.size = CGSizeMake(72, 24);
        _resendButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _resendButton.layer.cornerRadius = 12.f;
        _resendButton.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        _resendButton.layer.borderColor = [UIColor ssj_colorWithHex:@"#CCCCCC"].CGColor;
        [_resendButton setTitleColor:[UIColor ssj_colorWithHex:@"#CCCCCC"] forState:UIControlStateNormal];
        [_resendButton setTitle:@"随机生成" forState:UIControlStateNormal];
        [_resendButton addTarget:self action:@selector(resendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resendButton;
}

- (UILabel *)expireDateLab {
    if (!_expireDateLab) {
        _expireDateLab = [[UILabel alloc] init];
        _expireDateLab.textColor = [UIColor ssj_colorWithHex:@"#999999"];
        _expireDateLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _expireDateLab;
}

- (UILabel *)customCodeLab {
    if (!_customCodeLab) {
        _customCodeLab = [[UILabel alloc] init];
        _customCodeLab.textColor = [UIColor ssj_colorWithHex:@"#999999"];
        _customCodeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _customCodeLab.text = @"暗号可自定义哦";
        [_customCodeLab sizeToFit];
    }
    return _customCodeLab;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.size = CGSizeMake(224, 46);
        _sendButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _sendButton.layer.cornerRadius = 23.f;
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送暗号" forState:UIControlStateNormal];
        _sendButton.backgroundColor = [UIColor ssj_colorWithHex:@"#EB4A64"];
        _sendButton.layer.shadowPath = (__bridge CGPathRef _Nullable)([UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 226, 48) cornerRadius:23.f]);
        _sendButton.layer.shadowColor = [UIColor ssj_colorWithHex:@"#EB4A64"].CGColor;
        _sendButton.layer.shadowOpacity = 0.39;
    }
    return _sendButton;
}

#pragma mark - Event
- (void)resendButtonClicked:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"随机生成"]) {
        self.codeInput.text = [SSJShareBooksHelper generateTheRandomCodeWithType:SSJRandomCodeTypeUpperLetter | SSJRandomCodeTypeNumbers length:6];
    }
}


#pragma mark - Private
- (void)initHintView {
    self.hintViews = [NSMutableArray arrayWithCapacity:0];
    for (NSString *title in self.titles) {
        NSInteger index = [self.titles indexOfObject:title];
        SSJShareBooksHintView *hintView = [[SSJShareBooksHintView alloc] init];
        hintView.title = title;
        if (index == 0) {
            hintView.isFirstRow = YES;
            hintView.isLastRow = NO;
        } else if(index == self.titles.count - 1) {
            hintView.isFirstRow = NO;
            hintView.isLastRow = YES;
        } else {
            hintView.isFirstRow = NO;
            hintView.isLastRow = NO;
        }
        [self.hintViews addObject:hintView];
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
