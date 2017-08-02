//
//  SSJBooksMergeViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksMergeViewController.h"
#import "UIViewController+MMDrawerController.h"

#import "SSJBooksMergeHelper.h"

#import "SSJBooksMergeProgressButton.h"
#import "SSJBooksTransferSelectView.h"
#import "SSJBooksSelectView.h"

@interface SSJBooksMergeViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SSJBooksMergeProgressButton *mergeButton;

@property (nonatomic, strong) SSJBooksTransferSelectView *transferOutBookBackView;

@property (nonatomic, strong) SSJBooksTransferSelectView *transferInBookBackView;

@property (nonatomic, strong) UIImageView *transferImage;

@property (nonatomic, strong) SSJBooksMergeHelper *mergeHelper;

@property (nonatomic, strong) NSArray *allBooksItem;

@property (nonatomic, strong) SSJBooksSelectView *booksSelectView;

@property (nonatomic, strong) UIImageView *warningImage;

@property (nonatomic, strong) UILabel *warningLab;

@property (nonatomic, strong) UIView *containerView;

@end

@implementation SSJBooksMergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"迁移账本数据";
    [self.view addSubview:self.scrollView];
//    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.mergeButton];
    [self.containerView addSubview:self.transferOutBookBackView];
    [self.containerView addSubview:self.transferInBookBackView];
    [self.containerView addSubview:self.transferImage];
    [self.containerView addSubview:self.warningImage];
    [self.containerView addSubview:self.warningLab];
    [self.scrollView addSubview:self.containerView];

    
    [self.view setNeedsUpdateConstraints];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateWithBookData];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

- (void)updateViewConstraints {
    [self.mergeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width).offset(-30);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.transferInBookBackView.mas_bottom).offset(57);
        make.bottom.mas_equalTo(self.containerView.mas_bottom).offset(-30).priorityHigh();
    }];
    
    [self.transferOutBookBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView.mas_top).offset(SSJ_NAVIBAR_BOTTOM).priorityHigh();
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(self.containerView);
        make.centerX.mas_equalTo(self.containerView);
    }];
    
    [self.transferInBookBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferOutBookBackView.mas_bottom).offset(50).priorityHigh();
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(self.containerView);
        make.centerX.mas_equalTo(self.containerView);
    }];
    
    [self.transferImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.transferOutBookBackView.mas_bottom).offset(16);
    }];
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(self.view);
    }];
    
    [self.warningImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 14));
        make.top.mas_equalTo(self.transferInBookBackView.mas_bottom).offset(14);
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

- (SSJBooksTransferSelectView *)transferInBookBackView {
    if (!_transferInBookBackView) {
        _transferInBookBackView = [[SSJBooksTransferSelectView alloc] initWithFrame:CGRectZero type:SSJBooksTransferViewTypeTransferIn];
        _transferInBookBackView.selectable = self.transferInSelectable;
        _transferInBookBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        @weakify(self);
        _transferInBookBackView.transferInSelectButtonClick = ^{
            @strongify(self);
            NSArray *allBooks = [self.mergeHelper getAllBooksItemWithExceptionId:self.transferOutBooksItem.booksId];
            if (!allBooks.count) {
                [CDAutoHideMessageHUD showMessage:@"你还没有其他账本哦,可以先添加一个账本"];
            } else {
                self.booksSelectView.booksItems = [self.mergeHelper getAllBooksItemWithExceptionId:self.transferOutBooksItem.booksId];
                [self.booksSelectView showWithSelectedItem:self.transferInBooksItem];
            }
        };
    }
    return _transferInBookBackView;
}

- (SSJBooksTransferSelectView *)transferOutBookBackView {
    if (!_transferOutBookBackView) {
        _transferOutBookBackView = [[SSJBooksTransferSelectView alloc] initWithFrame:CGRectZero type:SSJBooksTransferViewTypeTransferOut];
        _transferOutBookBackView.selectable = self.transferOutSelectable;
        _transferOutBookBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        @weakify(self);
        _transferOutBookBackView.transferInSelectButtonClick = ^{
            @strongify(self);
            NSArray *allBooks = [self.mergeHelper getAllBooksItemWithExceptionId:self.transferInBooksItem.booksId];
            if (!allBooks.count) {
                [CDAutoHideMessageHUD showMessage:@"你还没有其他账本哦,可以先添加一个账本"];
            } else {
                self.booksSelectView.booksItems = [self.mergeHelper getAllBooksItemWithExceptionId:self.transferInBooksItem.booksId];
                [self.booksSelectView showWithSelectedItem:self.transferOutBooksItem];
            }
        };
    }
    return _transferOutBookBackView;
}

- (SSJBooksMergeProgressButton *)mergeButton {
    if (!_mergeButton) {
        _mergeButton = [[SSJBooksMergeProgressButton alloc] init];
        _mergeButton.title = @"迁移";
        @weakify(self);
        _mergeButton.mergeButtonClickBlock = ^(){
            @strongify(self);
            [self mergeBooks];
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

- (SSJBooksSelectView *)booksSelectView {
    if (!_booksSelectView) {
        _booksSelectView = [[SSJBooksSelectView alloc] init];
        @weakify(self);
        _booksSelectView.booksTypeSelectBlock = ^(SSJBaseCellItem<SSJBooksItemProtocol> *item) {
            @strongify(self);
            self.transferInBooksItem = item;
            [self updateWithBookData];
        };
    }
    return _booksSelectView;
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
- (void)updateWithBookData {
    if (!self.transferOutBooksItem) {
        SSJPRINT(@"转出账户不能为空");
    }
    
    NSNumber *transfeOutChargeCount = [self.mergeHelper getChargeCountForBooksId:self.transferOutBooksItem.booksId];
    
    NSNumber *transfeInChargeCount = [self.mergeHelper getChargeCountForBooksId:self.transferInBooksItem.booksId];
    
    self.transferOutBookBackView.chargeCount = transfeOutChargeCount;
    
    self.transferInBookBackView.chargeCount = transfeInChargeCount;
    
    self.transferOutBookBackView.booksTypeItem = self.transferOutBooksItem;
    
    self.transferInBookBackView.booksTypeItem = self.transferInBooksItem;
    
}

- (void)mergeBooks {
    if (!self.transferInBooksItem.booksId.length) {
        [CDAutoHideMessageHUD showMessage:@"请选择转入账本"];
        return;
    }
    @weakify(self);
    [self.mergeButton startAnimating];
    [self.mergeHelper startMergeWithSourceBooksId:self.transferOutBooksItem.booksId targetBooksId:self.transferInBooksItem.booksId Success:^{
        @strongify(self);
        self.mergeButton.progressDidCompelete = YES;
        self.mergeButton.isSuccess = YES;
        [self updateWithBookData];
    } failure:^(NSError *error) {
        self.mergeButton.progressDidCompelete = YES;
        self.mergeButton.isSuccess = NO;
        [SSJAlertViewAdapter showError:error];
    }];
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
