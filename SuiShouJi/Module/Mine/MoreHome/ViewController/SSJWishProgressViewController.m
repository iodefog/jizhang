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
#import "SSJWishWithdrawMoneyViewController.h"

#import "SSJWishChargeCell.h"
#import "SSJWishProgressView.h"
#import "SSJMakeWishGuideView.h"

#import "SSJWishModel.h"
#import "SSJWishChargeItem.h"

#import "SSJWishHelper.h"
#import "SSJDataSynchronizer.h"

@interface SSJWishProgressViewController ()<UITableViewDelegate,UITableViewDataSource>
/**topBg*/
@property (nonatomic, strong) UIView *topBg;

@property (nonatomic, strong) UILabel *wishTitleL;

@property (nonatomic, strong) UILabel *saveAmountL;

@property (nonatomic, strong) UILabel *targetAmountL;

/**状态*/
@property (nonatomic, strong) UIButton *stateBtn;

/**完成心愿*/
@property (nonatomic, strong) UIButton *finishBtn;

@property (nonatomic, strong) SSJWishProgressView *wishProgressView;

/**tableView*/
@property (nonatomic, strong) UITableView *tableView;

/**底部view*/
@property (nonatomic, strong) UIView *bottomView;

/**存钱*/
@property (nonatomic, strong) UIButton *saveBtn;

/**取钱*/
@property (nonatomic, strong) UIButton *withdrawBtn;

/**头*/
@property (nonatomic, strong) UIView *tableHeaderView;

/**guild*/
@property (nonatomic, strong) SSJMakeWishGuideView *guideView;

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
    [self.topBg addSubview:self.stateBtn];
    [self.topBg addSubview:self.finishBtn];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    
    [self updateAppearanceWithTheme];
    [self updateViewConstraints];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.showWishGuide == YES) {
        [self.guideView show];
        self.showWishGuide = NO;
    }
    [self getDataFromDatabase];
}


