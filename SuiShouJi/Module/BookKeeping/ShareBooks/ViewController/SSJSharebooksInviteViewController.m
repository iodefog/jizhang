
//
//  SSJSharebooksInviteViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSharebooksInviteViewController.h"
#import "SSJSHareBooksHintView.h"

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

@end

@implementation SSJSharebooksInviteViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"暗号添加成员";
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"sharebk_backgroud"];
    self.titles = @[@"发送暗号给好友",@"对方打开有鱼记账App V2.5 以上版本",@"好友添加共享账本时，输入暗号",@"大功告成～"];
    [self.view addSubview:self.backView];
    [self.backView addSubview:self.codeInput];
    [self.backView addSubview:self.customCodeLab];
    [self.backView addSubview:self.expireDateLab];
    [self.backView addSubview:self.codeTitleLab];
    [self.backView addSubview:self.codeLeftImage];
    [self.backView addSubview:self.codeRightImage];
    [self.view addSubview:self.sendButton];
    for (SSJSHareBooksHintView *hintView in self.hintViews) {
        [self.view addSubview:hintView];
    }
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    self.backView.centerX = self.view.width / 2;
    self.backView.top = 30;
    self.backView.size = CGSizeMake(self.view.width - 35, 255);
    self.codeTitleLab.centerX = self.backView.centerX;
    self.codeTitleLab.top = 30;
    
}

#pragma mark - Getter

#pragma mark - Private
- (void)initHintView {
    for (NSString *title in self.titles) {
        self.hintViews = [NSMutableArray arrayWithCapacity:0];
        NSInteger index = [self.titles indexOfObject:title];
        SSJSHareBooksHintView *hintView = [[SSJSHareBooksHintView alloc] init];
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
