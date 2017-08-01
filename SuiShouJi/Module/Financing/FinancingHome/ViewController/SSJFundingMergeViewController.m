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

@property (nonatomic, strong) UIImageView *warningImage;

@property (nonatomic, strong) UILabel *warningLab;

@property (nonatomic, strong) UIView *containerView;

@end

@implementation SSJFundingMergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"资金账本数据";
    [self.view addSubview:self.scrollView];
    [self.containerView addSubview:self.mergeButton];
    [self.containerView addSubview:self.transferInFundBackView];
    [self.containerView addSubview:self.transferOutFundBackView];
    [self.containerView addSubview:self.transferImage];
    [self.containerView addSubview:self.warningImage];
    [self.containerView addSubview:self.warningLab];
    [self.scrollView addSubview:self.containerView];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateTransferItem];
}

- (void)updateViewConstraints {
    
    [self.mergeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width).offset(-30);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.transferInFundBackView.mas_bottom).offset(57);
        make.bottom.mas_equalTo(self.containerView.mas_bottom).offset(-30).priorityHigh();
    }];
    
    [self.transferOutFundBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView.mas_top).offset(SSJ_NAVIBAR_BOTTOM).priorityHigh();
        make.height.mas_equalTo(160);
        make.width.mas_equalTo(self.containerView);
        make.centerX.mas_equalTo(self.containerView);
    }];
    
    [self.transferInFundBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferOutFundBackView.mas_bottom).offset(50).priorityHigh();
        make.height.mas_equalTo(160);
        make.width.mas_equalTo(self.containerView);
        make.centerX.mas_equalTo(self.containerView);
    }];
    
    [self.transferImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.transferOutFundBackView.mas_bottom).offset(16);
    }];
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(self.view);
    }];
    
    [self.warningImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferInFundBackView.mas_bottom).offset(14);
        make.left.mas_equalTo(15);
    }];
    
    [self.warningLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.warningImage);
        make.left.mas_equalTo(self.warningImage.mas_right).offset(10);
        make.right.mas_equalTo(self.containerView.mas_right).offset(-10);
    }];
    
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
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

- (SSJFundingMergeSelectView *)transferInFundBackView {
    if (!_transferInFundBackView) {
        _transferInFundBackView = [[SSJFundingMergeSelectView alloc] init];
        _transferInFundBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _transferInFundBackView;
}

- (SSJFundingMergeSelectView *)transferOutFundBackView {
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

- (UILabel *)warningLab {
    if (!_warningLab) {
        _warningLab = [[UILabel alloc] init];
        _warningLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _warningLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _warningLab.numberOfLines = 0;
        _warningLab.text = @"迁移账本，账本名称、收支类别等属性将以目标账本为准。";
    }
    return _warningLab;
}

- (UIImageView *)warningImage {
    if (!_warningImage) {
        _warningImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
    }
    return _warningImage;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

#pragma mark - Private
- (void)updateTransferItem {
    self.transferInFundBackView.fundingItem = self.transferInFundItem;
    self.transferOutFundBackView.fundingItem = self.transferOutFundItem;
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
