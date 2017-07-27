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
#import "SSJBooksView.h"

@interface SSJBooksMergeViewController ()

@property (nonatomic, strong) SSJBooksMergeProgressButton *mergeButton;

@property (nonatomic, strong) UIView *transferOutBookBackView;

@property (nonatomic, strong) UIView *transferInBookBackView;

@property (nonatomic, strong) SSJBooksView *transferInBookView;

@property (nonatomic, strong) SSJBooksView *transferOutBookView;

@property (nonatomic, strong) UILabel *chargeCountTitleLab;

@property (nonatomic, strong) UILabel *chargeCountLab;

@property (nonatomic, strong) UILabel *bookTypeTitleLab;

@property (nonatomic, strong) UILabel *bookTypeLab;

@property (nonatomic, strong) UIButton *transferInButton;

@property (nonatomic, strong) UILabel *transferInLab;

@property (nonatomic, strong) UILabel *transferInNameLab;

@property (nonatomic, strong) UIImageView *transferImage;

@property (nonatomic, strong) UIImageView *arrowImage;

@property (nonatomic, strong) SSJBooksMergeHelper *mergeHelper;

@end

@implementation SSJBooksMergeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mergeButton];
    [self.view addSubview:self.transferOutBookBackView];
    [self.view addSubview:self.transferInBookBackView];
    [self.view addSubview:self.chargeCountTitleLab];
    [self.view addSubview:self.chargeCountLab];
    [self.view addSubview:self.bookTypeTitleLab];
    [self.view addSubview:self.bookTypeLab];
    [self.view addSubview:self.transferInButton];
    [self.transferInButton addSubview:self.transferInLab];
    [self.transferInButton addSubview:self.transferInNameLab];
    [self.view addSubview:self.transferImage];
    [self.transferInButton addSubview:self.arrowImage];
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
    }];
    
    [self.transferOutBookBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(SSJ_NAVIBAR_BOTTOM);
        make.height.mas_equalTo(190);
        make.width.mas_equalTo(self.view);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.transferInBookBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferOutBookBackView.mas_bottom).offset(50);
        make.height.mas_equalTo(190);
        make.width.mas_equalTo(self.view);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.transferInBookView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferInBookBackView.mas_top).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 110));
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.transferOutBookView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferOutBookBackView.mas_top).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 110));
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.chargeCountTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.transferOutBookBackView.mas_bottom).offset(-29);
        make.left.mas_equalTo(32);
    }];
    
    [self.chargeCountLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.chargeCountTitleLab.mas_centerY);
        make.left.mas_equalTo(self.chargeCountTitleLab.mas_right).offset(5);
    }];

    
    [self.bookTypeTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.transferOutBookBackView.mas_bottom).offset(-29);
        make.right.mas_equalTo(self.bookTypeLab.mas_left).offset(-5);
    }];
    
    
    [self.bookTypeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bookTypeTitleLab.mas_centerY);
        make.right.mas_equalTo(self.view.mas_right).offset(-32);
    }];
    
    [self.transferInButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.transferInBookBackView.mas_bottom);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(55);
        make.right.mas_equalTo(self.view);
    }];
    
    [self.transferInLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.transferInButton.mas_centerY);
        make.left.mas_equalTo(self.transferInButton.mas_left).offset(15);
    }];
    
    [self.transferInNameLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.transferInButton.mas_centerY);
        make.right.mas_equalTo(self.arrowImage.mas_left).offset(-10);
    }];
    
    [self.arrowImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.transferInButton.mas_centerY);
        make.right.mas_equalTo(self.transferInButton.mas_right).offset(-15);
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

- (UIView *)transferInBookBackView {
    if (!_transferInBookBackView) {
        _transferInBookBackView = [[UIView alloc] init];
        _transferInBookBackView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _transferInBookBackView;
}

- (UIView *)transferOutBookBackView {
    if (!_transferOutBookBackView) {
        _transferOutBookBackView = [[UIView alloc] init];
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

- (UILabel *)chargeCountTitleLab {
    if (!_chargeCountTitleLab) {
        _chargeCountTitleLab = [[UILabel alloc] init];
        _chargeCountTitleLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
        _chargeCountTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _chargeCountTitleLab.text = @"账本流水：";
    }
    return _chargeCountTitleLab;
}

- (UILabel *)chargeCountLab {
    if (!_chargeCountLab) {
        _chargeCountLab = [[UILabel alloc] init];
        _chargeCountLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _chargeCountLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _chargeCountLab;
}

- (UILabel *)bookTypeLab {
    if (!_bookTypeLab) {
        _bookTypeLab = [[UILabel alloc] init];
        _bookTypeLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _bookTypeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _bookTypeLab;
}

- (UILabel *)bookTypeTitleLab {
    if (!_bookTypeTitleLab) {
        _bookTypeTitleLab = [[UILabel alloc] init];
        _bookTypeTitleLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
        _bookTypeTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _bookTypeTitleLab.text = @"账本属性：";
    }
    return _bookTypeTitleLab;
}

- (UILabel *)transferInLab {
    if (!_transferInLab) {
        _transferInLab = [[UILabel alloc] init];
        _transferInLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _transferInLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _transferInLab.text = @"请选择账本";
    }
    return _transferInLab;
}


- (UILabel *)transferInNameLab {
    if (!_transferInNameLab) {
        _transferInNameLab = [[UILabel alloc] init];
        _transferInNameLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
        _transferInNameLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _transferInNameLab;
}

- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] init];
        _arrowImage.image = [[UIImage imageNamed:@"book_transfer_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor];
    }
    return _arrowImage;
}

- (UIImageView *)transferImage {
    if (!_transferImage) {
        _transferImage = [[UIImageView alloc] init];
        _transferImage.image = [[UIImage imageNamed:@"book_transfer_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _transferImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _transferImage;
}

- (UIButton *)transferInButton {
    if (!_transferInButton) {
        _transferInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_transferInButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
        [_transferInButton ssj_setBorderWidth:1];
        [_transferInButton ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _transferInButton;
}


#pragma mark - Private
- (void)updateWithBookData {
    if (!self.transferOutBooksItem) {
        SSJPRINT(@"转出账户不能为空");
    }
    
    NSNumber *chargeCount = [self.mergeHelper getChargeCountForBooksId:self.transferOutBooksItem.booksId];
    
    self.chargeCountLab.text = [NSString stringWithFormat:@"%@条",chargeCount];
    
    self.bookTypeLab.text = [NSString stringWithFormat:@"%@",[self.transferOutBooksItem parentName]];
    
    
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
