//
//  SSJFundingMergeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingMergeViewController.h"

#import "SSJFundAccountMergeHelper.h"

#import "SSJBooksMergeProgressButton.h"
#import "SSJFundingMergeSelectView.h"
#import "SSJCreditCardItem.h"
#import "SSJMergeFundSelectView.h"

@interface SSJFundingMergeViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SSJBooksMergeProgressButton *mergeButton;

@property (nonatomic, strong) SSJFundingMergeSelectView *transferOutFundBackView;

@property (nonatomic, strong) SSJFundingMergeSelectView *transferInFundBackView;

@property (nonatomic, strong) UIImageView *transferImage;

@property (nonatomic, strong) SSJFundAccountMergeHelper *mergeHelper;

@property (nonatomic, strong) NSArray *allFundsItem;

@property (nonatomic, strong) UIImageView *warningImage;

@property (nonatomic, strong) UILabel *warningLab;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) SSJMergeFundSelectView *transferInFundSelectView;

@property (nonatomic, strong) SSJMergeFundSelectView *transferOutFundSelectView;

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
        make.size.mas_equalTo(CGSizeMake(16, 14));
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
- (SSJFundAccountMergeHelper *)mergeHelper {
    if (!_mergeHelper) {
        _mergeHelper = [[SSJFundAccountMergeHelper alloc] init];
    }
    return _mergeHelper;
}

- (SSJFundingMergeSelectView *)transferInFundBackView {
    if (!_transferInFundBackView) {
        _transferInFundBackView = [[SSJFundingMergeSelectView alloc] init];
        _transferInFundBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _transferInFundBackView.selectable = self.transferInSelectable;
        @weakify(self);
        _transferInFundBackView.fundSelectBlock = ^{
            @strongify(self);
            self.transferInFundSelectView.fundsArr = [self.mergeHelper getFundingsWithType:self.isCreditCardOrNot exceptFundItem:self.transferOutFundItem];
            [self.transferInFundSelectView showWithSelectedItem:self.transferInFundItem];
        };
    }
    return _transferInFundBackView;
}

- (SSJFundingMergeSelectView *)transferOutFundBackView {
    if (!_transferOutFundBackView) {
        _transferOutFundBackView = [[SSJFundingMergeSelectView alloc] init];
        _transferOutFundBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _transferOutFundBackView.selectable = self.transferOutSelectable;
        @weakify(self);
        _transferOutFundBackView.fundSelectBlock = ^{
            @strongify(self);
            self.transferOutFundSelectView.fundsArr = [self.mergeHelper getFundingsWithType:self.isCreditCardOrNot exceptFundItem:self.transferInFundItem];
            [self.transferOutFundSelectView showWithSelectedItem:self.transferOutFundItem];
        };
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
            [self mergeFunds];
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
        _warningLab.text = @"资金账户数据迁移，账户属性将以目标资金账户为准。";
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

- (SSJMergeFundSelectView *)transferInFundSelectView {
    if (!_transferInFundSelectView) {
        _transferInFundSelectView = [[SSJMergeFundSelectView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 250)];
        @weakify(self);
        _transferInFundSelectView.didSelectFundItem = ^(SSJBaseCellItem *fundItem) {
            @strongify(self);
            self.transferInFundItem = fundItem;
            [self updateTransferItem];
        };
    }
    return _transferInFundSelectView;
}

- (SSJMergeFundSelectView *)transferOutFundSelectView {
    if (!_transferOutFundSelectView) {
        _transferOutFundSelectView = [[SSJMergeFundSelectView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 250)];
        @weakify(self);
        _transferOutFundSelectView.didSelectFundItem = ^(SSJBaseCellItem *fundItem) {
            @strongify(self);
            self.transferOutFundItem = fundItem;
            [self updateTransferItem];
        };
    }
    return _transferOutFundSelectView;
}

#pragma mark - Event
- (void)mergeFunds {
    NSString *sourceFundId;
    
    NSString *targetFundId;

    
    if ([_transferInFundItem isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)_transferOutFundItem;
        sourceFundId = fundingItem.fundingID;
    } else if ([_transferInFundItem isKindOfClass:[SSJCreditCardItem class]]) {
        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)_transferOutFundItem;
        sourceFundId = cardItem.cardId;
    }
    
    if ([_transferOutFundItem isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)_transferInFundItem;
        targetFundId = fundingItem.fundingID;
    } else if ([_transferInFundItem isKindOfClass:[SSJCreditCardItem class]]) {
        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)_transferInFundItem;
        targetFundId = cardItem.cardId;
    }
    
    if (!self.transferInFundItem) {
        [CDAutoHideMessageHUD showMessage:@"请选择转入账本"];
        return;
    }
    
    if (!self.transferOutFundItem) {
        [CDAutoHideMessageHUD showMessage:@"请选择转出账本"];
        return;
    }
    @weakify(self);
    [self.mergeButton startAnimating];
    [self.mergeHelper startMergeWithSourceFundId:sourceFundId targetFundId:targetFundId needToDelete:self.needToDelete Success:^{
        @strongify(self);
        self.mergeButton.progressDidCompelete = YES;
        self.mergeButton.isSuccess = YES;
        if (self.needToDelete) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        self.mergeButton.progressDidCompelete = YES;
        self.mergeButton.isSuccess = NO;
        [SSJAlertViewAdapter showError:error];
    }];
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