#pragma mark - Private
- (void)getDataFromDatabase {
    if (!self.wishId.length) return;
    @weakify(self);
    
    [SSJWishHelper queryWishWithWisId:self.wishId Success:^(SSJWishModel *resultItem) {
        @strongify(self);
        //更新头
        self.wishModel = resultItem;
        [self updateDataOfTableHeaderView];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
    
    //流水列表
    [SSJWishHelper queryWishChargeListWithWishid:self.wishId success:^(NSMutableArray<SSJWishChargeItem *> *chargeArray) {
        @strongify(self);
        //处理开始结束时间以及终止时间
        SSJWishChargeItem *startItem = [[SSJWishChargeItem alloc] init];
        startItem.money = @"许下心愿";
        startItem.cbillDate = self.wishModel.startDate;
        [chargeArray addObject:startItem];
        
        if (self.wishModel.endDate.length && self.wishModel.status == SSJWishStateFinish) {
            SSJWishChargeItem *endItem = [[SSJWishChargeItem alloc] init];
            endItem.money = @"完成心愿";
            endItem.cbillDate = self.wishModel.endDate;
            [chargeArray insertObject:endItem atIndex:0];
        } else if (self.wishModel.endDate.length && self.wishModel.status == SSJWishStateTermination) {
            SSJWishChargeItem *termItem = [[SSJWishChargeItem alloc] init];
            termItem.money = @"终止心愿";
            termItem.cbillDate = self.wishModel.endDate;
            [chargeArray insertObject:termItem atIndex:0];
        }
        self.wishChargeListArr = chargeArray;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}



- (void)setUpNav {
    NSString *navStr;
    if (self.wishModel.status == SSJWishStateNormalIng) {
        navStr = @"编辑";
    } else {
        navStr = @"删除";
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:navStr style:UIBarButtonItemStylePlain target:self action:@selector(navRightClick)];
}

- (void)updateDataOfTableHeaderView {
    [self setUpNav];
    [self updateBottomView];
    self.wishTitleL.text = self.wishModel.wishName;
    self.wishProgressView.progress = [self.wishModel.wishSaveMoney doubleValue] / [self.wishModel.wishMoney doubleValue];
    self.saveAmountL.text = [NSString stringWithFormat:@"已存入：%.2lf",[self.wishModel.wishSaveMoney doubleValue]];
    self.targetAmountL.text = [NSString stringWithFormat:@"目标金额：%.2lf",[self.wishModel.wishMoney doubleValue]];
    
    if (self.wishModel.status == SSJWishStateNormalIng && [self.wishModel.wishSaveMoney doubleValue] >= [self.wishModel.wishMoney doubleValue]) {
        self.finishBtn.hidden = NO;
    } else {
        self.finishBtn.hidden = YES;
    }
    
    if (self.wishModel.status == SSJWishStateNormalIng) {//进行
        [self.stateBtn setTitle:@"进行中" forState:UIControlStateNormal];

    } else if (self.wishModel.status == SSJWishStateFinish) {//完成
        [self.stateBtn setTitle:@"完成心愿" forState:UIControlStateNormal];

    } else if (self.wishModel.status == SSJWishStateTermination) {//终止
        self.wishProgressView.progressColor = [UIColor lightGrayColor];
        [self.stateBtn setTitle:@"终止" forState:UIControlStateNormal];
    }
}

- (void)updateBottomView {
    if ([self.wishModel.wishSaveMoney doubleValue] >= [self.wishModel.wishMoney doubleValue] && self.wishModel.status == SSJWishStateNormalIng) {
        [self.bottomView ssj_setBorderWidth:1];
        [self.saveBtn ssj_setBorderWidth:1];
        [self.bottomView ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleBottom];
        [self.saveBtn ssj_setBorderStyle:SSJBorderStyleLeft];
        [self.saveBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];//ssj_setBackgroundColor
        [self.saveBtn ssj_setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self.withdrawBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
        [self.withdrawBtn ssj_setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        
    }else if (self.wishModel.status == SSJWishStateNormalIng) {//进行
        self.bottomView.hidden = NO;
        [self.bottomView ssj_setBorderWidth:0];
        [self.saveBtn ssj_setBorderWidth:1];
        [self.saveBtn ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleBottom];
        [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//ssj_setBackgroundColor
        [self.saveBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [self.withdrawBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [self.withdrawBtn ssj_setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
       
    } else if (self.wishModel.status == SSJWishStateFinish) {//完成
        self.bottomView.hidden = YES;
    } else if (self.wishModel.status == SSJWishStateTermination) {//终止
        self.bottomView.hidden = YES;
    }

}


- (void)navRightClick {
    if (self.wishModel.status == SSJWishStateNormalIng) {
        SSJWishDetailViewController *wishDetailVC = [[SSJWishDetailViewController alloc] init];
        wishDetailVC.wishModel = [self.wishModel copy];
        [self.navigationController pushViewController:wishDetailVC animated:YES];
    } else {
        @weakify(self);
        [SSJWishHelper deleteWishWithWisId:self.wishId Success:^{
            @strongify(self);
            [CDAutoHideMessageHUD showMessage:@"删除成功"];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:@"删除失败"];
        }];
    }
}


#pragma mark - Layout
- (void)updateViewConstraints {
    [self.topBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM + 13);
        make.bottom.mas_equalTo(self.targetAmountL.mas_bottom).offset(35);
    }];
    
    [self.stateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 20));
        make.centerX.mas_equalTo(self.topBg.mas_right).offset(-20);
        make.centerY.mas_equalTo(self.topBg.mas_top).offset(20);
    }];
    
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(71, 24));
        make.right.mas_equalTo(self.stateBtn.mas_left);
        make.top.mas_equalTo(15);
    }];
    
    [self.wishTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leftMargin.mas_equalTo(15);
        make.right.mas_equalTo(self.finishBtn.mas_left).offset(-5);
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
        make.width.mas_equalTo(self.targetAmountL.mas_width);
        make.top.mas_equalTo(self.wishProgressView.mas_bottom).offset(15);
        make.height.greaterThanOrEqualTo(0);
    }];
    
    [self.targetAmountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.saveAmountL.mas_right);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.saveAmountL);
        make.height.greaterThanOrEqualTo(0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.topBg.mas_bottom);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.bottom.left.right.mas_equalTo(0);
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
    self.tableHeaderView.backgroundColor = SSJ_MAIN_BACKGROUND_COLOR;
    
    [self.bottomView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [self.saveBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [self.withdrawBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [self.stateBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"999999"] forState:UIControlStateNormal];
    [self.finishBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [self.finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.stateBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.topBg.backgroundColor =SSJ_DEFAULT_BACKGROUND_COLOR;
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.topBg.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
    }
    [self.guideView updateAppearance];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wishChargeListArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self)wSelf = self;
    SSJWishChargeCell *cell = [SSJWishChargeCell cellWithTableView:tableView];
    cell.alowEdit = self.wishModel.status == SSJWishStateNormalIng;
    [cell cellLayoutWithTableView:tableView indexPath:indexPath];
    cell.cellItem = [[self.wishChargeListArr ssj_safeObjectAtIndex:indexPath.row] copy];
    cell.wishChargeEdidBlock = ^(SSJWishChargeCell *cell) {
        SSJWishChargeDetailViewController *chargeDetailVC = [[SSJWishChargeDetailViewController alloc] init];
        chargeDetailVC.chargeItem = [[wSelf.wishChargeListArr ssj_safeObjectAtIndex:indexPath.row] copy];
        chargeDetailVC.wishModel = wSelf.wishModel;
        [wSelf.navigationController pushViewController:chargeDetailVC animated:YES];
    };
    
    cell.wishChargeDeleteBlock = ^(SSJWishChargeCell *cell) {
        [SSJWishHelper deleteWishChargeWithWishChargeItem:(SSJWishChargeItem *)cell.cellItem success:^{
            [CDAutoHideMessageHUD showMessage:@"删除成功"];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            [wSelf getDataFromDatabase];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:@"删除失败"];
        }];
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
        _wishTitleL.numberOfLines = 0;
    }
    return _wishTitleL;
}

