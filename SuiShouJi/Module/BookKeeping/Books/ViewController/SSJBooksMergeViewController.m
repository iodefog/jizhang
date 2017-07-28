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

@end

@implementation SSJBooksMergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"迁移账本数据";
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.mergeButton];
    [self.scrollView addSubview:self.transferOutBookBackView];
    [self.scrollView addSubview:self.transferInBookBackView];
    [self.scrollView addSubview:self.transferImage];
    
    [self.view updateConstraintsIfNeeded];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateWithBookData];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

- (void)updateViewConstraints {
    [self.mergeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view.mas_width).offset(-30);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.transferInBookBackView.mas_bottom).offset(57);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-30);
    }];
    
    [self.transferOutBookBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_top).offset(SSJ_NAVIBAR_BOTTOM);
        make.height.mas_equalTo(190);
        make.width.mas_equalTo(self.scrollView);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    
    [self.transferInBookBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferOutBookBackView.mas_bottom).offset(50);
        make.height.mas_equalTo(190);
        make.width.mas_equalTo(self.scrollView);
        make.centerX.mas_equalTo(self.scrollView);
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

- (SSJBooksTransferSelectView *)transferInBookBackView {
    if (!_transferInBookBackView) {
        _transferInBookBackView = [[SSJBooksTransferSelectView alloc] initWithFrame:CGRectZero type:SSJBooksTransferViewTypeTransferIn];
        _transferInBookBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        @weakify(self);
        _transferInBookBackView.transferInSelectButtonClick = ^{
            @strongify(self);
            NSArray *allBooks = [self.mergeHelper getAllBooksItemWithExceptionId:self.transferOutBooksItem.booksId];
            if (!allBooks.count) {
                [CDAutoHideMessageHUD showMessage:@""];
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
        _transferOutBookBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _transferOutBookBackView;
}

- (SSJBooksMergeProgressButton *)mergeButton {
    if (!_mergeButton) {
        _mergeButton = [[SSJBooksMergeProgressButton alloc] init];
        
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

#pragma mark - Private
- (void)updateWithBookData {
    if (!self.transferOutBooksItem) {
        SSJPRINT(@"转出账户不能为空");
    }
    
    NSNumber *chargeCount = [self.mergeHelper getChargeCountForBooksId:self.transferOutBooksItem.booksId];
    
    self.transferOutBookBackView.chargeCount = chargeCount;
    
    self.transferOutBookBackView.booksTypeItem = self.transferOutBooksItem;
    
    self.transferInBookBackView.booksTypeItem = self.transferInBooksItem;
    
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
