//
//  SSJWishProgressViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishProgressViewController.h"
#import "SSJWishDetailViewController.h"
#import "SSJWishChargeDetailViewController.h"

#import "SSJWishChargeCell.h"
#import "SSJWishProgressView.h"

#import "SSJWishModel.h"
#import "SSJWishChargeItem.h"

#import "SSJWishHelper.h"

@interface SSJWishProgressViewController ()<UITableViewDelegate,UITableViewDataSource>
/**topBg*/
@property (nonatomic, strong) UIView *topBg;

@property (nonatomic, strong) UILabel *wishTitleL;

@property (nonatomic, strong) UILabel *saveAmountL;

@property (nonatomic, strong) UILabel *targetAmountL;

@property (nonatomic, strong) SSJWishProgressView *wishProgressView;

/**tableView*/
@property (nonatomic, strong) UITableView *tableView;

/**model*/
@property (nonatomic, strong) SSJWishModel *wishModel;

/**心愿流水*/
@property (nonatomic, strong) NSMutableArray <SSJWishChargeItem *> *wishChargeListArr;

@end

@implementation SSJWishProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"心愿进度";
    
    [self.view addSubview:self.topBg];
    [self.topBg addSubview:self.wishTitleL];
    [self.topBg addSubview:self.wishProgressView];
    [self.topBg addSubview:self.saveAmountL];
    [self.topBg addSubview:self.targetAmountL];
    [self.view addSubview:self.tableView];
    [self setUpNav];
    [self updateAppearanceWithTheme];
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    @weakify(self);
    [SSJWishHelper queryWishWithWisId:self.wishId Success:^(SSJWishModel *resultItem) {
        @strongify(self);
        //更新头
        self.wishModel = resultItem;
        [self updateDataOfTableHeaderView];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
    
    
}

#pragma mark - Private
- (void)setUpNav {
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(navRightClick)];
}

- (void)updateDataOfTableHeaderView {
    self.wishTitleL.text = self.wishModel.wishName;
    self.wishProgressView.progress = [self.wishModel.wishSaveMoney doubleValue] / [self.wishModel.wishMoney doubleValue];
    self.saveAmountL.text = [NSString stringWithFormat:@"已存入：%.2lf",[self.wishModel.wishSaveMoney doubleValue]];
    self.targetAmountL.text = [NSString stringWithFormat:@"目标金额：%.2lf",[self.wishModel.wishMoney doubleValue]];
}


- (void)navRightClick {
    SSJWishDetailViewController *wishDetailVC = [[SSJWishDetailViewController alloc] init];
    wishDetailVC.wishModel = self.wishModel;
    [self.navigationController pushViewController:wishDetailVC animated:YES];
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [self.topBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM + 13);
        make.bottom.mas_equalTo(self.targetAmountL.mas_bottom).offset(35);
    }];
    
    [self.wishTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leftMargin.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.lessThanOrEqualTo(@50);
        make.top.mas_equalTo(15);
        make.height.greaterThanOrEqualTo(@22);
    }];
    
    [self.wishProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(37);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.wishTitleL.mas_bottom).offset(25);
    }];
    
    [self.saveAmountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.wishTitleL);
        make.width.mas_equalTo(self.wishTitleL.mas_width).multipliedBy(0.5);
        make.top.mas_equalTo(self.wishProgressView.mas_bottom).offset(15);
        make.height.greaterThanOrEqualTo(0);
    }];
    
    [self.targetAmountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.saveAmountL.mas_right);
        make.width.top.mas_equalTo(self.saveAmountL);
        make.height.greaterThanOrEqualTo(0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(self.topBg.mas_bottom);
    }];
    [super updateViewConstraints];
}
#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearanceWithTheme];
}

- (void)updateAppearanceWithTheme {
    self.wishTitleL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.saveAmountL.textColor = self.targetAmountL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.topBg.backgroundColor =SSJ_DEFAULT_BACKGROUND_COLOR;
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.topBg.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.wishChargeListArr.count;
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self)wSelf = self;
    SSJWishChargeCell *cell = [SSJWishChargeCell cellWithTableView:tableView indexPath:indexPath];
    cell.wishChargeEdidBlock = ^(SSJWishChargeCell *cell) {
        SSJWishChargeDetailViewController *chargeDetailVC = [[SSJWishChargeDetailViewController alloc] init];
        [wSelf.navigationController pushViewController:chargeDetailVC animated:YES];
    };
    
    cell.wishChargeDelegateBlock = ^(SSJWishChargeCell *cell) {
        
    };
    
    return cell;
}


#pragma mark - Lazy

- (UIView *)topBg {
    if (!_topBg) {
        _topBg = [[UIView alloc] init];
        _topBg.layer.cornerRadius = 8;
        _topBg.layer.masksToBounds = YES;
    }
    return _topBg;
}

- (UILabel *)wishTitleL {
    if (!_wishTitleL) {
        _wishTitleL = [[UILabel alloc] init];
        _wishTitleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _wishTitleL;
}

- (SSJWishProgressView *)wishProgressView {
    if (!_wishProgressView) {
        _wishProgressView = [[SSJWishProgressView alloc] initWithFrame:CGRectZero proColor:[UIColor ssj_colorWithHex:@"#FFBB3C"] trackColor:[UIColor whiteColor]];
    }
    return _wishProgressView;
}

- (UILabel *)saveAmountL {
    if (!_saveAmountL) {
        _saveAmountL = [[UILabel alloc] init];
        _saveAmountL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _saveAmountL;
}

- (UILabel *)targetAmountL {
    if (!_targetAmountL) {
        _targetAmountL = [[UILabel alloc] init];
        _targetAmountL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _targetAmountL;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 56;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

- (NSMutableArray<SSJWishChargeItem *> *)wishChargeListArr {
    if (!_wishChargeListArr) {
        _wishChargeListArr = [NSMutableArray array];
    }
    return _wishChargeListArr;
}

- (SSJWishModel *)wishModel {
    if (!_wishModel) {
        _wishModel = [[SSJWishModel alloc] init];
    }
    return _wishModel;
}
@end
