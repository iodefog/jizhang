 //
//  SSJMakeWishViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMakeWishViewController.h"
#import "SSJWishPhotoChooseViewController.h"
#import "SSJWishProgressViewController.h"

#import "TPKeyboardAvoidingScrollView.h"
#import "SSJMakeWishMoneyCollectionViewCell.h"
#import "SSJWishTableViewCell.h"

#import "SSJWishModel.h"
#import "SSJWishDefItem.h"

#import "SSJWishHelper.h"

static NSString *wishMoneyCellId = @"SSJMakeWishMoneyCollectionViewCellId";
@interface SSJMakeWishViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>


@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;
/**topImg*/
@property (nonatomic, strong) UIImageView *topImg;

/**图片蒙层*/
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UILabel *slognL;

@property (nonatomic, strong) UIButton *cameraImg;

@property (nonatomic, strong) UILabel *wishTitleL;

@property (nonatomic, strong) UITextField *wishNameTextF;

/**bg*/
@property (nonatomic, strong) UIView *topBg;

/**心愿列表*/
@property (nonatomic, strong) UITableView *wishListTableView;

@property (nonatomic, strong) UILabel *wishAmountL;

@property (nonatomic, strong) UITextField *wishAmountTextF;

@property (nonatomic, strong) UICollectionView *moneyCollectionView;

/**bottomBg*/
@property (nonatomic, strong) UIView *bottomBg;

@property (nonatomic, strong) UIButton *makeWishBtn;

/**心愿列表数据源*/
@property (nonatomic, strong) NSMutableArray <SSJWishDefItem *>*wishListDataArray;

/**心愿列表数据源*/
@property (nonatomic, strong) NSArray *wishMoneyDataArray;

/**model*/
@property (nonatomic, strong) SSJWishModel *wishModel;
@end

@implementation SSJMakeWishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"许下心愿";
    [self setUpUI];
    [self appearanceWithTheme];
    [self signalBind];
    [self initNormalData];
}

- (void)setUpUI {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topImg];
    [self.topImg addSubview:self.coverView];
    [self.topImg addSubview:self.slognL];
    [self.topImg addSubview:self.cameraImg];
    
    [self.scrollView addSubview:self.wishAmountL];
    [self.scrollView addSubview:self.bottomBg];
    [self.bottomBg addSubview:self.wishAmountTextF];
    [self.bottomBg addSubview:self.moneyCollectionView];

    [self.scrollView addSubview:self.wishTitleL];
    [self.scrollView addSubview:self.topBg];
    [self.topBg addSubview:self.wishNameTextF];
    [self.topBg addSubview:self.wishListTableView];
    
    [self.scrollView addSubview:self.makeWishBtn];
}

- (void)initNormalData {
    self.wishMoneyDataArray = @[@"2000",@"5000",@"10000",@"100000"];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    self.topImg.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, kFinalImgHeight(self.view.width));
    self.coverView.frame = self.topImg.bounds;
    self.slognL.centerX = self.topImg.centerX;
    self.slognL.centerY = self.topImg.height * 0.5;
    self.cameraImg.rightTop = CGPointMake(self.view.width - 15, 15);
    self.cameraImg.size = CGSizeMake(50, 50);
    self.wishTitleL.leftTop = CGPointMake(15, CGRectGetMaxY(self.topImg.frame) + 25);
    self.topBg.frame = CGRectMake(15, CGRectGetMaxY(self.wishTitleL.frame)+10, self.view.width - 30, 44);
    self.wishNameTextF.frame = CGRectMake(15, 0, self.topBg.width - 30, 44);
    self.wishListTableView.frame = CGRectMake(15, CGRectGetMaxY(self.wishNameTextF.frame), self.wishNameTextF.width, self.wishListDataArray.count * 38);
    self.wishAmountL.leftTop = CGPointMake(15, CGRectGetMaxY(self.wishTitleL.frame) + 85);
    self.bottomBg.frame = CGRectMake(15, CGRectGetMaxY(self.wishAmountL.frame)+10, self.view.width - 30, 44);
    self.wishAmountTextF.frame = CGRectMake(15, 0, self.bottomBg.width - 30, 44);
    self.moneyCollectionView.frame = CGRectMake(15, CGRectGetMaxY(self.wishAmountTextF.frame), self.wishAmountTextF.width, 67);
    self.makeWishBtn.frame = CGRectMake(15, SSJSCREENHEIGHT - 115, self.view.width - 30, 44);
}
//[self.iconView sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(data.iconUrl)] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
#pragma mark - Private
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self appearanceWithTheme];
}