- (UIButton *)stateBtn {
    if (!_stateBtn) {
        _stateBtn = [[UIButton alloc] init];
        _stateBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _stateBtn.transform = CGAffineTransformMakeRotation(M_PI_4);
        _stateBtn.layer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    return _stateBtn;
}


- (UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [[UIButton alloc] init];
        _finishBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        CAShapeLayer *layer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 71, 24) cornerRadius:12];
        layer.path= path.CGPath;
        _finishBtn.layer.mask = layer;
        _finishBtn.hidden = YES;
        [_finishBtn setTitle:@"完成心愿" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        //完成心愿
        [[_finishBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [SSJWishHelper finishWishWithWisId:self.wishId Success:^{
                [CDAutoHideMessageHUD showMessage:@"心愿完成"];
                [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
                [weakSelf getDataFromDatabase];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }];
    }
    return _finishBtn;
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
        _targetAmountL.textAlignment = NSTextAlignmentRight;
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
        _tableView.tableHeaderView = self.tableHeaderView;
    }
    return _tableView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView addSubview:self.saveBtn];
        [_bottomView addSubview:self.withdrawBtn];
    }
    return _bottomView;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.withdrawBtn.frame), 0, SSJSCREENWITH * 2 / 3, 44)];
        _saveBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_saveBtn setTitle:@"存钱" forState:UIControlStateNormal];
        @weakify(self);
        [[_saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            SSJWishWithdrawMoneyViewController *saveVC = [[SSJWishWithdrawMoneyViewController alloc] init];
            saveVC.wishModel = [self.wishModel copy];
            saveVC.saveMoneyType = SSJSaveImgTypeCustom;
            [SSJVisibalController().navigationController pushViewController:saveVC animated:YES];
        }];
    }
    return _saveBtn;
}

- (UIButton *)withdrawBtn {
    if (!_withdrawBtn) {
        _withdrawBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SSJSCREENWITH / 3, 44)];
        _withdrawBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_withdrawBtn ssj_setBorderWidth:1];
        [_withdrawBtn ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleBottom];
        [_withdrawBtn setTitle:@"取钱" forState:UIControlStateNormal];
        @weakify(self);
        //取钱
        [[_withdrawBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
             SSJWishChargeDetailViewController *withdrawVC = [[SSJWishChargeDetailViewController alloc] init];
            withdrawVC.wishModel = [self.wishModel copy];
            [SSJVisibalController().navigationController pushViewController:withdrawVC animated:YES];
        }];
    }
    return _withdrawBtn;
}

- (SSJMakeWishGuideView *)guideView {
    if (!_guideView) {
        _guideView = [[SSJMakeWishGuideView alloc] initWithFrame:CGRectMake(0, 0, 260, 190)];
        _guideView.image = @"wish_guite_mg";
        _guideView.title = @"愿望已经开启，快去存一笔，一步步实现愿望吧～";
    }
    return _guideView;
}

- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SSJSCREENWITH, 30)];
        UIView *vLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _tableHeaderView.height)];
        vLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        vLine.centerX = SSJSCREENWITH * 0.5;
        [_tableHeaderView addSubview:vLine];
    }
    return _tableHeaderView;
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
