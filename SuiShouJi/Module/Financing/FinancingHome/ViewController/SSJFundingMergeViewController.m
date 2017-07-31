//
//  SSJFundingMergeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingMergeViewController.h"

#import "SSJBooksMergeHelper.h"

#import "SSJBooksMergeProgressButton.h"
#import "SSJFundingMergeSelectView.h"

@interface SSJFundingMergeViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SSJBooksMergeProgressButton *mergeButton;

@property (nonatomic, strong) SSJFundingMergeSelectView *transferOutFundBackView;

@property (nonatomic, strong) SSJFundingMergeSelectView *transferInFundBackView;

@property (nonatomic, strong) UIImageView *transferImage;

@property (nonatomic, strong) SSJBooksMergeHelper *mergeHelper;

@property (nonatomic, strong) NSArray *allFundsItem;

@end

@implementation SSJFundingMergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"资金账本数据";
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.mergeButton];
    [self.scrollView addSubview:self.transferInFundBackView];
    [self.scrollView addSubview:self.transferOutFundBackView];
    [self.scrollView addSubview:self.transferImage];

    // Do any additional setup after loading the view.
}

- (void)updateViewConstraints {
    
    [self.mergeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width).offset(-30);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.transferInFundBackView.mas_bottom).offset(57);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-30);
    }];
    
    [self.transferOutFundBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(SSJ_NAVIBAR_BOTTOM);
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(self.scrollView);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    
    [self.transferInFundBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferOutFundBackView.mas_bottom).offset(50);
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(self.scrollView);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    
    [self.transferImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollView);
        make.top.mas_equalTo(self.transferOutFundBackView.mas_bottom).offset(16);
    }];
    
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Getter
- (SSJBooksMergeHelper *)mergeHelper {
    if (!_mergeHelper) {
        _mergeHelper = [[SSJBooksMergeHelper alloc] init];
    }
    return _mergeHelper;
}

- (SSJFundingMergeSelectView *)transferInBookBackView {
    if (!_transferInFundBackView) {
        _transferInFundBackView = [[SSJFundingMergeSelectView alloc] init];
        _transferInFundBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _transferInFundBackView;
}

- (SSJFundingMergeSelectView *)transferOutBookBackView {
    if (!_transferOutFundBackView) {
        _transferOutFundBackView = [[SSJFundingMergeSelectView alloc] init];
        _transferOutFundBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _transferOutFundBackView;
}

- (SSJBooksMergeProgressButton *)mergeButton {
    if (!_mergeButton) {
        _mergeButton = [[SSJBooksMergeProgressButton alloc] init];
        _mergeButton.title = @"迁移";
        @weakify(self);
        _mergeButton.mergeButtonClickBlock = ^(){
            @strongify(self);
        };
        _mergeButton.layer.cornerRadius = 6.f;
    }
    return _mergeButton;
}

- (UIImageView *)transferImage {
    if (!_transferImage) {
        _transferImage = [[UIImageView alloc] init];
        _transferImage.image = [[UIImage imageNamed:@"book_transfer_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _transferImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _transferImage;
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
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