- (void)appearanceWithTheme {
    self.wishTitleL.textColor = self.wishAmountL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    self.wishNameTextF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入心愿" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    self.wishAmountTextF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"完成心愿所需金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    
    self.wishNameTextF.textColor = self.wishAmountTextF.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    [self.makeWishBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [self.makeWishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.makeWishBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:SSJButtonDisableAlpha] forState:UIControlStateSelected];
    
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.bottomBg.backgroundColor = self.topBg.backgroundColor =SSJ_DEFAULT_BACKGROUND_COLOR;
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.bottomBg.backgroundColor = self.topBg.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
    }
}

- (void)signalBind {
    RACSignal *signal = [RACSignal combineLatest:@[RACObserve(self, wishNameTextF.text),RACObserve(self, wishAmountTextF.text)] reduce:^id(NSString *name, NSString *money) {
        return @(name.length && money.length);
    }];
    RAC(self.makeWishBtn,enabled) = signal;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wishListDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJWishTableViewCell *cell = [SSJWishTableViewCell cellWithTableView:tableView];
    cell.cellItem = [self.wishListDataArray ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.wishModel.wishType = indexPath.row + 1;
    SSJWishDefItem *item = [self.wishListDataArray ssj_safeObjectAtIndex:indexPath.row];
    if (item.wishMoney.length) {
        self.wishAmountTextF.text = item.wishMoney;
    }
    if (item.wishName.length) {
        self.wishNameTextF.text = item.wishName;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.width - 120)/4, 25);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *amount = [self.wishMoneyDataArray ssj_safeObjectAtIndex:indexPath.row];
    self.wishAmountTextF.text = amount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.wishMoneyDataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJMakeWishMoneyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:wishMoneyCellId forIndexPath:indexPath];
    cell.layer.cornerRadius = 6;
    cell.layer.masksToBounds = YES;
    cell.amontStr = [self.wishMoneyDataArray ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.wishNameTextF) {
        [UIView animateWithDuration:0.1 animations:^{
            self.topBg.height = CGRectGetMaxY(self.wishListTableView.frame);
        }];
    } else if(self.wishAmountTextF) {
        [UIView animateWithDuration:0.1 animations:^{
            self.bottomBg.height = CGRectGetMaxY(self.moneyCollectionView.frame);
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.wishNameTextF) {
        [UIView animateWithDuration:0.1 animations:^{
            self.topBg.height = CGRectGetMaxY(self.wishNameTextF.frame);
        }];
    } else if(textField == self.wishAmountTextF) {
        //textField.clearsOnInsertion = YES;
        [UIView animateWithDuration:0.1 animations:^{
            self.bottomBg.height = CGRectGetMaxY(self.wishAmountTextF.frame);
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.wishAmountTextF == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
    }
    return YES;
}

#pragma mark - Lazy
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
    }
    return _scrollView;
}

- (UIImageView *)topImg {
    if (!_topImg) {
        _topImg = [[UIImageView alloc] init];
        _topImg.image = [UIImage imageNamed:@"wish_image_def"];
        _topImg.userInteractionEnabled = YES;
    }
    return _topImg;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor ssj_colorWithHex:@"000000" alpha:0.3];
    }
    return _coverView;
}

- (UILabel *)slognL {
    if (!_slognL) {
        _slognL = [[UILabel alloc] init];
        _slognL.text = @"许下心愿  为心愿存钱";
        _slognL.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_1];
        _slognL.textColor = [UIColor whiteColor];
        [_slognL sizeToFit];
    }
    return _slognL;
}

- (UIButton *)cameraImg {
    if (!_cameraImg) {
        _cameraImg = [[UIButton alloc] init];
        [_cameraImg setImage:[UIImage imageNamed:@"wish_bg_camera"] forState:UIControlStateNormal];
        @weakify(self);
        [[_cameraImg rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            SSJWishPhotoChooseViewController *photoVC = [[SSJWishPhotoChooseViewController alloc] init];
            @weakify(self);
            photoVC.changeTopImage = ^(UIImage *seleImg) {
                @strongify(self);
                //切换背景
                self.topImg.image = seleImg;
                [self.navigationController popViewControllerAnimated:YES];
            };
            
            [self.navigationController pushViewController:photoVC animated:YES];
            
        }];
    }
    return _cameraImg;
}

- (UILabel *)wishTitleL {
    if (!_wishTitleL) {
        _wishTitleL = [[UILabel alloc] init];
        _wishTitleL.text = @"我的心愿";
        _wishTitleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_wishTitleL sizeToFit];
    }
    return _wishTitleL;
}

- (UITextField *)wishNameTextF {
    if (!_wishNameTextF) {
        _wishNameTextF = [[UITextField alloc] init];
        _wishNameTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _wishNameTextF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _wishNameTextF.delegate = self;
    }
    return _wishNameTextF;
}

- (UIView *)topBg {
    if (!_topBg) {
        _topBg = [[UIView alloc] init];
        _topBg.layer.cornerRadius = 6;
        _topBg.layer.masksToBounds = YES;
    }
    return _topBg;
}

- (UITableView *)wishListTableView {
    if (!_wishListTableView) {
        _wishListTableView = [[UITableView alloc] init];
        _wishListTableView.delegate = self;
        _wishListTableView.dataSource = self;
        _wishListTableView.rowHeight = 38;
        _wishListTableView.backgroundColor = [UIColor clearColor];
        _wishListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _wishListTableView;
}

- (UILabel *)wishAmountL {
    if (!_wishAmountL) {
        _wishAmountL = [[UILabel alloc] init];
        _wishAmountL.text = @"目标金额";
        _wishAmountL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_wishAmountL sizeToFit];
    }
    return _wishAmountL;
}

- (UITextField *)wishAmountTextF {
    if (!_wishAmountTextF) {
        _wishAmountTextF = [[UITextField alloc] init];
        _wishAmountTextF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _wishAmountTextF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _wishAmountTextF.keyboardType = UIKeyboardTypeDecimalPad;
        _wishAmountTextF.delegate = self;
    }
    return _wishAmountTextF;
}

- (UICollectionView *)moneyCollectionView {
    if (!_moneyCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 15;
        flowLayout.minimumLineSpacing = 15;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _moneyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _moneyCollectionView.delegate = self;
        _moneyCollectionView.dataSource = self;
        _moneyCollectionView.backgroundColor = [UIColor clearColor];
        [_moneyCollectionView registerClass:[SSJMakeWishMoneyCollectionViewCell class] forCellWithReuseIdentifier:wishMoneyCellId];
    }
    return _moneyCollectionView;
}

- (UIView *)bottomBg {
    if (!_bottomBg) {
        _bottomBg = [[UIView alloc] init];
        _bottomBg.layer.cornerRadius = 6;
        _bottomBg.layer.masksToBounds = YES;
    }
    return _bottomBg;
}

- (UIButton *)makeWishBtn {
    if (!_makeWishBtn) {
        _makeWishBtn = [[UIButton alloc] init];
        _makeWishBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_makeWishBtn setTitle:@"许下心愿" forState:UIControlStateNormal];
        _makeWishBtn.layer.cornerRadius = 6;
        _makeWishBtn.layer.masksToBounds = YES;
        @weakify(self);
        [[_makeWishBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
           //保存心愿
            self.wishModel.wishName = self.wishNameTextF.text;
            self.wishModel.wishMoney = [NSString stringWithFormat:@"%.2f",[self.wishAmountTextF.text doubleValue]];
            [SSJWishHelper saveWishWithWishModel:self.wishModel success:^{
                //进入许愿成功进度反馈页面
                SSJWishProgressViewController *wishProVC = [[SSJWishProgressViewController alloc] init];
                wishProVC.wishId = self.wishModel.wishId;
                [self.navigationController pushViewController:wishProVC animated:YES];
                self.wishModel = nil;
            } failure:^(NSError *error) {
                [CDAutoHideMessageHUD showMessage:error.localizedDescription];
            }];

        }];
    }
    return _makeWishBtn;
}

- (NSMutableArray *)wishListDataArray {
    if (!_wishListDataArray) {
//        _wishListDataArray = [NSMutableArray array];
        _wishListDataArray = [SSJWishDefItem defWishItemArr];
    }
    return _wishListDataArray;
}

- (SSJWishModel *)wishModel {
    if (!_wishModel) {
        _wishModel = [[SSJWishModel alloc] init];
        _wishModel.wishImage = @"wish_image_def";
    }
    return _wishModel;
}
@end
